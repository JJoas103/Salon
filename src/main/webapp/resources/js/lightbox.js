(function () {
  const overlay = document.createElement('div');
  overlay.className = 'lightbox-overlay';
  overlay.innerHTML = '<button type="button" class="lightbox-close" aria-label="닫기"><i class="fas fa-times"></i></button><img class="lightbox-image" alt="">';
  document.body.appendChild(overlay);
  const lightboxImage = overlay.querySelector('.lightbox-image');

  function closeLightbox() {
    overlay.classList.remove('is-open');
    lightboxImage.src = '';
  }

  document.addEventListener('click', function (event) {
    const trigger = event.target.closest('.lightbox-img');
    if (trigger) {
      lightboxImage.src = trigger.src;
      lightboxImage.alt = trigger.alt || '';
      overlay.classList.add('is-open');
      return;
    }
    if (event.target === overlay || event.target.closest('.lightbox-close')) {
      closeLightbox();
    }
  });
  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') closeLightbox();
  });
})();
