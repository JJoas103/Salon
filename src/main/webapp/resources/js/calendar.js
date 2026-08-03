document.addEventListener("DOMContentLoaded", async function () {
    const calendarElement = document.getElementById("calendar");

    if (!calendarElement) {
        return;
    }

    const calendarView = document.getElementById("calendarView");
    const listView = document.getElementById("listView");

    const monthViewButton =
        document.getElementById("monthViewButton");

    const listViewButton =
        document.getElementById("listViewButton");

    const reservationList =
        document.getElementById("reservationList");

    const reservationCount =
        document.getElementById("reservationCount");

    const listMonthTitle =
        document.getElementById("listMonthTitle");

    const reservationModal =
        document.getElementById("reservationModal");

    let selectedReservation = null;

    /*
     * UI 확인용 데이터
     * 나중에 DB 조회 결과로 교체
     */
    let reservations = [];

    async function loadReservations() {

    const response = await fetch(
        calendarContextPath + "/common/calendar/events"
    );
    const data = await response.json();

    reservations = data.map(function(item){

        const start =
            item.reservationTime.replace(" ", "T");

        const endDate = new Date(start);
        endDate.setHours(endDate.getHours() + 1);

        return {
            id: item.reservationId,
            serviceName: item.serviceName,
            salonName: item.salonName,
            stylistName: "-",
            start: start,
            end: endDate.toISOString(),
            price: item.amount,
            request: "",
            status: convertStatus(item.status)
        };
    });
}
    function convertStatus(status){

       switch(status){

        case "completed":
            return "COMPLETED";
        case "cancelled":
            return "CANCELLED";
        default:
            return "UPCOMING";
       }
    }

    let listCurrentDate = new Date(2026, 7, 1);
    await loadReservations();

    const calendar = new FullCalendar.Calendar(calendarElement, {
        locale: "ko",
        initialView: "dayGridMonth",
        initialDate: "2026-08-01",
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

        buttonText: {
            today: "오늘"
        },

        titleFormat: {
            year: "numeric",
            month: "long"
        },

        eventTimeFormat: {
            hour: "2-digit",
            minute: "2-digit",
            hour12: false
        },

        events: reservations.map(function (reservation) {
            return {
                id: String(reservation.id),
                title: reservation.serviceName,
                start: reservation.start,
                end: reservation.end,
                extendedProps: {
                    reservation: reservation
                }
            };
        }),

        eventClick: function (info) {
            openReservationModal(
                info.event.extendedProps.reservation
            );
        },

        eventDidMount: function (info) {
            const reservation =
                info.event.extendedProps.reservation;

            const colors = {
                COMPLETED: "var(--success)",
                CANCELLED: "var(--danger)",
                UPCOMING: "var(--accent)"
            };

            info.el.style.setProperty(
                "border-left-color",
                colors[reservation.status] || "var(--accent)",
                "important"
            );
        }
    });

    calendar.render();

    monthViewButton.addEventListener("click", function () {
        calendarView.classList.remove("hidden");
        listView.classList.add("hidden");

        monthViewButton.classList.add("active");
        listViewButton.classList.remove("active");

        setTimeout(function () {
            calendar.updateSize();
        }, 0);
    });

    listViewButton.addEventListener("click", function () {
        calendarView.classList.add("hidden");
        listView.classList.remove("hidden");

        listViewButton.classList.add("active");
        monthViewButton.classList.remove("active");

        const calendarDate = calendar.getDate();

        listCurrentDate = new Date(
            calendarDate.getFullYear(),
            calendarDate.getMonth(),
            1
        );

        renderReservationList();
    });

    document
        .getElementById("previousListMonth")
        .addEventListener("click", function () {
            listCurrentDate.setMonth(
                listCurrentDate.getMonth() - 1
            );

            renderReservationList();
        });

    document
        .getElementById("nextListMonth")
        .addEventListener("click", function () {
            listCurrentDate.setMonth(
                listCurrentDate.getMonth() + 1
            );

            renderReservationList();
        });

    function renderReservationList() {
        const year = listCurrentDate.getFullYear();
        const month = listCurrentDate.getMonth();

        listMonthTitle.textContent =
            year + "년 " + (month + 1) + "월";

        const monthlyReservations = reservations
            .filter(function (reservation) {
                const date = new Date(reservation.start);

                return (
                    date.getFullYear() === year &&
                    date.getMonth() === month
                );
            })
            .sort(function (first, second) {
                return (
                    new Date(first.start) -
                    new Date(second.start)
                );
            });

        reservationCount.textContent =
            monthlyReservations.length;

        if (monthlyReservations.length === 0) {
            reservationList.innerHTML = `
                <div class="empty-reservation-list">
                    <i class="fa-regular fa-calendar-xmark"></i>
                    <h3>등록된 예약이 없습니다.</h3>
                    <p>다른 달을 선택해서 예약 내역을 확인해 주세요.</p>
                </div>
            `;

            return;
        }

        reservationList.innerHTML =
            monthlyReservations
                .map(createReservationCard)
                .join("");

        bindCardButtons();
    }

    function createReservationCard(reservation) {
        const status = getStatusInfo(reservation.status);

        const startDate = new Date(reservation.start);
        const endDate = new Date(reservation.end);

        const canCancel =
            reservation.status === "UPCOMING";

        return `
            <article class="reservation-card ${status.cardClass}">

                <header class="reservation-card-header">
                    <div>
                        <p class="reservation-salon">
                            ${escapeHtml(reservation.salonName)}
                        </p>

                        <h3 class="reservation-service-name">
                            ${escapeHtml(reservation.serviceName)}
                        </h3>
                    </div>

                    <span class="reservation-status ${status.badgeClass}">
                        ${status.text}
                    </span>
                </header>

                <div class="reservation-card-body">

                    ${createInfoItem(
                        "fa-regular fa-calendar",
                        "예약 날짜",
                        formatDate(startDate)
                    )}

                    ${createInfoItem(
                        "fa-regular fa-clock",
                        "예약 시간",
                        formatTime(startDate) +
                        " ~ " +
                        formatTime(endDate)
                    )}

                    ${createInfoItem(
                        "fa-solid fa-scissors",
                        "담당 디자이너",
                        reservation.stylistName
                    )}

                </div>

                <footer class="reservation-card-footer">

                    <button type="button"
                            class="calendar-action-button detail-button"
                            data-reservation-id="${reservation.id}">
                        <i class="fa-regular fa-file-lines"></i>
                        상세 보기
                    </button>

                    <button type="button"
                            class="calendar-action-button google google-button"
                            data-reservation-id="${reservation.id}">
                        <i class="fa-brands fa-google"></i>
                        Google Calendar
                    </button>

                    ${
                        canCancel
                            ? `
                                <button type="button"
                                        class="calendar-action-button danger cancel-button"
                                        data-reservation-id="${reservation.id}">
                                    <i class="fa-regular fa-circle-xmark"></i>
                                    예약 취소
                                </button>
                            `
                            : ""
                    }

                </footer>
            </article>
        `;
    }

    function createInfoItem(icon, label, value) {
        return `
            <div class="reservation-info">
                <span class="reservation-info-icon">
                    <i class="${icon}"></i>
                </span>

                <div>
                    <p class="reservation-info-label">
                        ${label}
                    </p>

                    <p class="reservation-info-value">
                        ${escapeHtml(value)}
                    </p>
                </div>
            </div>
        `;
    }

    function bindCardButtons() {
        document
            .querySelectorAll(".detail-button")
            .forEach(function (button) {
                button.addEventListener("click", function () {
                    openReservationModal(
                        findReservation(
                            button.dataset.reservationId
                        )
                    );
                });
            });

        document
            .querySelectorAll(".google-button")
            .forEach(function (button) {
                button.addEventListener("click", function () {
                    openGoogleCalendar(
                        findReservation(
                            button.dataset.reservationId
                        )
                    );
                });
            });

        document
            .querySelectorAll(".cancel-button")
            .forEach(function (button) {
                button.addEventListener("click", function () {
                    cancelReservation(
                        findReservation(
                            button.dataset.reservationId
                        )
                    );
                });
            });
    }

    function openReservationModal(reservation) {
        if (!reservation) {
            return;
        }

        selectedReservation = reservation;

        const status = getStatusInfo(reservation.status);
        const startDate = new Date(reservation.start);
        const endDate = new Date(reservation.end);

        document.getElementById("modalStatus").textContent =
            status.text;

        document.getElementById("modalServiceName").textContent =
            reservation.serviceName;

        document.getElementById("modalSalonName").textContent =
            reservation.salonName;

        document.getElementById("modalDate").textContent =
            formatDate(startDate);

        document.getElementById("modalTime").textContent =
            formatTime(startDate) +
            " ~ " +
            formatTime(endDate);

        document.getElementById("modalStylist").textContent =
            reservation.stylistName;

        document.getElementById("modalPrice").textContent =
            Number(reservation.price).toLocaleString("ko-KR") +
            "원";

        document.getElementById("modalRequest").textContent =
            reservation.request || "요청 사항 없음";

        document.getElementById("modalCancelButton").style.display =
            reservation.status === "UPCOMING"
                ? "inline-flex"
                : "none";

        reservationModal.classList.add("open");
        document.body.style.overflow = "hidden";
    }

    function closeReservationModal() {
        reservationModal.classList.remove("open");
        document.body.style.overflow = "";
        selectedReservation = null;
    }

    document
        .getElementById("modalCloseButton")
        .addEventListener("click", closeReservationModal);

    document
        .getElementById("modalBackdrop")
        .addEventListener("click", closeReservationModal);

    document
        .getElementById("modalConfirmButton")
        .addEventListener("click", closeReservationModal);

    document
        .getElementById("modalGoogleButton")
        .addEventListener("click", function () {
            if (selectedReservation) {
                openGoogleCalendar(selectedReservation);
            }
        });

    document
        .getElementById("modalCancelButton")
        .addEventListener("click", function () {
            if (selectedReservation) {
                cancelReservation(selectedReservation);
            }
        });

    function openGoogleCalendar(reservation) {
        const start = convertGoogleDate(reservation.start);
        const end = convertGoogleDate(reservation.end);

        const details =
            "매장: " + reservation.salonName + "\n" +
            "디자이너: " + reservation.stylistName + "\n" +
            "요청 사항: " +
            (reservation.request || "없음");

        const url =
            "https://calendar.google.com/calendar/render" +
            "?action=TEMPLATE" +
            "&text=" +
            encodeURIComponent(
                "[SALU] " + reservation.serviceName
            ) +
            "&dates=" +
            encodeURIComponent(start + "/" + end) +
            "&details=" +
            encodeURIComponent(details) +
            "&location=" +
            encodeURIComponent(reservation.salonName);

        window.open(url, "_blank", "noopener,noreferrer");
    }

    function cancelReservation(reservation) {
        if (!reservation) {
            return;
        }

        const confirmed = window.confirm(
            reservation.serviceName +
            " 예약을 취소하시겠습니까?"
        );

        if (!confirmed) {
            return;
        }

        reservation.status = "CANCELLED";

        closeReservationModal();
        renderReservationList();

        const event = calendar.getEventById(
            String(reservation.id)
        );

        if (event) {
            event.remove();
        }

        calendar.addEvent({
            id: String(reservation.id),
            title: reservation.serviceName,
            start: reservation.start,
            end: reservation.end,
            extendedProps: {
                reservation: reservation
            }
        });

        window.alert("예약이 취소되었습니다.");
    }

    function findReservation(id) {
        return reservations.find(function (reservation) {
            return String(reservation.id) === String(id);
        });
    }

    function getStatusInfo(status) {
        switch (status) {
            case "COMPLETED":
                return {
                    text: "이용 완료",
                    cardClass: "status-completed",
                    badgeClass: "completed"
                };

            case "CANCELLED":
                return {
                    text: "예약 취소",
                    cardClass: "status-cancelled",
                    badgeClass: "cancelled"
                };

            default:
                return {
                    text: "이용 예정",
                    cardClass: "status-upcoming",
                    badgeClass: ""
                };
        }
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