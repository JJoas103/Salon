document.addEventListener("DOMContentLoaded", async function () {
    "use strict";

    const calendarElement = document.getElementById("calendar");
    if (!calendarElement) return;

    const elements = {
        calendarView: document.getElementById("calendarView"),
        listView: document.getElementById("listView"),
        monthViewButton: document.getElementById("monthViewButton"),
        listViewButton: document.getElementById("listViewButton"),
        reservationList: document.getElementById("reservationList"),
        reservationCount: document.getElementById("reservationCount"),
        listMonthTitle: document.getElementById("listMonthTitle"),
        previousListMonth: document.getElementById("previousListMonth"),
        nextListMonth: document.getElementById("nextListMonth"),
        reservationModal: document.getElementById("reservationModal"),
        modalBackdrop: document.getElementById("modalBackdrop"),
        modalCloseButton: document.getElementById("modalCloseButton"),
        modalConfirmButton: document.getElementById("modalConfirmButton"),
        modalGoogleButton: document.getElementById("modalGoogleButton")
    };

    let reservations = [];
    let selectedReservation = null;
    let calendar = null;
    const today = new Date();
    let listCurrentDate = new Date(today.getFullYear(), today.getMonth(), 1);

    function parseDateTime(value) {
        if (!value) return new Date(NaN);

        const normalized = String(value).trim().replace(" ", "T");
        const parsed = new Date(normalized);
        if (!Number.isNaN(parsed.getTime())) return parsed;

        const parts = String(value).match(
            /^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?/
        );
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

    function convertStatus(rawStatus, startDate) {
        const status = String(rawStatus || "").toLowerCase();

        if (status === "cancelled") return "CANCELLED";
        if (status === "completed") return "COMPLETED";

        // 확정 상태여도 예약 시각이 지났다면 취소할 수 없는 지난 예약으로 표시한다.
        if (status === "confirmed" && startDate.getTime() >= Date.now()) {
            return "UPCOMING";
        }

        return "COMPLETED";
    }

    async function loadReservations() {
        const response = await fetch(
            calendarContextPath + "/common/calendar/events",
            { headers: { "Accept": "application/json" } }
        );

        if (!response.ok) {
            throw new Error("예약 정보를 불러오지 못했습니다. (" + response.status + ")");
        }

        const data = await response.json();

        reservations = data.map(function (item) {
            const startDate = parseDateTime(item.reservationTime);
            const endDate = new Date(startDate.getTime() + 60 * 60 * 1000);

            return {
                id: item.reservationId,
                serviceName: item.serviceName || "예약",
                salonName: item.salonName || "-",
                stylistName: item.stylistName || "-",
                start: startDate.toISOString(),
                end: endDate.toISOString(),
                price: item.amount || 0,
                request: item.request || "",
                status: convertStatus(item.status, startDate)
            };
        }).filter(function (reservation) {
            // 취소 예약은 월 캘린더와 캘린더 목록에서 모두 완전히 제외한다.
            return reservation.status !== "CANCELLED";
        });
    }

    function createCalendarEvents() {
        return reservations.map(function (reservation) {
            return {
                id: String(reservation.id),
                title: reservation.serviceName,
                start: reservation.start,
                end: reservation.end,
                extendedProps: { reservation: reservation }
            };
        });
    }

    function refreshCalendarEvents() {
        if (!calendar) return;

        // 이전 이벤트를 모두 제거한 뒤 최신 배열을 한 번만 등록하여 중복을 막는다.
        calendar.removeAllEvents();
        calendar.addEventSource(createCalendarEvents());
    }

    try {
        await loadReservations();
    } catch (error) {
        console.error("예약 조회 오류:", error);
        window.alert("예약 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.");
    }

    calendar = new FullCalendar.Calendar(calendarElement, {
        locale: "ko",
        initialView: "dayGridMonth",
        initialDate: new Date(),
        height: "auto",
        fixedWeekCount: false,
        dayMaxEvents: 3,
        eventDisplay: "block",
        displayEventTime: true,
        headerToolbar: {
            left: "prev,next today",
            center: "title",
            right: ""
        },
        buttonText: { today: "오늘" },
        titleFormat: { year: "numeric", month: "long" },
        eventTimeFormat: {
            hour: "2-digit",
            minute: "2-digit",
            hour12: false
        },
        events: createCalendarEvents(),
        eventClick: function (info) {
            openReservationModal(info.event.extendedProps.reservation);
        },
        eventDidMount: function (info) {
            const reservation = info.event.extendedProps.reservation;
            const color = reservation.status === "COMPLETED"
                ? "var(--success)"
                : "var(--accent)";
            info.el.style.setProperty("border-left-color", color, "important");
        }
    });

    calendar.render();

    elements.monthViewButton?.addEventListener("click", function () {
        elements.calendarView?.classList.remove("hidden");
        elements.listView?.classList.add("hidden");
        elements.monthViewButton.classList.add("active");
        elements.listViewButton?.classList.remove("active");
        setTimeout(function () { calendar.updateSize(); }, 0);
    });

    elements.listViewButton?.addEventListener("click", function () {
        elements.calendarView?.classList.add("hidden");
        elements.listView?.classList.remove("hidden");
        elements.listViewButton.classList.add("active");
        elements.monthViewButton?.classList.remove("active");

        const calendarDate = calendar.getDate();
        listCurrentDate = new Date(
            calendarDate.getFullYear(),
            calendarDate.getMonth(),
            1
        );
        renderReservationList();
    });

    elements.previousListMonth?.addEventListener("click", function () {
        listCurrentDate = new Date(
            listCurrentDate.getFullYear(),
            listCurrentDate.getMonth() - 1,
            1
        );
        renderReservationList();
    });

    elements.nextListMonth?.addEventListener("click", function () {
        listCurrentDate = new Date(
            listCurrentDate.getFullYear(),
            listCurrentDate.getMonth() + 1,
            1
        );
        renderReservationList();
    });

    function renderReservationList() {
        if (!elements.reservationList) return;

        const year = listCurrentDate.getFullYear();
        const month = listCurrentDate.getMonth();

        if (elements.listMonthTitle) {
            elements.listMonthTitle.textContent = year + "년 " + (month + 1) + "월";
        }

        const monthlyReservations = reservations.filter(function (reservation) {
            const date = new Date(reservation.start);
            return date.getFullYear() === year && date.getMonth() === month;
        }).sort(function (first, second) {
            return new Date(first.start) - new Date(second.start);
        });

        if (elements.reservationCount) {
            elements.reservationCount.textContent = monthlyReservations.length;
        }

        if (monthlyReservations.length === 0) {
            elements.reservationList.innerHTML = `
                <div class="empty-reservation-list">
                    <i class="fa-regular fa-calendar-xmark"></i>
                    <h3>등록된 예약이 없습니다.</h3>
                    <p>다른 달을 선택해서 예약 내역을 확인해 주세요.</p>
                </div>
            `;
            return;
        }

        elements.reservationList.innerHTML = monthlyReservations
            .map(createReservationCard)
            .join("");
        bindCardButtons();
    }

    function createReservationCard(reservation) {
        const status = getStatusInfo(reservation.status);
        const startDate = new Date(reservation.start);
        const endDate = new Date(reservation.end);
        const googleButton = `
            <button type="button" class="calendar-action-button google google-button"
                    data-reservation-id="${reservation.id}">
                <i class="fa-brands fa-google"></i> Google Calendar
            </button>
        `;

        const cancelButton = reservation.status === "UPCOMING" ? `
            <button type="button" class="calendar-action-button danger cancel-button"
                    data-reservation-id="${reservation.id}">
                <i class="fa-regular fa-circle-xmark"></i> 예약 취소
            </button>
        ` : "";

        return `
            <article class="reservation-card ${status.cardClass}">
                <header class="reservation-card-header">
                    <div>
                        <p class="reservation-salon">${escapeHtml(reservation.salonName)}</p>
                        <h3 class="reservation-service-name">${escapeHtml(reservation.serviceName)}</h3>
                    </div>
                    <span class="reservation-status ${status.badgeClass}">${status.text}</span>
                </header>
                <div class="reservation-card-body">
                    ${createInfoItem("fa-regular fa-calendar", "예약 날짜", formatDate(startDate))}
                    ${createInfoItem(
                        "fa-regular fa-clock",
                        "예약 시간",
                        formatTime(startDate) + " ~ " + formatTime(endDate)
                    )}
                    ${createInfoItem(
                        "fa-solid fa-scissors",
                        "담당 디자이너",
                        reservation.stylistName
                    )}
                </div>
                <footer class="reservation-card-footer">
                    <button type="button" class="calendar-action-button detail-button"
                            data-reservation-id="${reservation.id}">
                        <i class="fa-regular fa-file-lines"></i> 상세 보기
                    </button>
                    ${googleButton}
                    ${cancelButton}
                </footer>
            </article>
        `;
    }

    function createInfoItem(icon, label, value) {
        return `
            <div class="reservation-info">
                <span class="reservation-info-icon"><i class="${icon}"></i></span>
                <div>
                    <p class="reservation-info-label">${escapeHtml(label)}</p>
                    <p class="reservation-info-value">${escapeHtml(value)}</p>
                </div>
            </div>
        `;
    }

    function bindCardButtons() {
        elements.reservationList.querySelectorAll(".detail-button").forEach(function (button) {
            button.addEventListener("click", function () {
                openReservationModal(findReservation(button.dataset.reservationId));
            });
        });

        elements.reservationList.querySelectorAll(".google-button").forEach(function (button) {
            button.addEventListener("click", function () {
                openGoogleCalendar(findReservation(button.dataset.reservationId));
            });
        });

        elements.reservationList.querySelectorAll(".cancel-button").forEach(function (button) {
            button.addEventListener("click", function () {
                cancelReservation(findReservation(button.dataset.reservationId), button);
            });
        });
    }

    function setText(id, value) {
        const element = document.getElementById(id);
        if (element) element.textContent = value;
    }

    function openReservationModal(reservation) {
        if (!reservation || !elements.reservationModal) return;

        selectedReservation = reservation;
        const status = getStatusInfo(reservation.status);
        const startDate = new Date(reservation.start);
        const endDate = new Date(reservation.end);

        setText("modalStatus", status.text);
        setText("modalServiceName", reservation.serviceName);
        setText("modalSalonName", reservation.salonName);
        setText("modalDate", formatDate(startDate));
        setText("modalTime", formatTime(startDate) + " ~ " + formatTime(endDate));
        setText("modalStylist", reservation.stylistName);
        setText("modalPrice", Number(reservation.price).toLocaleString("ko-KR") + "원");
        setText("modalRequest", reservation.request || "요청 사항 없음");

        // 취소 예약은 캘린더 데이터에서 제외되므로 상세 모달에서는 항상 사용할 수 있다.
        if (elements.modalGoogleButton) elements.modalGoogleButton.hidden = false;

        elements.reservationModal.classList.add("open");
        document.body.style.overflow = "hidden";
    }

    function closeReservationModal() {
        elements.reservationModal?.classList.remove("open");
        document.body.style.overflow = "";
        selectedReservation = null;
    }

    elements.modalCloseButton?.addEventListener("click", closeReservationModal);
    elements.modalBackdrop?.addEventListener("click", closeReservationModal);
    elements.modalConfirmButton?.addEventListener("click", closeReservationModal);
    elements.modalGoogleButton?.addEventListener("click", function () {
        if (selectedReservation) openGoogleCalendar(selectedReservation);
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && elements.reservationModal?.classList.contains("open")) {
            closeReservationModal();
        }
    });

    function openGoogleCalendar(reservation) {
        if (!reservation) return;

        const details = [
            "매장: " + reservation.salonName,
            "디자이너: " + reservation.stylistName,
            "요청 사항: " + (reservation.request || "없음")
        ].join("\n");

        const parameters = new URLSearchParams({
            action: "TEMPLATE",
            text: "[SALU] " + reservation.serviceName,
            dates: convertGoogleDate(reservation.start) + "/" + convertGoogleDate(reservation.end),
            details: details,
            location: reservation.salonName
        });

        window.open(
            "https://calendar.google.com/calendar/render?" + parameters.toString(),
            "_blank",
            "noopener,noreferrer"
        );
    }

    async function cancelReservation(reservation, clickedButton) {
        if (!reservation || reservation.status !== "UPCOMING") {
            window.alert("취소할 수 없는 예약입니다.");
            return;
        }

        if (!window.confirm(reservation.serviceName + " 예약을 취소하시겠습니까?")) return;
        if (clickedButton) clickedButton.disabled = true;

        try {
            const response = await fetch(
                calendarContextPath + "/common/reservation/cancel",
                {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: "reservationId=" + encodeURIComponent(reservation.id)
                }
            );

            if (!response.ok) {
                throw new Error("예약 취소 요청에 실패했습니다. (" + response.status + ")");
            }

            const result = await response.json();
            if (!result.success) {
                if (clickedButton) clickedButton.disabled = false;
                window.alert(result.message || "예약을 취소할 수 없습니다.");
                return;
            }

            // 서버에서 다시 조회한 최신 결과만 사용한다.
            await loadReservations();
            refreshCalendarEvents();
            renderReservationList();
            closeReservationModal();
            window.alert("예약이 취소되었습니다.");
        } catch (error) {
            if (clickedButton) clickedButton.disabled = false;
            console.error("예약 취소 오류:", error);
            window.alert("예약 취소 처리 중 오류가 발생했습니다.");
        }
    }

    function findReservation(id) {
        return reservations.find(function (reservation) {
            return String(reservation.id) === String(id);
        });
    }

    function getStatusInfo(status) {
        if (status === "COMPLETED") {
            return {
                text: "이용 완료",
                cardClass: "status-completed",
                badgeClass: "completed"
            };
        }

        return {
            text: "이용 예정",
            cardClass: "status-upcoming",
            badgeClass: ""
        };
    }

    function formatDate(date) {
        return new Intl.DateTimeFormat("ko-KR", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            weekday: "short"
        }).format(date);
    }

    function formatTime(date) {
        return new Intl.DateTimeFormat("ko-KR", {
            hour: "2-digit",
            minute: "2-digit",
            hour12: false
        }).format(date);
    }

    function convertGoogleDate(value) {
        return new Date(value)
            .toISOString()
            .replace(/[-:]/g, "")
            .replace(/\.\d{3}/, "");
    }

    function escapeHtml(value) {
        return String(value ?? "")
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    }
});