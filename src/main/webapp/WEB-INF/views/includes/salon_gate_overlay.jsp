<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 매장 미선택 시 본문 콘텐츠를 덮어 조작을 막는 오버레이. 세션의 selectedSalonId만 보고 판단하므로
     별도 모델 없이 어느 점주 페이지에서든 그대로 include 하면 된다. --%>
<c:if test="${empty sessionScope.selectedSalonId}">
  <div class="salon-gate-overlay">
    <div class="salon-gate-box">
      <i class="fas fa-store-slash"></i>
      <p>매장을 선택해야 이용할 수 있는 기능입니다.</p>
      <button type="button" id="salonGateSelectBtn" class="btn-modern btn-primary">매장 선택하기</button>
    </div>
  </div>
  <script>
    (function () {
      var btn = document.getElementById('salonGateSelectBtn');
      var modal = document.getElementById('salonSelectModal');
      if (btn && modal) {
        btn.addEventListener('click', function () { modal.classList.add('active'); });
      }
    })();
  </script>
</c:if>
