(function () {
  var links = Array.prototype.slice.call(
    document.querySelectorAll('.step-thumb-link[data-gallery]')
  );
  if (!links.length) {
    return;
  }

  var groups = {};
  links.forEach(function (link) {
    var g = link.getAttribute('data-gallery') || 'default';
    if (!groups[g]) {
      groups[g] = [];
    }
    groups[g].push(link);
  });

  var overlay = document.createElement('div');
  overlay.className = 'lightbox-overlay';
  overlay.innerHTML =
    '<button class="lightbox-close" aria-label="Schliessen">×</button>' +
    '<button class="lightbox-prev" aria-label="Vorheriges Bild">‹</button>' +
    '<figure class="lightbox-figure">' +
    '  <img class="lightbox-image" alt="" />' +
    '  <figcaption class="lightbox-caption"></figcaption>' +
    '</figure>' +
    '<button class="lightbox-next" aria-label="Naechstes Bild">›</button>';
  document.body.appendChild(overlay);

  var imageEl = overlay.querySelector('.lightbox-image');
  var captionEl = overlay.querySelector('.lightbox-caption');
  var closeBtn = overlay.querySelector('.lightbox-close');
  var prevBtn = overlay.querySelector('.lightbox-prev');
  var nextBtn = overlay.querySelector('.lightbox-next');

  var currentGroup = null;
  var currentIndex = 0;

  function render() {
    if (!currentGroup) {
      return;
    }
    var arr = groups[currentGroup] || [];
    if (!arr.length) {
      return;
    }
    if (currentIndex < 0) {
      currentIndex = arr.length - 1;
    }
    if (currentIndex >= arr.length) {
      currentIndex = 0;
    }

    var link = arr[currentIndex];
    var img = link.querySelector('img');
    imageEl.src = link.getAttribute('href');
    imageEl.alt = img ? img.getAttribute('alt') || '' : '';
    captionEl.textContent = (currentIndex + 1) + ' / ' + arr.length;
  }

  function openLightbox(group, index) {
    currentGroup = group;
    currentIndex = index;
    overlay.classList.add('is-open');
    document.body.classList.add('lightbox-open');
    render();
  }

  function closeLightbox() {
    overlay.classList.remove('is-open');
    document.body.classList.remove('lightbox-open');
    imageEl.src = '';
  }

  function move(delta) {
    currentIndex += delta;
    render();
  }

  links.forEach(function (link) {
    link.addEventListener('click', function (e) {
      e.preventDefault();
      var group = link.getAttribute('data-gallery') || 'default';
      var arr = groups[group] || [];
      var idx = arr.indexOf(link);
      if (idx < 0) {
        idx = 0;
      }
      openLightbox(group, idx);
    });
  });

  closeBtn.addEventListener('click', closeLightbox);
  prevBtn.addEventListener('click', function () {
    move(-1);
  });
  nextBtn.addEventListener('click', function () {
    move(1);
  });

  overlay.addEventListener('click', function (e) {
    if (e.target === overlay) {
      closeLightbox();
    }
  });

  document.addEventListener('keydown', function (e) {
    if (!overlay.classList.contains('is-open')) {
      return;
    }
    if (e.key === 'Escape') {
      closeLightbox();
    } else if (e.key === 'ArrowLeft') {
      move(-1);
    } else if (e.key === 'ArrowRight') {
      move(1);
    }
  });
})();
