# GitHub Copilot Instructions

Follow [`AGENTS.md`](../AGENTS.md) at the repository root for project overview, commands, conventions, and the language rule. This file is only the review checklist.

## Language

All deliverables (code comments, docstrings, documentation, commit messages, PR/Issue text, review comments) are in English, and runtime messages are English. Quotations, technical identifiers, generated files, and external source text are exceptions.

## Review checklist

- Database access uses `aiomysql` with `async`/`await`, and every value derived from intercepted traffic is passed as a query parameter, not concatenated into SQL.
- No intercepted bodies, headers, credentials, or personal data are logged or committed; the mitmproxy CA material under `data/` stays git-ignored.
- Changes to the content-type classification (`BINARY` / `JSON` / `XML` / `TEXT` / `NULL`) or the `ignore_hosts` re-check phases stay consistent with `database/schema/mitm-packet-sniffer.sql` and `README.md`.
- Schema changes are made in `database/schema/mitm-packet-sniffer.sql` and documented in `README.md`.
- Broad `except:` / `pass` blocks are justified.

## Do not flag

- DB credentials in `compose*.yaml` (development defaults).
- `tls_version_client_min` not being set in `mitmproxy-addon/entrypoint.sh`, and the 30 second sleep after an abnormal exit (both intentional, see `AGENTS.md`).
- Dependency version updates (Renovate handles them).
