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
  - Run mobile app (emulator):
    - `cd mobile-app && flutter pub get && flutter run` (use `http://10.0.2.2:8000` for Android emulator).

- Important conventions and guardrails discovered in code:
  - Strict settings: backend uses Pydantic `BaseSettings` with strict validation; startup fails if `DATABASE_URL` or `SECRET_KEY` are missing or invalid. Always ensure these are set before running.
  - SECRET_KEY policy: generate a strong key (>=32 chars). Helper: `python -c "import secrets; print(secrets.token_urlsafe(32))"`.
  - DB migrations: production schema changes MUST use Alembic (do not call `create_all()` in production). Tests/dev may create tables automatically.
  - API structure: routes under `backend/api/v1/endpoints/` (auth, users, measurements). Use routers aggregated in `backend/api/v1/api.py`.
  - Rate limiting: optional but enabled if Redis is available; code in `backend/main.py` will try to init `FastAPILimiter` from `REDIS_URL`.

- Integration points & environment variables (look here):
  - `backend/.env.example` — required env vars and templates.
  - `AI_SERVICE_URL` — backend → AI model service URL (default `http://ai-models:8000`).
  - `REDIS_URL` — enabling rate limiting.
  - `DATABASE_URL`, `SECRET_KEY`, `ENVIRONMENT` — control runtime behavior and security.

- Project-specific patterns to follow when changing code:
  - Keep `backend/` self-contained: tests use `PYTHONPATH=backend` and expect imports relative to that package.
  - Use Pydantic schemas for request/response validation and SQLAlchemy models for persistence (see `backend/models/` and `backend/schemas/`).
  - Business logic should live in `backend/services/` rather than in endpoint handlers.
  - For admin UI API calls, follow `admin-portal/lib/api/*` patterns (Axios client, interceptors, centralized base URL).
  - Mobile app expects host addresses per platform (`10.0.2.2` for Android emulator); update `mobile-app/lib/utils/app_config.dart` when testing on device.

- Examples (quick references):
  - Health check: `GET http://localhost:8000/health` (see `backend/main.py`).
  - Auth endpoints: `POST /api/v1/auth/login` and `POST /api/v1/auth/register` (see `backend/api/v1/endpoints/auth.py`).
  - Run full test suite (root): `scripts/run_tests_with_db.sh` or run `pytest backend/tests/` with a configured `DATABASE_URL`.

- Editing & PR guidance for AI agents:
  - Small, focused changes only. Match existing module patterns (services → endpoints → schemas → models).
  - Run `scripts/run_tests_with_db.sh` for backend changes that touch DB or Alembic migrations.
  - If adding env vars, update `backend/.env.example` and document default behavior in `backend/README.md`.
  - Do not remove or weaken `SECRET_KEY` validation; surface errors occur early in config validation.

If any of these sections look incomplete or you want more detail about any area (for example particular endpoints, test conventions, or CI workflow), tell me which area to expand and I will iterate.

---

**توسيع: تفاصيل CI وبيئة الاختبار (موجز عربي)**

فيما يلي تفاصيل عملية CI الحالية وملاحظات عملية للمساعدة في استكشاف الأخطاء وإصلاحها، مستمدة مباشرة من ملفات سير العمل في `.github/workflows/` و`docker-compose.yml`.

