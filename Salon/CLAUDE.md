# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

`salu` is a hair salon reservation platform (미용실 예약 플랫폼) built as a **legacy-style** Spring stack: Spring MVC 5 (XML config) + Spring Security 5 (Java config) + MyBatis + JSP/JSTL, packaged as a WAR for Tomcat 9. It intentionally does not use Spring Boot. See `docs/초기세팅가이드.md` for the full stack rationale.

**Tomcat version is load-bearing**: this project uses `javax.servlet` (not `jakarta.servlet`), so it only runs on **Tomcat 9**. Tomcat 10+ will not work without a full jakarta migration.

## Build & run

```bash
mvn clean package -DskipTests -q   # build target/salu.war
mvn clean package                  # build with tests (no test sources exist yet)
```

- No test framework is wired into `pom.xml` yet — there is no `mvn test` suite to run today.
- DB init: `mysql -u root -p < sql/schema.sql` (creates the `salu` database + all tables). `dummydata_original.sql` has seed data.
- Local DB credentials live in `src/main/resources/properties/db.properties`, which **is committed intentionally** (see comment in `.gitignore` — team shares dev DB credentials at this stage; this must change before any real deployment).
- Deploy scripts (`deploy.sh` for Linux/root, `deploy.bat` for Windows) build the WAR and copy it into Tomcat as `ROOT.war`, so the app serves from context path `/`, not `/salu`, despite the WAR's `finalName`.

## Architecture

**Request flow**: `Controller → Service → Mapper (interface) → Mapper XML (SQL) → MySQL`, wired by MyBatis. Adding a feature almost always means touching all four layers plus the matching `vo/` class.

**Two separate Spring contexts** — a common source of "why isn't my bean found" confusion in this codebase:
- Root context (`applicationContext.xml`, loaded by `ContextLoaderListener`): DataSource, MyBatis `SqlSessionFactory`, `MapperScannerConfigurer` (scans `com.soldesk.mapper`), transaction manager. Component-scans only `com.soldesk.config` and `com.soldesk.security`.
- Web context (`WEB-INF/spring/dispatcher-servlet.xml`, the `DispatcherServlet`): component-scans `controller`, `service`, `config`, `validation`, `handler`; owns the `InternalResourceViewResolver` (`/WEB-INF/views/{viewName}.jsp`) and static resource mapping (`/resources/**` → `webapp/resources/`).

  Mappers live only in the root context; controllers/services live only in the web context. Both contexts scan `com.soldesk.config`, so config classes must not assume which context they end up in.

**VO ↔ table mapping**: Java fields are camelCase, DB columns are snake_case; each MyBatis mapper XML declares an explicit `resultMap` to bridge them (see `UserMapper.xml`). Follow this pattern for new mappers rather than relying on MyBatis's auto camel-case mapping (it isn't enabled globally).

**Security** (`config/SecurityConfig.java`, Java-based, not XML): form login at `/user/login` with **non-default parameter names** `userEmail`/`userPassword` (must match the `name=` attributes in `login.jsp`). Roles are `ADMIN` / `OWNER` / `CUSTOMER`, derived at login time from `Users.user_type` by `UserDetailService.resolveRole()` — there is no roles/permissions table. `/admin/**` requires `ADMIN`; everything else is `permitAll()` except `/reserve/info`. CSRF is currently disabled project-wide.

**Domain model** (`sql/schema.sql`): `Users` (customer/owner/admin) own `Salons`, which have `Services`, `Stylists`, `Stylist_Schedules`, `Salon_Operating_Hours`. `Reservations` tie a user+salon+stylist+service together and drive `Reviews` and `Payments` (1:1 with a reservation). Separately there's a lightweight community (`Posts`/`Comments`), 1:1 `Chats`/`Messages`, `Wishlists`, and salon `Promotions`. Most of these tables already have a matching `vo/` class, but only `User*` (controller/service/mapper) is implemented end-to-end so far — the rest are data-model scaffolding for features not yet built.

**Validation**: `Validator` implementations (e.g. `UserValidator`) are wired per-form via `@InitBinder("<modelAttributeName>")` in the controller, and gate on the model attribute name inside `validate()` (e.g. only runs for `joinUser`/`updateMember`). When adding a new form-backed validator, follow this same gate pattern rather than validating every object of that type unconditionally.

## Conventions to prevent past mistakes recurring

- **Auth/role checks belong only in `SecurityConfig.filterChain()`'s `authorizeHttpRequests`.** Do not add manual session/role checks inside controllers (e.g. `if (session.getAttribute(...) == null) redirect...`). Scattering auth logic per-controller is how a previous project ended up with inconsistent, duplicated login verification across pages — when a new URL needs protection, add one more `.requestMatchers(...)` rule here instead.
- **There is no error/404 handling yet** (no `<error-page>` in `web.xml`, no `@ControllerAdvice`). When adding it, centralize it in one place rather than having each controller/page redirect to its own ad hoc error view with its own message — that inconsistency (different message/look per page) is a known past failure mode to avoid.
- **Keep external resource loading (CDN vs local) consistent across pages.** `join.jsp` and `login.jsp` both load Font Awesome from the same cdnjs CDN and share `common.css`/`auth.css` from `resources/css/`; new JSPs should follow the same pattern rather than mixing CDN-loaded and locally-vendored versions of the same asset.
- **CSS lives in `src/main/webapp/resources/css/` — that is the one canonical stylesheet set the running app loads** (`common.css` = design tokens in `:root` + shared utilities, then role/page CSS: `auth.css`/`admin.css`/`owner.css`/`user.css`). Put shared design tokens (colors, radius, shadow) in `common.css`'s `:root` and reference them via `var(--…)`; do not hardcode hex values inline in JSP. For form-validation error messages use the `.error-text` class (and `.input-error` on the offending field) rather than inline `style="color:…"`.
- **No CSS framework** (no Bootstrap/Tailwind) — styles are hand-written. `styles/modern-common.css` at the repo root is a **kept-for-reference** all-in-one design system (sidebar/navbar/cards/inputs) for future logged-in *dashboard* pages; it is intentionally not wired into any JSP yet. When building 마이페이지/점주센터/관리자 shells, harvest its component patterns into `resources/css/` rather than linking it directly.

## Feature progress notes

Per-feature "what's done / what's next" status lives outside this file since it changes fast — see `docs/login-todo.md` for the login/registration feature (`feature/auth` branch). Other features don't have an equivalent doc yet; add one per feature branch as needed rather than tracking status here.

## Frontend notes

- `src/main/webapp/WEB-INF/views/` holds the live JSPs actually rendered by the app.
- `html/` at the repo root holds standalone HTML mockups (split by role: 일반/점주/관리자/로그인-가입) used as design references — these are **not** wired into the Spring app and should not be treated as the current UI state.
