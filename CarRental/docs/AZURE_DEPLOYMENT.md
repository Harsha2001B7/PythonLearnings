# Azure Deployment Guide — Falcon View Car Rentals

This guide covers deploying the Falcon View Car Rentals platform to Microsoft Azure.

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                    Azure                            │
│                                                     │
│  ┌──────────────────────┐  ┌──────────────────────┐ │
│  │  Azure Static Web    │  │  Azure App Service   │ │
│  │  Apps (Frontend)     │  │  (Backend FastAPI)   │ │
│  │                      │  │                      │ │
│  │  React + Vite build  │  │  Python 3.11         │ │
│  │  Global CDN          │  │  uvicorn             │ │
│  └──────────────────────┘  └──────────────────────┘ │
│                                      │              │
│                             ┌────────┴──────┐       │
│                             │   SQLite DB   │       │
│                             │  (dev only)   │       │
│                             │               │       │
│                             │  Azure        │       │
│                             │  PostgreSQL   │       │
│                             │  (production) │       │
│                             └───────────────┘       │
└─────────────────────────────────────────────────────┘
```

---

## 1. Backend — Azure App Service

### Create App Service

1. In Azure Portal: **Create a resource → App Service**
2. Settings:
   - **Runtime stack**: Python 3.11
   - **OS**: Linux
   - **SKU**: B2 or higher recommended

### Environment Variables

Set these in **App Service → Configuration → Application settings**:

| Variable | Description | Required |
|----------|-------------|----------|
| `ENVIRONMENT` | `production` | ✅ |
| `SECRET_KEY` | Random 32-byte hex string | ✅ |
| `GOOGLE_CLIENT_ID` | Google OAuth Client ID | ✅ |
| `GOOGLE_CLIENT_SECRET` | Google OAuth Client Secret | ✅ |
| `FRONTEND_URL` | Azure Static Web Apps URL | ✅ |
| `BACKEND_URL` | This App Service URL | ✅ |
| `BACKEND_CORS_ORIGINS` | JSON array of allowed origins | ✅ |
| `DATABASE_URI` | PostgreSQL connection string (see below) | ✅ |

#### Generate SECRET_KEY

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

#### BACKEND_CORS_ORIGINS format

```
["https://your-app.azurestaticapps.net"]
```

### Startup Command

In **App Service → Configuration → General settings → Startup Command**:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 1
```

### Deploy via GitHub Actions

1. In App Service → Deployment Center → GitHub
2. Select your repository and branch
3. Azure will generate a GitHub Actions workflow automatically

Sample workflow (`.github/workflows/backend.yml`):

```yaml
name: Deploy Backend

on:
  push:
    branches: [main]
    paths:
      - 'apps/backend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install -r apps/backend/requirements.txt
      - name: Deploy to Azure App Service
        uses: azure/webapps-deploy@v3
        with:
          app-name: ${{ secrets.AZURE_APP_SERVICE_NAME }}
          publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE }}
          package: apps/backend
```

---

## 2. Frontend — Azure Static Web Apps

### Create Static Web App

1. In Azure Portal: **Create a resource → Static Web App**
2. Connect to your GitHub repository
3. Build settings:
   - **App location**: `apps/web`
   - **Build command**: `npm run build`
   - **Output location**: `dist`

### Environment Variables

Static Web Apps environment variables are set in **Configuration → Application settings** in Azure Portal. They are **not** baked into the build — use GitHub Actions secrets for build-time variables.

Add to your GitHub Actions secrets:
- `VITE_API_URL` = `https://YOUR_APP.azurewebsites.net/api/v1`
- `VITE_GOOGLE_CLIENT_ID` = your Google Client ID

Sample workflow (`.github/workflows/frontend.yml`):

```yaml
name: Deploy Frontend

on:
  push:
    branches: [main]
    paths:
      - 'apps/web/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install and Build
        run: |
          cd apps/web
          npm ci
          npm run build
        env:
          VITE_API_URL: ${{ secrets.VITE_API_URL }}
          VITE_GOOGLE_CLIENT_ID: ${{ secrets.VITE_GOOGLE_CLIENT_ID }}
      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: upload
          app_location: apps/web
          output_location: dist
```

### SPA Routing

The `apps/web/staticwebapp.config.json` file is already configured to handle SPA routing (all routes fall back to `index.html`).

---

## 3. Database Migration — SQLite → Azure PostgreSQL

The app currently uses SQLite for local development. For production on Azure, migrate to **Azure Database for PostgreSQL**.

### Step 1: Create Azure PostgreSQL

1. Azure Portal → **Create a resource → Azure Database for PostgreSQL**
2. Choose **Flexible Server**
3. Note the connection details

### Step 2: Update requirements.txt

Add the PostgreSQL adapter:

```
psycopg2-binary==2.9.9
```

### Step 3: Update DATABASE_URI

Set the App Service environment variable:

```
DATABASE_URI=postgresql+psycopg2://USER:PASSWORD@HOST:5432/DBNAME?sslmode=require
```

### Step 4: Run Alembic migrations

```bash
cd apps/backend
alembic upgrade head
```

> [!NOTE]
> The current startup SQLite migration guard in `main.py` is automatically skipped for non-SQLite databases. When using PostgreSQL, use only Alembic for schema changes.

---

## 4. Google OAuth Configuration

Add the production domain to **Google Cloud Console → APIs & Services → Credentials → OAuth 2.0 Client**:

- **Authorised JavaScript origins**: `https://YOUR_APP.azurestaticapps.net`
- **Authorised redirect URIs**: `https://YOUR_APP.azurestaticapps.net/login`

---

## 5. Health Check

The backend exposes a health endpoint at `/health`:

```
GET https://YOUR_APP.azurewebsites.net/health
→ {"status": "ok", "service": "FalconViewCarRentals", "environment": "production"}
```

Configure this in **App Service → Health check** for automatic instance replacement on failure.

---

## 6. Custom Domain & HTTPS

Azure App Service and Static Web Apps both support custom domains with free managed TLS certificates.

1. Go to **Custom domains** in each service
2. Add your domain (e.g., `api.falconviewcarrentals.com` for backend, `falconviewcarrentals.com` for frontend)
3. Enable **HTTPS Only** on App Service

---

## 7. Production Checklist

- [ ] `SECRET_KEY` set to a strong random value
- [ ] `ENVIRONMENT=production` set on App Service
- [ ] All secrets set as App Service Application Settings (not committed to code)
- [ ] `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` set
- [ ] Google OAuth origins updated with production URL
- [ ] CORS configured to allow only the production frontend URL
- [ ] Health check endpoint working
- [ ] HTTPS enforced on both services
- [ ] Database migrated to Azure PostgreSQL (recommended)
- [ ] Custom domain configured
- [ ] Azure Application Insights configured for monitoring (optional)
