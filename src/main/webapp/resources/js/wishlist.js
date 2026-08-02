(function () {
  const forms = Array.from(document.querySelectorAll('.wishlist-form'));
  if (!forms.length) return;

  function updateButtons(salonId, wishlisted) {
    document.querySelectorAll('.wishlist-form[data-salon-id="' + salonId + '"] .wishlist-btn')
      .forEach(function (button) {
        button.classList.toggle('is-active', wishlisted);
        button.innerHTML = '<i class="' + (wishlisted ? 'fas' : 'far') +
          ' fa-heart"></i> ' + (wishlisted ? '찜완료' : '찜하기');
      });
  }

  forms.forEach(function (form) {
    form.addEventListener('submit', async function (event) {
      event.preventDefault();
      const button = form.querySelector('.wishlist-btn');
      if (!button || button.disabled) return;
      button.disabled = true;

      try {
        const response = await fetch(form.action, {
          method: 'POST',
          headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' }
        });
        if (response.redirected) {
          window.location.href = response.url;
          return;
        }
        if (!response.ok) throw new Error('찜 상태를 변경하지 못했습니다.');
        const result = await response.json();
        updateButtons(form.dataset.salonId, result.wishlisted);
        document.dispatchEvent(new CustomEvent('wishlist:changed', {
          detail: { salonId: form.dataset.salonId, wishlisted: result.wishlisted,
                    wishlistCount: result.wishlistCount }
        }));

        document.querySelectorAll('[data-wishlist-count]').forEach(function (element) {
          element.textContent = result.wishlistCount;
        });
        if (!result.wishlisted && form.dataset.removeCard === 'true') {
          const card = form.closest('[data-wishlist-card]');
          if (card) {
            card.classList.add('is-removing');
            window.setTimeout(function () {
              card.remove();
              if (!document.querySelector('[data-wishlist-card]')) {
                const grid = document.querySelector('.wishlist-grid');
                if (grid) {
                  // 주소는 JSP 가 data-home-url 로 내려준다 (컨텍스트 경로 포함)
                  const homeUrl = grid.dataset.homeUrl || '/common/home';
                  grid.outerHTML =
                    '<div class="wishlist-empty"><i class="far fa-heart"></i>' +
                    '<h2>아직 찜한 헤어샵이 없습니다.</h2>' +
                    '<p>마음에 드는 헤어샵을 찜해두면 이곳에서 바로 확인할 수 있어요.</p>' +
                    '<a class="btn-modern btn-primary" href="' + homeUrl + '">헤어샵 둘러보기</a></div>';
                }
              }
            }, 220);
          }
        }
      } catch (error) {
        window.alert(error.message);
      } finally {
        button.disabled = false;
      }
    });
  });
}());
