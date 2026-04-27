# SMS Reseller API

## Auth
- `POST /auth/register` -> `{ email, password }`
- `POST /auth/login` -> `{ email, password }`

## User
- `GET /balance` (Bearer token)
- `POST /order/create` -> `{ service, country }`
- `GET /order/status?orderId=<uuid>`
- `POST /order/cancel` -> `{ orderId }`
- `GET /providers`

## Payments
- `POST /webhook/payment` -> `{ userId, amount, reference, signature }`

## Admin (Bearer token with admin role)
- `GET /admin/users`
- `PATCH /admin/users/:userId/block`
- `PATCH /admin/users/:userId/balance` -> `{ amount }`
- `GET /admin/orders`
- `GET /admin/providers`
- `PATCH /admin/providers/:providerId` -> `{ status?, priority? }`
