<!-- Copied together from repository READMEs and code inspection. Keep concise. -->
# Copilot Instructions — Qeyafa

Purpose: give AI coding agents the minimal, actionable knowledge to be productive in this repository.

- Project layout (where to look):
  - `backend/` — Primary FastAPI backend. Key files: `backend/main.py`, `backend/core/config.py`, `backend/api/v1/api.py`, `backend/requirements.txt`, `backend/tests/`.
  - `admin-portal/` — Next.js 14 admin UI (App Router). API layer in `admin-portal/lib/api/`, env in `.env.local`.
  - `mobile-app/` — Flutter mobile client. Entry: `mobile-app/lib/main.dart`, API config in `mobile-app/lib/utils/app_config.dart` and `mobile-app/lib/services/api_service.dart`.
  - `ai-models/` — Measurement model service (Flask/ML). API in `ai-models/measurement_model/api.py`.
  - `docker-compose.yml` — orchestrates backend, DB, ai-models, and other services for local development.

- Big-picture architecture and data flow (concise):
  - The canonical backend is the FastAPI app under `backend/` exposing `API_V1_PREFIX` (see `backend/core/config.py`).
  - Frontends (admin Next.js and Flutter mobile) call the FastAPI backend at `/api/v1/...`.
  - AI model service (`ai-models`) is a separate HTTP service; backend integrates via `AI_SERVICE_URL` (env var, default `http://ai-models:8000`).
  - Persistence: PostgreSQL (configured via `DATABASE_URL`), migrations via Alembic. Tests and CI spin up ephemeral Postgres instances.
  - Rate limiting uses Redis + `fastapi-limiter` — controlled by `REDIS_URL` (see `backend/main.py` lifespan setup).

- Concrete developer workflows (commands you can run):
  - Start full stack locally (recommended):
    - `docker compose up --build -d` (runs backend, postgres, redis, ai-models, admin container if defined).
  - Run backend locally (no Docker):
    - `python -m venv .venv && source .venv/bin/activate`
    - `pip install -r backend/requirements.txt`
    - copy `.env.example` → `.env` and set `DATABASE_URL`, `SECRET_KEY` (must be >=32 chars)
    - `uvicorn backend.main:app --reload --port 8000`
  - Run tests with ephemeral Postgres (helper):
    - `scripts/run_tests_with_db.sh` (it exports `DATABASE_URL`, generates a strong `SECRET_KEY`, runs `pytest` with `PYTHONPATH=backend`).
  - Run admin portal locally:
    - `cd admin-portal && npm install && npm run dev` (set `NEXT_PUBLIC_API_BASE_URL` to `http://localhost:8000`).
  <!-- Concise Copilot / AI-agent guidance for Qeyafa -->
  # Copilot Instructions — Qeyafa (Concise)

  Purpose: give AI coding agents only the repository-specific facts needed to be productive.

  - Project layout (where to look):
    - `backend/` — FastAPI app (entry `backend/main.py`, config `backend/core/config.py`, routers under `backend/api/v1/`).
    - `ai-models/` — separate Flask ML service (API: `ai-models/measurement_model/api.py`, `AI_SERVICE_URL` env).
    - `admin-portal/` — Next.js 14 admin UI (API wrappers in `admin-portal/lib/api/`).
    - `mobile-app/` — Flutter client (`mobile-app/lib/*`) — uses platform-specific host overrides (Android `10.0.2.2`).
    - `docker-compose.yml` — recommended local dev: brings up backend, postgres, redis, ai-models.

  - Quick start commands (most common):
    - Full stack: `docker compose up --build -d` then `GET http://localhost:8000/health`.
    - Backend without Docker: `python -m venv .venv && source .venv/bin/activate && pip install -r backend/requirements.txt && cp backend/.env.example backend/.env && set required envs && uvicorn backend.main:app --reload --port 8000`.
    - Run backend tests (CI helper): `scripts/run_tests_with_db.sh` (sets `PYTHONPATH=backend`, generates `SECRET_KEY`, runs pytest).

  - Key environment and guardrails (do not change silently):
    - `DATABASE_URL`, `SECRET_KEY` (>=32 chars), `AI_SERVICE_URL`, `REDIS_URL` are authoritative — `backend/pydantic_settings.py` enforces them at startup.
    - Migrations: use Alembic (`backend/alembic.ini`, `backend/alembic/env.py`). Do not rely on `create_all()` in production.

  - Code conventions specific to this repo:
    - Keep business logic in `backend/services/`; endpoints in `backend/api/v1/endpoints/`; schemas in `backend/schemas/`; models in `backend/models/`.
    - Tests and CI run with `PYTHONPATH=backend` — imports like `from core.config import settings` depend on that layout.
    - Admin API client patterns live in `admin-portal/lib/api/` (Axios wrappers, central base URL).

  - Important files to inspect for context:
    - `backend/main.py` — app startup, rate-limiter init, health route.
    - `backend/core/config.py` (or `backend/pydantic_settings.py`) — all env/settings and defaults.
    - `backend/api/v1/api.py` and `backend/api/v1/endpoints/*` — route organization.
    - `ai-models/measurement_model/api.py` — expected AI service endpoints and failure modes used in CI smoke tests.

  - CI & debug tips (practical):
    - CI uses `docker compose up --build -d` and probes `/health` (see `.github/workflows/`).
    - To collect logs in CI: `docker compose logs --no-color --timestamps backend > backend.logs.txt` and `docker compose cp backend:/app/uploads ./uploads || true`.
    - If you see import errors in CI, verify `PYTHONPATH=backend` or run from inside `backend/`.

  - Short editing & PR rules for agents:
    - Make small, focused changes; follow services→endpoints→schemas→models layering.
    - If code touches DB schema, provide Alembic migration and update `backend/.env.example` if new envs are required.
    - Never weaken `SECRET_KEY` validation or remove strict Pydantic checks — these are intentional guardrails.

  If you'd like, I can: (1) shorten or expand any section, (2) add common example requests for `measurements` endpoints, or (3) generate a small checklist for creating PRs that change DB models. Which would you prefer? 
       - إن كان `upload-data` مرفقاً كمجلد Host (مثل `./backend/uploads`)، تأكد من نسخه: `tar -czf ci-uploads.tar.gz backend/uploads || true`.
       - وإلا استخدم `docker compose cp backend:/app/uploads ./ci-uploads || true`.
    4. أنشئ tar شامل للـ artifacts:
       - `tar -czf ci-logs.tar.gz backend.logs.txt ai-models.logs.txt postgres.logs.txt alembic.log ci-uploads.tar.gz || true`
    5. ارفق `ci-logs.tar.gz` كـ artifact في خطوة Action (`actions/upload-artifact@v4`).

  - نقاط تحقق للتأكد من أن الملفات مشمولة:
    - تأكد أن الحاوية تكتب فعلاً إلى المسارات التي تجمعها (راجع `UPLOAD_DIR` في `backend/api/v1/endpoints/measurements.py` — القيمة الافتراضية هي `/workspaces/Qeyafa/backend/uploads`).
    - إذا كان `docker-compose.yml` يستخدم حجمًا مملوكًا باسم (`upload-data`) وليس مساراً على المضيف (`./backend/uploads`)، فاستخدم `docker compose cp` أو ربط الحجم إلى مسار مضيف أثناء تشغيل CI.

