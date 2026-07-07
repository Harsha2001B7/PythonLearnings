# Luxury UAE Car Rental Platform

A production-quality monorepo foundation for a luxury car rental platform targeted at the UAE market.

## Monorepo Structure

- `apps/backend`: FastAPI application providing the API.
- `apps/web`: React 19 web application for the premium user experience.
- `apps/mobile`: Flutter mobile application.
- `apps/admin`: Placeholder for future admin dashboard.
- `packages/`: Shared packages like UI components, types, and utilities.
- `infrastructure/`: Docker and Nginx configurations.

## Quickstart

### Backend
1. Navigate to `apps/backend`
2. Run `uvicorn app.main:app --reload` (requires Python & FastAPI installed).

### Web
1. Navigate to `apps/web`
2. Run `npm install`
3. Run `npm run dev`

### Mobile
1. Navigate to `apps/mobile`
2. Run `flutter pub get`
3. Run `flutter run`
