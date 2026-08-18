<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 예약 내역</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
  <link rel="stylesheet" href="<c:url value='/resources/css/calendar.css'/>">

  <style>
    .history-category-tabs {
      display: flex;
      gap: 8px;
      margin: 24px 0 16px;
      padding: 6px;
      border-radius: var(--radius-md);
      background: #f5f6f8;
    }

    .history-category-tab {
      flex: 1;
      padding: 12px 16px;
      border: 0;
      border-radius: calc(var(--radius-md) - 4px);
      background: transparent;
      color: var(--text-sub);
      font-size: 14px;
      font-weight: 700;
      cursor: pointer;
      transition: background-color .2s, color .2s, box-shadow .2s;
    }

    .history-category-tab.active {
      background: #fff;
      color: var(--primary);
      box-shadow: 0 2px 10px rgba(0, 0, 0, .08);
    }

    .history-category-tab .tab-count {
      margin-left: 4px;
      font-size: 12px;
    }

    .reservation-item[hidden] {
      display: none !important;
    }

    .reservation-empty {
      padding: 56px 20px;
      color: var(--text-sub);
      text-align: center;
    }

    .reservation-empty i {
      display: block;
      margin-bottom: 12px;
      font-size: 32px;
    }

    .reservation-pagination {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 6px;
      margin-top: 24px;
    }

    .reservation-page-button {
      min-width: 38px;
      height: 38px;
      padding: 0 10px;
      border: 1px solid #e1e4e8;
      border-radius: 8px;
      background: #fff;
      color: var(--text-sub);
      font-weight: 700;
      cursor: pointer;
    }

    .reservation-page-button.active {
      border-color: var(--primary);
      background: var(--primary);
      color: #fff;
    }

    .reservation-page-button:disabled {
      cursor: default;
      opacity: .4;
    }

    @media (max-width: 640px) {
      .history-category-tabs {
        flex-direction: column;
      }
    }
  </style>
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="reservations" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content">
      <!-- 상단 페이지 탭: 현재 페이지인 전체 예약 히스토리만 활성화 -->
      <div class="res-tabs">
        <div class="res-tab active">
          <a href="<c:url value='/common/reservation'/>">전체 예약 히스토리</a>
        </div>

        <div class="res-tab">
          <a href="<c:url value='/common/calendar'/>">예약 캘린더</a>
        </div>
      </div>

      <!-- 예약 분류 탭 -->
      <div class="history-category-tabs" role="tablist" aria-label="예약 분류">
        <button type="button" class="history-category-tab active" data-tab="upcoming" role="tab" aria-selected="true">
          예정 예약 <span class="tab-count" id="upcomingCount">0</span>
        </button>
        <button type="button" class="history-category-tab" data-tab="past" role="tab" aria-selected="false">
          지난 예약 <span class="tab-count" id="pastCount">0</span>
        </button>
        <button type="button" class="history-category-tab" data-tab="cancelled" role="tab" aria-selected="false">
          취소 예약 <span class="tab-count" id="cancelledCount">0</span>
        </button>
      </div>

      <div id="reservationCards">
        <c:forEach var="reserve" items="${reservs}">
          <article class="res-card reservation-item"
                   data-reservation-id="${reserve.reservationId}"
                   data-status="${reserve.status}"
                   data-reservation-time="${reserve.reservationTime}">
            <div class="res-card-header">
              <span style="font-size: 14px; color: var(--text-sub); font-weight: 600;">
                주문번호: ${reserve.transactionId}
              </span>

              <c:choose>
                <c:when test="${reserve.status eq 'pending'}">
                  <span class="status-badge status-upcoming">확정 대기</span>
                </c:when>
                <c:when test="${reserve.status eq 'confirmed'}">
                  <span class="status-badge status-upcoming">이용 예정 (확정)</span>
                </c:when>
                <c:when test="${reserve.status eq 'completed'}">
                  <span class="status-badge">이용 완료</span>
                </c:when>
                <c:when test="${reserve.status eq 'cancelled'}">
                  <span class="status-badge">예약 취소</span>
                </c:when>
                <c:otherwise>
                  <span class="status-badge">${reserve.status}</span>
                </c:otherwise>
              </c:choose>
            </div>

            <div class="res-card-body">
              <img
                src="https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&amp;fit=crop&amp;w=300&amp;q=80"
                style="width: 110px; height: 110px; border-radius: var(--radius-md); object-fit: cover;"
                alt="salon"
              >

              <div class="res-info-grid">
                <div class="res-meta-item">
                  <span>매장명</span>
                  <strong>${reserve.salonName}</strong>
                </div>

                <div class="res-meta-item">
                  <span>예약일시</span>
                  <strong>${reserve.reservationTime}</strong>
                </div>

                <div class="res-meta-item">
                  <span>시술 상품 / 소요 시간</span>
                  <strong>${reserve.serviceName} / ${reserve.durationMinutes > 0 ? reserve.durationMinutes : 60}분 소요 예상</strong>
                </div>

                <%-- 결제까지 못 간 예약은 Payments 행이 없어(LEFT JOIN) 금액이 0이다.
                     그때는 금액을 붙이지 않는다 — "0원" 은 무료 시술처럼 읽힌다. --%>
                <div class="res-meta-item">
                  <span>결제 수단 및 금액</span>
                  <strong>
                    <c:out value="${reserve.displayPayment}"/>
                    <c:if test="${reserve.amount > 0}">
                      / <fmt:formatNumber value="${reserve.amount}" pattern="#,##0"/>원
                    </c:if>
                  </strong>
                </div>
              </div>

              <div style="display:flex; flex-direction:column; gap:8px;">
                <%-- 방이 없으면 만들고 있으면 재사용한 뒤 그 방으로 리다이렉트된다 (ChatService.openRoom) --%>
                <form action="<c:url value='/common/chat/room'/>" method="post">
                  <input type="hidden" name="salonId" value="${reserve.salonId}">
                  <button type="submit" class="btn-modern btn-outline" style="width:100%;">1:1 문의</button>
                </form>

                <%-- JS가 예정 예약으로 분류한 confirmed 카드에서만 이 버튼을 표시한다. --%>
                <c:if test="${reserve.status eq 'confirmed'}">
                  <button
                    type="button"
                    class="btn-modern btn-primary reservation-cancel-btn"
                    data-reservation-id="${reserve.reservationId}"
                    style="width:100%; background:#FF4757; border-color:#FF4757;">
                    예약 취소
                  </button>
                </c:if>
              </div>
            </div>
          </article>
        </c:forEach>
      </div>

      <div id="reservationEmpty" class="res-card reservation-empty" hidden>
        <i class="fa-regular fa-calendar-xmark"></i>
        <span id="reservationEmptyMessage">등록된 예약정보가 없습니다.</span>
      </div>

      <nav id="reservationPagination" class="reservation-pagination" aria-label="예약 목록 페이지"></nav>
    </main>
  </div>

  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const PAGE_SIZE = 5;
      const contextPath = "${pageContext.request.contextPath}";
      const cardContainer = document.getElementById("reservationCards");
      const cards = Array.from(document.querySelectorAll(".reservation-item"));
      const tabButtons = Array.from(document.querySelectorAll(".history-category-tab"));
      const emptyBox = document.getElementById("reservationEmpty");
      const emptyMessage = document.getElementById("reservationEmptyMessage");
      const pagination = document.getElementById("reservationPagination");

      const pageByTab = {
        upcoming: 1,
        past: 1,
        cancelled: 1
      };

      const labels = {
        upcoming: "예정된 예약이 없습니다.",
        past: "지난 예약이 없습니다.",
        cancelled: "취소된 예약이 없습니다."
      };

      let activeTab = "upcoming";
      const now = new Date();

      function parseReservationTime(value) {
        if (!value) return new Date(NaN);

        // MySQL/JSP의 "yyyy-MM-dd HH:mm:ss" 형식도 브라우저가 안정적으로 읽도록 변환한다.
        const normalized = String(value).trim().replace(" ", "T");
        const parsed = new Date(normalized);
        if (!Number.isNaN(parsed.getTime())) return parsed;

        const parts = String(value).match(/^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?/);
        if (!parts) return new Date(NaN);

        return new Date(
          Number(parts[1]),
          Number(parts[2]) - 1,
          Number(parts[3]),
          Number(parts[4]),
          Number(parts[5]),
          Number(parts[6] || 0)
        );
      }

      function statusOf(card) {
        return (card.dataset.status || "").trim().toLowerCase();
      }

      function timeOf(card) {
        return parseReservationTime(card.dataset.reservationTime).getTime();
      }

      const groups = {
        upcoming: cards.filter(function (card) {
          return statusOf(card) !== "cancelled" && timeOf(card) >= now.getTime();
        }).sort(function (a, b) {
          return timeOf(a) - timeOf(b);
        }),

        past: cards.filter(function (card) {
          return statusOf(card) !== "cancelled" && timeOf(card) < now.getTime();
        }).sort(function (a, b) {
          return timeOf(b) - timeOf(a);
        }),

        cancelled: cards.filter(function (card) {
          return statusOf(card) === "cancelled";
        }).sort(function (a, b) {
          return timeOf(b) - timeOf(a);
        })
      };

      document.getElementById("upcomingCount").textContent = groups.upcoming.length;
      document.getElementById("pastCount").textContent = groups.past.length;
      document.getElementById("cancelledCount").textContent = groups.cancelled.length;

      // confirmed여도 시간이 지난 카드라면 취소 버튼을 숨긴다.
      cards.forEach(function (card) {
        const cancelButton = card.querySelector(".reservation-cancel-btn");
        if (cancelButton && !(statusOf(card) === "confirmed" && timeOf(card) >= now.getTime())) {
          cancelButton.remove();
        }
      });

      function createPageButton(label, page, disabled, active, ariaLabel) {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "reservation-page-button" + (active ? " active" : "");
        button.textContent = label;
        button.disabled = disabled;
        if (ariaLabel) button.setAttribute("aria-label", ariaLabel);
        if (active) button.setAttribute("aria-current", "page");
        button.addEventListener("click", function () {
          pageByTab[activeTab] = page;
          render();
        });
        return button;
      }

      function renderPagination(totalPages, currentPage) {
        pagination.innerHTML = "";
        pagination.hidden = totalPages <= 1;
        if (totalPages <= 1) return;

        pagination.appendChild(createPageButton("‹", currentPage - 1, currentPage === 1, false, "이전 페이지"));

        for (let page = 1; page <= totalPages; page += 1) {
          pagination.appendChild(createPageButton(String(page), page, false, page === currentPage, page + "페이지"));
        }

        pagination.appendChild(createPageButton("›", currentPage + 1, currentPage === totalPages, false, "다음 페이지"));
      }

      function render() {
        const activeCards = groups[activeTab];
        const totalPages = Math.max(1, Math.ceil(activeCards.length / PAGE_SIZE));
        pageByTab[activeTab] = Math.min(pageByTab[activeTab], totalPages);

        cards.forEach(function (card) {
          card.hidden = true;
        });

        if (activeCards.length === 0) {
          emptyMessage.textContent = labels[activeTab];
          emptyBox.hidden = false;
          pagination.hidden = true;
          return;
        }

        emptyBox.hidden = true;
        const start = (pageByTab[activeTab] - 1) * PAGE_SIZE;
        activeCards.slice(start, start + PAGE_SIZE).forEach(function (card) {
          // 정렬 결과와 화면 표시 순서를 일치시킨다.
          cardContainer.appendChild(card);
          card.hidden = false;
        });

        renderPagination(totalPages, pageByTab[activeTab]);
      }

      tabButtons.forEach(function (button) {
        button.addEventListener("click", function () {
          activeTab = button.dataset.tab;

          tabButtons.forEach(function (tabButton) {
            const selected = tabButton === button;
            tabButton.classList.toggle("active", selected);
            tabButton.setAttribute("aria-selected", String(selected));
          });

          render();
        });
      });

      document.querySelectorAll(".reservation-cancel-btn").forEach(function (button) {
        button.addEventListener("click", async function () {
          const reservationId = button.dataset.reservationId;

          if (!window.confirm("예약을 취소하시겠습니까?")) {
            return;
          }

          button.disabled = true;

          try {
            const response = await fetch(
              contextPath + "/common/reservation/cancel",
              {
                method: "POST",
                headers: {
                  "Content-Type": "application/x-www-form-urlencoded"
                },
                body: "reservationId=" + encodeURIComponent(reservationId)
              }
            );

            if (!response.ok) {
              throw new Error("HTTP " + response.status);
            }

            const result = await response.json();

            if (result.success) {
              alert("예약이 취소되었습니다.");
              // DB의 최신 cancelled 상태로 다시 분류하기 위해 현재 페이지를 새로 불러온다.
              window.location.reload();
            } else {
              button.disabled = false;
              alert(result.message || "예약을 취소할 수 없습니다.");
            }
          } catch (error) {
            button.disabled = false;
            console.error(error);
            alert("예약 취소 중 오류가 발생했습니다.");
          }
        });
      });

      render();
    });
  </script>
</body>
</html>