- **(أ) تسلسل تنفيذ CI Smoke E2E - Measurements** (`.github/workflows/ci-smoke-measurements.yml`):
  - Checkout الكود ثم تثبيت أدوات مساعدة بسيطة (`jq`, `curl`).
  - تشغيل Docker Compose عبر الأمر `docker compose up --build -d` مع حقن متغير `SECRET_KEY` من أسرار GitHub Actions (`secrets.CI_SECRET_KEY`). هذا يشغل الخدمات المعرفة في `docker-compose.yml` (backend, postgres, redis, ai-models, ...).
  - انتظار صحة الـ backend: حلقة تحقق من `GET http://localhost:8000/health` (حاول حتى 40 مرة مع تأخير 3 ثواني).
  - تنفيذ اختبار الـ smoke: يقوم السيناريو بإنشاء صورة صغيرة (1x1 PNG) ثم:
    - تسجيل مستخدم تجريبي (`/api/v1/auth/register`) ثم تسجيل الدخول للحصول على توكن JWT.
    - POST إلى `/api/v1/measurements/process` مع الصور وحقول `height` و`weight`، ثم التحقق من وجود مفاتيح `measurements` و`confidence_score` ونجاح الاستجابة (HTTP 200).
    - إجراء تحديث للقياسات عبر `PUT /api/v1/measurements/{id}` ثم حذف القياس والتحقق من السلوك المتوقّع (DELETE => 204, GET بعد الحذف => 404).
    - سيناريو سلبي: إرسال حقل `force_error=error` ليتوقّع إرجاع 500 من السيرفر عندما تعود خدمة AI بحالة فاشلة.
  - تحقق استمرارية الحفظ في DB داخل الحاوية بواسطة الأمر:
    - `docker compose exec -T backend bash -lc "export TEST_EMAIL='${TEST_EMAIL}'; python /workspaces/Qeyafa/backend/ci/check_db.py"`
  - في النهاية يتم إيقاف حاويات الـ compose باستخدام `docker compose down -v` (يتم دائماً تنفيذها عبر `if: always()` لتضمن التنظيف).

- **(ب) ملاحظات حول `docker-compose.ci.yml` وملفات Compose في CI**
  - المخرجات الحالية: المشروع لا يحتوي على ملف `docker-compose.ci.yml` مضمّن. سير العمل يستخدم ببساطة `docker compose up --build -d` فافتراضياً يقرأ `docker-compose.yml` في المستودع.
  - متطلبات شائعة عند بناء ملف Compose مخصص للـ CI:
    - حقن متغيرات البيئة الحساسة عبر GitHub Secrets: `SECRET_KEY`, `DATABASE_URL` (إن لزم), `AI_SERVICE_URL`, `REDIS_URL`.
    - استخدم خرائط `volumes` واضحة لالتقاط الملفات التي تريد جمعها (مثل مجلد التحميلات `./backend/uploads` أو مجلدات السجلات). مثال حجم لالتقاط الصور والـ uploads:
      - في `docker-compose.yml` الحالي: `volumes:\n      - ./backend:/app\n      - upload-data:/app/uploads` → في بيئة runner هذه ستنعكس الملفات ضمن المسار النسبي في workspace أو في حجم Docker المسمى `upload-data`.
    - إذا تبيّن أن السجلات لا تظهر في artefact، فالأسباب الشائعة: السجلات تُكتب داخل حجم Docker غير مربوط بمجلد على المضيف، أو تم ضغط/حذف الملفات قبل جمعها، أو أن `docker compose logs` لم يُدخَر.
  - مثال بسيط لكيفية إنشاء `docker-compose.ci.yml` ديناميكياً (في خطوة Workflow) عبر heredoc: 
    - ضع الملف في وقت التشغيل وتمرّر متغيرات البيئة من Secrets ثم شغّل `docker compose -f docker-compose.ci.yml up --build -d`.

- **(ج) آليات جمع السجلات الموصى بها (ci-logs.tar.gz)**
  - لا يوجد سكربت جاهز لجمع السجلات في المستودع. خطوات موثوقة لجمع السجلات في GitHub Actions:
    1. قبل `docker compose down`, اجمع سجلات الحاويات بصيغة زمنية وبدون ألوان:
       - `docker compose logs --no-color --timestamps backend > backend.logs.txt`
       - `docker compose logs --no-color --timestamps ai-models > ai-models.logs.txt`
       - `docker compose logs --no-color --timestamps postgres > postgres.logs.txt`
    2. انسخ الملفات الموجودة داخل الحاوية إن احتجت للسجلات التي تُكتب إلى ملفات داخل الحاوية (مثال):
       - `docker compose exec -T backend bash -lc 'cp /app/backend/alembic.log /tmp/alembic.log || true'`
       - ثم `docker compose cp backend:/tmp/alembic.log ./alembic.log || true`
    3. اجمع مجلدات التحميلات/النسخ التي تحتاجها (مثل `backend/uploads`):
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
