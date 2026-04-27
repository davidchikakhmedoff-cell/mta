# SMS Activation Reseller Platform

Production-oriented reseller platform for virtual number activations and SMS retrieval.

## Architecture

- **Backend**: Node.js + Express with clean modules (controllers/services/repositories/adapters)
- **Database**: PostgreSQL with Prisma ORM
- **Frontend**: React + Vite
- **Auth**: JWT + bcrypt
- **Payments**: webhook-based deposit handling
- **Deployment**: Docker + Docker Compose

## Monorepo Layout

- `backend/` API, provider orchestration, polling worker
- `frontend/` user/admin dashboard
- `docker-compose.yml` local deployment stack

## Quick Start

```bash
cp backend/.env.example backend/.env
cd backend && npm install && npx prisma migrate dev && npm run dev
cd ../frontend && npm install && npm run dev
```

Or run everything with Docker:

```bash
docker compose up --build
```

## Core API Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `GET /balance`
- `POST /order/create`
- `GET /order/status`
- `POST /order/cancel`
- `GET /providers`
- `POST /webhook/payment`
- `GET /admin/*` and `PATCH /admin/*` for administration

More details: `backend/src/docs/api.md`.

## Order Flow

1. User requests activation (`service`, `country`)
2. System validates balance
3. Provider router tries enabled providers by priority
4. Partner allocation is created
5. Order is persisted and user balance is charged
6. Polling job checks SMS status periodically
7. SMS message is saved and order marked received
8. Cancel path triggers partner cancellation and refund

## Security Controls

- Rate limiting on API routes
- Helmet + CORS hardening
- Zod input validation
- JWT auth middleware
- Password hashing with bcrypt
- Provider API timeout + retry wrappers
- Centralized error handler and request logging
