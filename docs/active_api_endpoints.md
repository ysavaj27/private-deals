# Active API endpoints (app)

Endpoints currently called from the Flutter app (live `Class.method` call sites).

Base: `/api`

Auth: header `headtoken`; after login also `Authorization: Bearer <token>`.

## Auth / profile

- GET /api/v1/business/profile
- GET /api/v2/business/profile
- POST /api/v1/business/changepassword
- POST /api/v1/business/delete-account
- POST /api/v1/business/forgot-password
- POST /api/v1/business/forgot-password/resend-otp
- POST /api/v1/business/forgot-password/verify-otp
- POST /api/v1/business/login
- POST /api/v1/business/logout
- POST /api/v1/business/profile
- POST /api/v2/business/profile
- POST /api/v1/business/forgot-password/change-password

## Master / config

- GET /api/get-config
  - `enum.document_type` is the client document-type filter only (no SSA/PAN/Aadhaar/cheque).
  - App does not read removed keys: `secondary_banners`, `preipo_banners`, `app_version`, `build`, `app_tutorial_video`, `investment_process`, `calendly_url`.
- GET /api/master/get-blog
- GET /api/master/get-sector

## Catalog / landing

- GET /api/v1/business/get-startup-lite
- GET /api/v1/get-home
- GET /api/v2/business/company/detail
- GET /api/v2/business/company/list
- GET /api/v2/business/home/secondary
- GET /api/v2/business/startup/detail
- GET /api/v2/business/startup/list

## Dashboard

- GET /api/v1/business/dashboard

## Portfolio

- GET /api/v1/business/company-startup-list
- GET /api/v2/business/portfolio/startup
- POST /api/v2/business/portfolio/upload

## Channel partners

- GET /api/v1/business/relation-manager
- GET /api/v2/business/channel-partner
- POST /api/v2/business/channel-partner

## Investors / KYC / CML

- GET /api/v2/business/investor
- GET /api/v2/business/investor/detail
- POST /api/v1/business/investor-kyc
- POST /api/v1/business/investor/update
- POST /api/v2/business/investor

## Primary

- GET /api/v1/business/primary-invest/transaction
- GET /api/v1/business/primary-transactions

## Pre-IPO

- GET /api/v1/business/dashboard-pre-ipo
- GET /api/v2/business/common/preipo-news
- GET /api/v2/business/home/pre-ipo
- GET /api/v2/business/home/pre-ipo/news-sectors
- GET /api/v2/business/portfolio/pre-ipo
- GET /api/v2/business/pre-ipo/transaction-list
- POST /api/v1/business/pre-ipo/sell
- POST /api/v2/business/pre-ipo/buy
- POST /api/v2/business/pre-ipo/transaction/confirm-payment
- POST /api/v2/business/pre-ipo/transaction/confirm-share-transfer
- POST /api/v2/business/pre-ipo/transaction/share-transfer-receipt

## Enquiries

- GET /api/v2/business/enquiries/deals
- POST /api/v2/business/enquiries/deals
- POST /api/v2/business/enquiries/deals/accept
- POST /api/v2/business/enquiries/deals/accept-counterparty
- POST /api/v2/business/enquiries/deals/quotes/accept
- POST /api/v2/business/enquiries/deals/reject
- POST /api/v2/business/enquiries/deals/withdraw
- GET /api/v2/business/institution/enquiries
- POST /api/v2/business/institution/enquiries/accept
- POST /api/v2/business/institution/enquiries/quote
- POST /api/v2/business/institution/enquiries/quote/withdraw
- POST /api/v2/business/institution/enquiries/reject

## Ops (earnings/MIS/tasks/docs/notif)

- GET /api/v1/business/earning/partner
- GET /api/v2/business/earning/investor
- GET /api/v1/business/invested-startup-mis
- GET /api/v1/business/notifications
- GET /api/v2/business/pending-tasks
- GET /api/v2/business/documents
- GET /api/v2/business/documents/download
- POST /api/v2/business/documents/send

## Institution

- GET /api/v2/business/institution/company/deals
- GET /api/v2/business/institution/company/detail
- GET /api/v2/business/institution/company/list
- GET /api/v2/business/institution/company/list-lite
- GET /api/v2/business/institution/company/my-submissions
- GET /api/v2/business/institution/company/sectors
- GET /api/v2/business/institution/pre-ipo/transaction
- GET /api/v2/business/institution/pre-ipo/transaction/detail
- GET /api/v2/business/institution/profile
- POST /api/v2/business/institution/company
- POST /api/v2/business/institution/company/check-duplicate
- POST /api/v2/business/institution/company/deals
- POST /api/v2/business/institution/company/deals/bulk
- POST /api/v2/business/institution/company/deals/delete
- POST /api/v2/business/institution/company/deals/update
- POST /api/v2/business/institution/company/prices/excel
- POST /api/v2/business/institution/company/promoters
- POST /api/v2/business/institution/company/shareholders
- POST /api/v2/business/institution/pre-ipo/transaction/approve
- POST /api/v2/business/institution/pre-ipo/transaction/confirm-payment
- POST /api/v2/business/institution/pre-ipo/transaction/confirm-share-transfer
- POST /api/v2/business/institution/pre-ipo/transaction/payment-receipt
- POST /api/v2/business/institution/pre-ipo/transaction/reject
- POST /api/v2/business/institution/profile

## Investor leftovers (still called from WM UI)

- GET /api/v1/investor/company-startup-list
- POST /api/v1/investor/pitch
- POST /api/v1/investor/secondary-invest/sell-now
- POST /api/v1/investor/primary-invest/upload-payment-receipt
