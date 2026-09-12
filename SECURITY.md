# Security

## Reporting a vulnerability

Email hello@notifi.it. Do not open a public issue.

Include the steps to reproduce, the component (app, Worker or contract) and the
version or commit you tested against. You will get a reply within three days,
and a fix or a stated reason there will be none within thirty.

## Scope

- `apps/api` — the Cloudflare Worker at notifi.it, its D1 schema and migrations
- `apps/app` — the iOS and macOS apps, including the notification service extensions
- `packages/contract` — the request and response schemas both sides validate against

The design assumes the server cannot read notification content: it is sealed to
the device's public key at ingest and deleted once the device acknowledges it. A
report showing the server, an operator or Apple can recover content, or that a
send key lets anyone read another device's inbox, is the highest severity.

Out of scope: volume-based denial of service, findings that need a compromised
device or a jailbroken OS, and issues in Cloudflare or APNs themselves.

## Supported versions

Only the latest release on each channel (App Store, TestFlight, DMG) receives
fixes. Fixes ship as a new release; there are no backports.

## Disclosure

The fix ships first, then the release notes describe the issue. Reporters are
credited in those notes if they want to be.