**هيكلة مشروع Backend و Database (موجز عربي)**

- **(أ) بنية حزم Python (PYTHONPATH والمناطق المهمة)**
  - جذر الحزمة للخدمات الخلفية هو المجلد `backend/`. ملفات الاختبارات والمشغلات في CI تعتمد على تشغيل `PYTHONPATH=backend` (انظر `.github/workflows/ci.yml` و `scripts/run_tests_with_db.sh`).
  - أمثلة لمسارات الاستيراد المتوقعة:
    - `from core.config import settings` → يشير إلى `backend/core/config.py` عند تشغيل مع `PYTHONPATH=backend`.
  - ملاحظة عملية: إذا ظهرت مشاكل `ModuleNotFoundError` في CI، تحقق أن `PYTHONPATH` مضبوط على مسار `backend` أو أن العملية تعمل من داخل `backend/` مع تثبيت الحزمة.

- **(ب) إعدادات Alembic**
  - موقع الملفات: `backend/alembic.ini` و `backend/alembic/env.py`.
  - كيفية اختيار `DATABASE_URL`: `env.py` يقوم باستيراد `settings` من `core.config` ثم `config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)` — لذلك Alembic يعتمد على نفس إعدادات التطبيق (بيئة Pydantic Settings).
  - في CI تأكد من أن البيئة تحتوي على `DATABASE_URL` قبل استدعاء `python -m alembic upgrade head` (انظر خطوة `Apply migrations` في `.github/workflows/ci.yml`).
  - سجلات Alembic: الإخراج الافتراضي يُطبع على stdout/stderr؛ إن أردت ملف لالتقاطه، قم بتوجيه الإخراج:
    - `python -m alembic upgrade head 2>&1 | tee alembic_migrate.log`

- **(ج) مخطط بيانات أساسي (جدولان رئيسيان وملاحظات العلاقة)**
  - `users` (`backend/models/user.py`):
    - الحقول الأساسية: `id` (UUID PK), `email` (unique), `hashed_password`, `first_name`, `last_name`, `is_active`, `is_superuser`, `role` (enum: admin, customer, designer, tailor), `created_at`.
  - `measurements` (`backend/models/measurement.py`):
    - الحقول الأساسية: `id` (UUID PK), `user_id` (FK → `users.id`), `measurements` (JSONB), `image_paths` (JSONB), `processed_at`, `confidence_score`.
    - علاقة: كل قياس مرتبط بمستخدم واحد (`user_id` foreign key). لا توجد علاقات معقدة أخرى مطلوبة للاختبارات الحالية للـ measurements.
  - جداول أخرى موجودة: `roles` enums وكيانات مثل `design`, `category`, `fabric`, `color` موجودة كنماذج لكن ليست حرجة لتشغيل اختبارات القياسات.

**خلاصة سريعة وإجراءات مقترحة**
- لتصحيح مشاكل السجلات: تحقق ما إذا كان `upload-data` مربوطًا إلى مجلد على المضيف أو إلى حجم Docker فقط — في الحالة الأخيرة، استخدم `docker compose cp` لاستخراج الملفات قبل `down`.
- للتأكد من Alembic في CI: تحقق من أن `DATABASE_URL` موجود في بيئة خطوة `Apply migrations` أو مرّرها صراحة إلى أمر Alembic.
- إذا واجهت أخطاء استيراد في CI: تأكد من ضبط `PYTHONPATH=backend` أو تشغيل الأوامر من داخل مجلد `backend`.

أخبرني أي قسم تريد توسيعه أكثر (أمثلة أو أوامر جاهزة للنسخ واللصق في Workflow)، وسأدرجه فورًا.
