(function () {
  function loadCss(href) {
    if (document.querySelector('link[data-trip-map][href="' + href + '"]')) {
      return;
    }
    var link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = href;
    link.setAttribute('data-trip-map', '1');
    document.head.appendChild(link);
  }

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var existing = document.querySelector('script[data-trip-map][src="' + src + '"]');
      if (existing) {
        if (existing.getAttribute('data-loaded') === '1') {
          resolve();
          return;
        }
        existing.addEventListener('load', function () { resolve(); });
        existing.addEventListener('error', reject);
        return;
      }
      var script = document.createElement('script');
      script.src = src;
      script.defer = true;
      script.setAttribute('data-trip-map', '1');
      script.addEventListener('load', function () {
        script.setAttribute('data-loaded', '1');
        resolve();
      });
      script.addEventListener('error', reject);
      document.head.appendChild(script);
    });
  }

  function htmlEscape(s) {
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function normalizeText(s) {
    return String(s || '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  function shortenText(s, maxLen) {
    var t = String(s || '').trim().replace(/\s+/g, ' ');
    if (t.length <= maxLen) {
      return t;
    }
    return t.slice(0, maxLen - 1).trimEnd() + '...';
  }

  function buildStageContext() {
    var headings = Array.prototype.slice.call(document.querySelectorAll('article h4'));
    var ordered = [];
    var byName = {};

    headings.forEach(function (h, idx) {
      var raw = (h.textContent || '').trim();
      var m = raw.match(/^Etappe:\s*(.+)$/i);
      if (!m) {
        return;
      }

      var name = (m[1] || '').trim();
      if (!name) {
        return;
      }

      if (!h.id) {
        h.id = 'etappe-' + normalizeText(name) + '-' + (idx + 1);
      }

      var next = h.nextElementSibling;
      var snippet = '';
      if (next && next.tagName && next.tagName.toLowerCase() === 'p') {
        snippet = shortenText(next.textContent || '', 160);
      }

      var entry = {
        id: h.id,
        name: name,
        snippet: snippet,
      };

      ordered.push(entry);
      var key = normalizeText(name);
      if (!byName[key]) {
        byName[key] = [];
      }
      byName[key].push(entry);
    });

    return {
      ordered: ordered,
      byName: byName,
    };
  }

  function stageForFeature(feature, stageCtx) {
    if (!stageCtx) {
      return null;
    }

    var p = (feature && feature.properties) || {};
    var key = normalizeText(p.name || '');
    var list = stageCtx.byName[key] || [];
    if (list.length) {
      return list[0];
    }

    var order = Number(p.order || 0);
    if (Number.isFinite(order) && order > 0 && order <= stageCtx.ordered.length) {
      return stageCtx.ordered[order - 1];
    }

    return null;
  }

  function tileConfig() {
    var dark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    var url = dark
      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
      : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
    var attribution = '&copy; OpenStreetMap contributors &copy; CARTO';
    return { url: url, attribution: attribution };
  }

  function pointPopup(feature, stageCtx) {
    var p = (feature && feature.properties) || {};
    var order = Number(p.order || 0);
    var stageTag = '';
    if (order === 1) {
      stageTag = '<br><span class="trip-map-popup-stage is-start">Start</span>';
    } else if (order > 1 && p.is_end) {
      stageTag = '<br><span class="trip-map-popup-stage is-end">Ziel</span>';
    }
    var title = p.name ? '<strong>' + htmlEscape(p.name) + '</strong>' : '<strong>Etappe</strong>';
    var day = p.day ? '<br>Tag ' + htmlEscape(p.day) : '';
    var date = p.date ? '<br>' + htmlEscape(p.date) : '';
    var stage = stageForFeature(feature, stageCtx);
    var snippet = (p.note || '').trim();
    if (!snippet && stage && stage.snippet) {
      snippet = stage.snippet;
    }
    var extra = snippet ? '<br><span class="trip-map-popup-note">' + htmlEscape(shortenText(snippet, 160)) + '</span>' : '';
    var jump = stage ? '<br><a class="trip-map-popup-jump" href="#' + encodeURIComponent(stage.id) + '">Zur Etappe springen</a>' : '';
    return title + stageTag + day + date + extra + jump;
  }

  function initMap(el, data) {
    if (!window.L) {
      return;
    }
    // Prevent duplicate Leaflet init on the same element.
    if (el.getAttribute('data-trip-map-ready') === '1' || el._leaflet_id) {
      return;
    }

    var cfg = tileConfig();
    var stageCtx = buildStageContext();
    var map = L.map(el, {
      scrollWheelZoom: true,
      zoomControl: true,
      zoomSnap: 0.25,
      zoomDelta: 0.25,
      wheelPxPerZoomLevel: 90,
      wheelDebounceTime: 40,
    });
    // Ensure renderer bounds exist before adding vector layers.
    map.setView([0, 0], 2);

    var tiles = L.tileLayer(cfg.url, {
      maxZoom: 19,
      attribution: cfg.attribution,
    }).addTo(map);

    var points = [];
    if (data && data.features && Array.isArray(data.features)) {
      data.features.forEach(function (f) {
        if (!f || !f.geometry || f.geometry.type !== 'Point') {
          return;
        }
        var c = f.geometry.coordinates || [];
        if (c.length < 2) {
          return;
        }
        points.push([c[1], c[0], f]);
      });
    }

    if (points.length) {
      var totalPoints = points.length;
      points.sort(function (a, b) {
        var oa = (((a[2] || {}).properties || {}).order) || 0;
        var ob = (((b[2] || {}).properties || {}).order) || 0;
        return oa - ob;
      });

      var lastFeature = points[totalPoints - 1][2];
      if (lastFeature && lastFeature.properties) {
        lastFeature.properties.is_end = true;
      }

      var geo = {
        type: 'FeatureCollection',
        features: points.map(function (p) { return p[2]; }),
      };

      var markerLayer = L.geoJSON(geo, {
        pointToLayer: function (feature, latlng) {
          var props = (feature && feature.properties) || {};
          var order = Number(props.order || 0);
          var isStart = order === 1;
          var isEnd = !!props.is_end;

          if (isStart || isEnd) {
            return L.marker(latlng, {
              icon: L.divIcon({
                className: 'trip-map-stage-marker ' + (isStart ? 'is-start' : 'is-end'),
                html: '<span>' + (isStart ? 'S' : 'Z') + '</span>',
                iconSize: [26, 26],
                iconAnchor: [13, 13],
                popupAnchor: [0, -12],
              }),
            });
          }

          return L.circleMarker(latlng, {
            radius: 8,
            weight: 2,
            color: '#0a9396',
            fillColor: '#e9ffff',
            fillOpacity: 0.95,
          });
        },
        onEachFeature: function (feature, layer) {
          layer.bindPopup(pointPopup(feature, stageCtx));
        },
      }).addTo(map);

      if (points.length > 1) {
        var route = points.map(function (p) { return [p[0], p[1]]; });
        L.polyline(route, {
          color: '#bb3e03',
          weight: 3,
          opacity: 0.9,
          interactive: false,
        }).addTo(map);
      }

      markerLayer.bringToFront();

      map.fitBounds(markerLayer.getBounds().pad(0.15));
    } else {
      map.setView([51.1657, 10.4515], 5);
    }

    var gpxPath = el.getAttribute('data-gpx');
    if (gpxPath) {
      loadScript('https://unpkg.com/leaflet-gpx@1.7.0/gpx.min.js').then(function () {
        if (!window.L || !window.L.GPX) {
          return;
        }
        new L.GPX(gpxPath, {
          async: true,
          marker_options: {
            startIconUrl: null,
            endIconUrl: null,
            shadowUrl: null,
          },
          polyline_options: {
            color: '#ff7f11',
            weight: 3,
            opacity: 0.85,
          },
        })
          .on('loaded', function (e) {
            map.fitBounds(e.target.getBounds().pad(0.1));
          })
          .addTo(map);
      });
    }

    if (window.matchMedia) {
      var mq = window.matchMedia('(prefers-color-scheme: dark)');
      var onChange = function () {
        var nextCfg = tileConfig();
        tiles.setUrl(nextCfg.url);
      };
      if (mq.addEventListener) {
        mq.addEventListener('change', onChange);
      } else if (mq.addListener) {
        mq.addListener(onChange);
      }
    }

    el.setAttribute('data-trip-map-ready', '1');
  }

  function initAll() {
    var maps = Array.prototype.slice.call(document.querySelectorAll('.trip-map[data-geojson]'));
    if (!maps.length) {
      return;
    }

    loadCss('https://unpkg.com/leaflet@1.9.4/dist/leaflet.css');
    loadScript('https://unpkg.com/leaflet@1.9.4/dist/leaflet.js').then(function () {
      maps.forEach(function (el) {
        if (el.getAttribute('data-trip-map-init') === '1' || el.getAttribute('data-trip-map-ready') === '1') {
          return;
        }
        el.setAttribute('data-trip-map-init', '1');

        var path = el.getAttribute('data-geojson');
        if (!path) {
          el.removeAttribute('data-trip-map-init');
          return;
        }
        fetch(path)
          .then(function (res) { return res.json(); })
          .then(function (data) {
            initMap(el, data);
            el.removeAttribute('data-trip-map-init');
          })
          .catch(function (err) {
            console.error('Trip map init failed:', err);
            el.innerHTML = '<p class="trip-map-error">Karte konnte nicht geladen werden.</p>';
            el.removeAttribute('data-trip-map-init');
          });
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAll);
  } else {
    initAll();
  }
})();
