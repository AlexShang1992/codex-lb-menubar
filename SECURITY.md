# Security Policy

## Supported versions

The latest released version receives security fixes.

| Version | Supported |
| ------- | --------- |
| 1.0.x   | ✅        |

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Instead, use GitHub's private
[**Report a vulnerability**](https://github.com/AlexShang1992/codex-lb-menubar/security/advisories/new)
workflow (Security → Advisories). You should receive an acknowledgement within a
few days.

## Scope & notes

CodexBar is a **read-only** client. It:

- talks only to the `codex-lb` endpoint you configure (default
  `http://127.0.0.1:2455`, loopback);
- performs a single `GET /api/accounts` request and renders the response;
- does not store credentials, write files, or proxy any traffic.

The app is distributed **ad-hoc signed and not notarized**. Verify builds
yourself or build from source if your threat model requires it.
