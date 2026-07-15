# Falcon View Car Rentals

A production-quality luxury car rental platform for the UAE market, built as a monorepo.

## Monorepo Structure

```
CarRental/
├── apps/
│   ├── backend/          # FastAPI Python backend (REST API)
│   └── web/              # React 19 + Vite frontend
├── apps/data/
│   └── sqlite/           # SQLite database (local dev only)
├── infrastructure/
│   ├── docker/           # docker-compose for local development
│   └── nginx/            # Nginx reverse proxy configuration
└── docs/                 # Deployment and architecture documentation
```

## Quickstart

### Prerequisites

- Python 3.11+
- Node.js 20+
- pip / npm

### Backend

```bash
cd apps/backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate        # Linux/Mac
# .\venv\Scripts\Activate.ps1   # Windows PowerShell

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env and fill in your values

# Seed the database (first time only)
python seed_auth.py
python seed_memberships.py

# Start the development server
uvicorn app.main:app --reload
```

API docs available at: http://localhost:8000/docs

### Frontend

```bash
cd apps/web

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local and fill in your values

# Start the development server
npm run dev
```

Frontend available at: http://localhost:5173

## Deployment

See [docs/AZURE_DEPLOYMENT.md](docs/AZURE_DEPLOYMENT.md) for full Azure deployment instructions.

### Quick Reference

| Service | Platform | Notes |
|---------|----------|-------|
| Backend | Azure App Service (Python 3.11) | Startup: `uvicorn app.main:app --host 0.0.0.0 --port 8000` |
| Frontend | Azure Static Web Apps | Build: `npm run build`, Output: `dist/` |
| Database | SQLite (dev) / Azure PostgreSQL (prod) | See `AZURE_DEPLOYMENT.md` for PostgreSQL migration |

## Environment Variables

- Backend: copy `apps/backend/.env.example` → `apps/backend/.env`
- Frontend: copy `apps/web/.env.example` → `apps/web/.env.local`

**Never commit populated `.env` files to source control.**
