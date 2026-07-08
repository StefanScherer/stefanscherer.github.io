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

  function tileConfig(language) {
    var lang = String(language || '').toLowerCase();

    // OSM-DE renders many place names in German/local language.
    if (lang === 'de' || lang.indexOf('de-') === 0) {
      return {
        url: 'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png',
        attribution: '&copy; OpenStreetMap contributors',
        maxZoom: 18,
        supportsThemeSwitch: false,
      };
    }

    var dark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    var url = dark
      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
      : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
    var attribution = '&copy; OpenStreetMap contributors &copy; CARTO';
    return {
      url: url,
      attribution: attribution,
      maxZoom: 19,
      supportsThemeSwitch: true,
    };
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

  function rectOverlaps(a, b, gap) {
    return !(
      a.right + gap < b.left ||
      a.left > b.right + gap ||
      a.bottom + gap < b.top ||
      a.top > b.bottom + gap
    );
  }

  function labelVisibilityStep(totalPoints, zoom) {
    if (!Number.isFinite(zoom)) {
      return 99;
    }

    if (zoom < 6.6) {
      return 99;
    }
    if (zoom < 7.6) {
      return totalPoints > 20 ? 4 : 3;
    }
    if (zoom < 8.6) {
      return totalPoints > 20 ? 3 : 2;
    }
    if (zoom < 9.6) {
      return 2;
    }
    return 1;
  }

  function setPointHighlight(entry, enabled, requestLayout) {
    if (!entry || !entry.layer) {
      return;
    }

    if (!entry.isEndpoint && entry.layer.setStyle) {
      if (enabled) {
        entry.layer.setStyle({
          weight: 3,
          color: '#0a6f82',
          fillColor: '#ffffff',
          fillOpacity: 1,
        });
        if (entry.layer.setRadius) {
          entry.layer.setRadius(9.5);
        }
      } else {
        entry.layer.setStyle({
          weight: 2,
          color: '#0a9396',
          fillColor: '#e9ffff',
          fillOpacity: 0.95,
        });
        if (entry.layer.setRadius) {
          entry.layer.setRadius(8);
        }
      }
    }

    var markerEl = entry.layer.getElement && entry.layer.getElement();
    if (markerEl) {
      markerEl.classList.toggle('trip-map-point-hover', enabled);
    }

    var tooltip = entry.layer.getTooltip && entry.layer.getTooltip();
    var tooltipEl = tooltip && tooltip.getElement && tooltip.getElement();
    if (!tooltipEl) {
      return;
    }

    tooltipEl.classList.toggle('trip-map-city-label-hover', enabled);
    if (enabled) {
      tooltipEl.classList.remove('trip-map-city-label-hidden');
      return;
    }

    if (typeof requestLayout === 'function') {
      requestLayout();
    }
  }

  function initPointLabels(map, labelEntries, totalPoints) {
    if (!labelEntries.length) {
      return;
    }

    var scheduled = false;
    var gapPx = 8;

    function scheduleLayout() {
      if (scheduled) {
        return;
      }
      scheduled = true;
      window.requestAnimationFrame(layoutLabels);
    }

    map._tripMapRelayout = scheduleLayout;

    function layoutLabels() {
      scheduled = false;
      var mapRect = map.getContainer().getBoundingClientRect();
      var zoom = map.getZoom();
      var step = labelVisibilityStep(totalPoints, zoom);

      labelEntries.forEach(function (entry) {
        var tooltip = entry.layer.getTooltip();
        if (!tooltip) {
          return;
        }
        var el = tooltip.getElement();
        if (!el) {
          return;
        }

        var keepByZoom = entry.isEndpoint || (entry.order > 0 && entry.order % step === 0);
        if (!keepByZoom) {
          el.classList.add('trip-map-city-label-hidden');
        } else {
          el.classList.remove('trip-map-city-label-hidden');
        }
      });

      var occupied = [];
      var candidates = labelEntries
        .filter(function (entry) {
          var tooltip = entry.layer.getTooltip();
          var el = tooltip && tooltip.getElement();
          return el && !el.classList.contains('trip-map-city-label-hidden');
        })
        .sort(function (a, b) {
          return b.priority - a.priority;
        });

      candidates.forEach(function (entry) {
        var tooltip = entry.layer.getTooltip();
        var el = tooltip && tooltip.getElement();
        if (!el) {
          return;
        }

        var r = el.getBoundingClientRect();
        var box = {
          left: r.left - mapRect.left,
          right: r.right - mapRect.left,
          top: r.top - mapRect.top,
          bottom: r.bottom - mapRect.top,
        };

        var outside = box.right < 0 || box.left > mapRect.width || box.bottom < 0 || box.top > mapRect.height;
        if (outside) {
          el.classList.add('trip-map-city-label-hidden');
          return;
        }

        var hasCollision = occupied.some(function (other) {
          return rectOverlaps(box, other, gapPx);
        });

        if (hasCollision) {
          el.classList.add('trip-map-city-label-hidden');
          return;
        }

        occupied.push(box);
      });
    }

    map.on('zoomend', scheduleLayout);
    map.on('moveend', scheduleLayout);
    map.on('resize', scheduleLayout);

    // Run after initial render and after fitBounds settled.
    setTimeout(scheduleLayout, 0);
    setTimeout(scheduleLayout, 120);
  }

  function initMap(el, data) {
    if (!window.L) {
      return;
    }
    // Prevent duplicate Leaflet init on the same element.
    if (el.getAttribute('data-trip-map-ready') === '1' || el._leaflet_id) {
      return;
    }

    var mapLanguage = el.getAttribute('data-map-language') || 'de';
    var cfg = tileConfig(mapLanguage);
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
      maxZoom: cfg.maxZoom,
      attribution: cfg.attribution,
      detectRetina: true,
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

      var labelEntries = [];
      function requestLabelLayout() {
        if (typeof map._tripMapRelayout === 'function') {
          map._tripMapRelayout();
        }
      }

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
          var props = (feature && feature.properties) || {};
          var order = Number(props.order || 0);
          var isEndpoint = order === 1 || !!props.is_end;

          if (props.name) {
            var side = order % 2 === 0 ? 'left' : 'right';
            var direction = isEndpoint ? 'top' : side;
            var offset = isEndpoint ? [0, -16] : (side === 'left' ? [-14, 0] : [14, 0]);

            layer.bindTooltip(htmlEscape(props.name), {
              permanent: true,
              direction: direction,
              offset: offset,
              className: 'trip-map-city-label',
              opacity: 1,
            });

            labelEntries.push({
              layer: layer,
              order: order,
              isEndpoint: isEndpoint,
              priority: isEndpoint ? 10000 - order : (1000 - order),
            });

            var entry = labelEntries[labelEntries.length - 1];
            layer.on('mouseover', function () {
              setPointHighlight(entry, true, requestLabelLayout);
            });
            layer.on('mouseout', function () {
              setPointHighlight(entry, false, requestLabelLayout);
            });
          }

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
      initPointLabels(map, labelEntries, totalPoints);
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

    if (cfg.supportsThemeSwitch && window.matchMedia) {
      var mq = window.matchMedia('(prefers-color-scheme: dark)');
      var onChange = function () {
        var nextCfg = tileConfig(mapLanguage);
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
