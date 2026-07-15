# Ruby Store

A small sample storefront demonstrating how to integrate the [`paystack-ruby`](https://github.com/PaystackOSS/paystack-ruby) gem in a Rails app: initializing a hosted-checkout transaction, verifying it on redirect, and confirming it via a signed webhook.

## Stack

Rails 8.1, Ruby 3.4.9, SQLite, Propshaft, importmap/Turbo/Stimulus (no Node/JS build step), Minitest.

## Setup

```bash
bundle install
cp .env.example .env       # then fill in your Paystack TEST keys, see below
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Visit `http://localhost:3000`.

## Payments (Paystack)

### 1. Get test API keys

Sign up / log in at the [Paystack dashboard](https://dashboard.paystack.com), switch to **Test Mode**, and grab your test secret key from Settings → API Keys & Webhooks. Put it in `.env`:

```
PAYSTACK_SECRET_KEY=sk_test_...
```

### 2. Make a test purchase

Click "Buy Now" on any product, enter an email, and complete checkout on Paystack's hosted payment page. For test payments see Paystack's [Test Payments docs](https://paystack.com/docs/payments/test-payments/).

After paying, Paystack redirects back to `/orders/callback`, which verifies the transaction and shows a success or failure page.

### 3. Test the webhook locally

The redirect callback above confirms payment for the browser, but the webhook (`POST /webhooks/paystack`) is the recommended, production-correct way to confirm payment — Paystack sends it independently of whether the customer's browser makes it back to your app.

To receive it locally:

1. Start an HTTP tunnel to your local server, e.g. `ngrok http 3000`.
2. In the Paystack dashboard (Test Mode) under Settings → API Keys & Webhooks, set the webhook URL to `https://<your-ngrok-subdomain>.ngrok.io/webhooks/paystack`.
3. Make another test purchase. Your server logs should show a `200` response from `PaystackWebhooksController`, and the order's `paid_at` should already be set from the callback (the webhook is a no-op the second time, by design — see `Order#mark_paid!`).

## Running tests

```bash
bin/rails test
```
