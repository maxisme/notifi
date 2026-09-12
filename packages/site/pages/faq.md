---
path: /faq
eyebrow: FAQ
title: notifi: frequently asked questions
description: What notifi costs, its limits, what our server can read, and what happens when you delete the app.
ogDescription: What notifi costs, its limits, what our server can read, and what happens when you delete the app.
---
# Frequently asked questions

> What notifi costs, its limits, what our server can read, and what happens when you delete the app.

## The basics

### What is notifi?

A push-notification relay. One HTTP request to notifi.it and it’s on your iPhone or Mac. Nothing to install on the sending side, nothing to sign up for.

### What does it cost?

Nothing. The service is free and there is no paid tier.

### Do I need an account?

No. The app makes a keypair on first launch. That is your identity. No signup required.

### How do I send something?

One request, `GET` or `POST`, JSON or form-encoded:

```
curl -X POST https://notifi.it/send \
  -H "Authorization: Bearer $NOTIFI_KEY" \
  -d "title=Hello from notifi" \
  -d "message=Your first notification." \
  -d "link=https://notifi.it/docs" \
  -d "image=https://notifi.it/anaglyph-bell.png"
```

A successful send answers `202` with `{"ok":true}`. The key can also be passed as a `key` parameter, though the [note on query strings](/faq#logs) below applies if you do.

## Limits

### How much can I send?

- **60 sends an hour per device**, shared by every key on that device rather than counted per key. Over the limit answers `429` with a `Retry-After` header.
- **Five active send keys per device**, one of which is the app’s own device key.
- There is also a per-IP ceiling of 100 requests a minute on every endpoint.

### How long can a notification be?

- `title` — 1 to 200 characters, required.
- `message` — up to 16,000 characters.
- `link` and `image` — up to 2,048 characters.

A push payload has a 4,000-byte ceiling set by Apple, so a long notification is truncated in the banner and delivered in full to the app.

### Why did my send get a 401?

The key is unknown or revoked. Reinstalling the app or moving device makes a new identity and every old key stops working.

## Privacy and encryption

### Can you read my notifications?

No. Notifications are encrypted with your device’s public key before they are stored, and only your device can open them. See the [privacy policy](/privacy).

### What can the server see?

Sender and device IP addresses, your platform and app version, the time of every send and collection, the rough size of each notification, which key sent it and how often, and your push token. See the [privacy policy](/privacy).

### Is it safe to put the key in the URL?

It is the weaker option: a query string ends up in server logs. Ideally use an `Authorization: Bearer` header and a `POST` body. See the [docs](/docs).

### How long are notifications kept?

A notification is deleted as soon as your device confirms it has it. One your device never collects stays, encrypted, until it does — there is no time limit. Revoked send keys are kept forever, as hashes, so that a revoked key can never be reused.

### What happens if I delete the app?

Your notifications, your keys and your identity go with it. None of it is recoverable, and every send key you created stops working.

### Do you track me?

There is no analytics, no crash reporting, no advertising identifier and no tracking SDK in the apps. This website sets no cookies and serves its fonts from this domain; Cloudflare, which hosts it, counts visits with its cookieless Web Analytics, and that is the only analytics anywhere in the product. The [privacy policy](/privacy) has the full picture.

## The apps

### Which devices does it run on?

iPhone and iPad on iOS 17 or later, and Mac on macOS 14 or later, where it lives in the menu bar. There is no Android app, because delivery goes through Apple’s push service.

### Where do I get the Mac app?

From this site, as a notarized DMG that updates itself, or from the [Mac App Store](https://apps.apple.com/app/id1563961135?platform=mac). Both are the same app.

### Can I send to more than one device?

Yes, by creating a key on each. A key delivers only to the device that created it, so which key a script holds decides where its notifications go.

### How do I revoke a key?

Revoke it in the app. The next send with it is refused. A key is shown once when it is created and is never stored, so it cannot be shown again — if you lose it, make a new one.

## Urgent alerts

### What does the urgent toggle do?

A key marked urgent, sent with `is_critical=1`, is delivered as a Time Sensitive notification: it breaks through Focus and stays on the lock screen. It does **not** sound through the silent switch. Both halves are required — a send that asks for urgency with a key that does not have it is delivered as an ordinary notification rather than refused.

### Will it ring through silent mode?

No. Time Sensitive is the highest level notifi delivers at: it breaks through Focus and stays on the lock screen, and it respects the silent switch.

## Reliability

### Is delivery guaranteed?

No. Every send goes out over Apple’s push service and a websocket at the same time, and the notification is stored before either, so the app can fetch anything a push missed. But delivery still depends on Apple, your network and your device’s settings, and the service is provided as is, without an uptime guarantee. See the [terms](/terms).

> **Do not make notifi the only path for anything where a missed notification causes harm.** It is a pager for your own systems, not a life-safety, medical or emergency alerting system.

## Something else

Any questions please contact [hello@notifi.it](mailto:hello@notifi.it) or open an issue at [github.com/notifi-it/notifi/issues](https://github.com/notifi-it/notifi/issues).
