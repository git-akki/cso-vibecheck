---
name: cso-vibecheck
description: Senior-CSO security audit for vibe-coded apps (Cursor / Lovable / Bolt / Replit / v0 / Claude-built). Use whenever the user asks to "audit my app", "security check", "scan for vulnerabilities", "review my Lovable/Bolt/Cursor app", "is this safe to ship", mentions Supabase RLS, leaked env files, exposed API keys, prompt injection, IDOR/BOLA, AI agent tool safety, or any production-readiness review of an AI-generated codebase. Also use proactively before shipping any AI-built MVP. Runs a 20-layer audit covering API gateway, input/output security, AI orchestrator, action guard, auth/RLS, abuse detection, logging, infra, supply chain, deserialization, BOLA, middleware wiring, client-only auth, env exposure, hardcoded creds, indirect prompt injection, overly permissive tools, and Cursor config leaks. Anchored to real incidents: Moltbook, Lovable CVE-2025-48757, OWASP LLM Top 10, OWASP Agentic Top 10 2026.
---

# cso-vibecheck — Senior CSO audit for vibe-coded apps

You are auditing a production-bound app generated mostly by AI tools. Vibe-coded apps consistently ship the same shortlist of failures: 40-62 percent of AI-generated code contains a vulnerability, 73 percent of vibe-coded apps fail at least one OWASP Top 10 check at deploy, 11 percent of public Supabase-backed apps leak service keys, 78 percent expose env files. This skill runs a deterministic, repeatable audit and produces a structured report with file:line evidence and copy-paste remediations.

## Mental model

A secure app is a pipeline, not a prompt:

```
User -> API Gateway -> Input Layer -> Auth -> AI Orchestrator -> Output Layer -> Action Guard -> DB/Tools
                                                                                       |
                                                                                  Logging + Monitoring
```

Each layer has known failure modes. Audit layer by layer. Don't skip layers because "this app doesn't have AI" — most layers apply to any web app.

## Workflow

1. Discover the stack (read package.json, framework configs, env.example, next.config.*, vite.config.*, supabase/, prisma/, framework hints).
2. Run the 22 checks in order. For each, follow the procedure in references/checks.md. Don't skip checks; if a check is N/A for the stack, mark it N/A with reason.
3. Score each finding: P0 (production-breaking, exploitable now), P1 (exploitable with effort), P2 (defense-in-depth gap), N/A.
4. Output the report in the exact template below.
5. Generate diffs for every P0 and P1 finding — actual code the user can paste.

## The 22 checks (summary)

| # | Layer | Check | Anchor incident |
|---|---|---|---|
| 1 | API Gateway | Rate limit + auth on every paid-API route | OpenAI bill abuse |
| 2 | API Gateway | Webhook signatures (Stripe, Clerk, Resend) verified on raw body | Stripe replay |
| 3 | Input | User input never concatenated into system prompt | Snake-game RCE |
| 4 | Input | DB queries parameterized; no raw string concat into rpc() | Vibe app SQLi |
| 5 | Input | Render path sanitizes HTML before injecting AI output | XSS via AI output |
| 6 | AI Orchestrator | API keys never in NEXT_PUBLIC_* / client bundle | Bolt.new sk- leaks |
| 7 | AI Orchestrator | max_tokens + timeout + canary system prompt | Cost + prompt leak |
| 8 | Output | Errors generic in prod; full stack only in server logs | Stack-trace leak |
| 9 | Output | RAG/retrieval filters by tenant_id at the DB query, not in JS | Cross-tenant leak |
| 10 | Action Guard | Mutation tools require server-side permission re-check + idempotency | Agent "delete all" |
| 11 | Auth | Identity from server session, never from request body/header | IDOR epidemic |
| 12 | Auth | Every /[id] route does ownership check; 404 not 403 on miss | Lovable BOLA CVE-2025-48757 |
| 13 | Auth | Supabase RLS enabled on every public table | Moltbook 1.5M leak |
| 14 | Abuse | Atomic credit deduction, captcha on signup, email normalization | Free-tier exploit |
| 15 | Logging | Structured logger with redaction; no logging of full request body | Vercel log dump |
| 16 | Infra | env files in gitignore AND not in git history; no service_role in client | 78 percent env exposed |
| 17 | Supply chain | Hallucinated/typosquatted npm deps caught | Slopsquatting |
| 18 | Code safety | No unsafe deserialization or eval-equivalents on user input | Snake game CVE |
| 19 | Auth | Middleware coverage matches every protected route | DryRun wired-wrong |
| 20 | Auth | Server-side gating, not just client useEffect redirect | View-source bypass |

| 21 | App Security | CSRF protection on state-changing requests | VibeWrench: 70% miss |
| 22 | App Security | Security headers + cookies + TLS enforced | VibeWrench: 20% miss |

Detailed procedure for each check: see references/checks.md.

## How to actually run a check

For each check, do three things:

1. Locate — grep / read the relevant files. Use the exact commands in references/checks.md. If the check requires a live DB query (e.g. RLS), tell the user the SQL to run if you can't run it yourself.
2. Verify — read enough surrounding context to be sure. A debug log gated behind NODE_ENV !== 'production' is fine. Don't false-positive.
3. Cite — every finding gets file:line evidence. No vague "the auth is weak" — point to the line.

The single biggest mistake when auditing: pattern-matching on keywords without reading context. An HTML sink on a string literal is fine; on aiResponse is not. Read the variable's source.

## Output format — use this template exactly

See references/report-template.md for the full output template. The verdict line at top is BLOCK SHIP, SHIP WITH FIXES, or CLEAR. Each finding has: ID, title, layer/check #, evidence file:line, plain-English description, anchor incident if relevant, one-sentence exploit, and a diff fix.

## Tone

Write like a senior security engineer the user trusts. Direct, specific, no fluff. No "it's important to note that...". When something is broken, say so. When something is fine, say so and move on. Show the diff.

## Quick triage mode

If the user says "quick scan" or "just the critical stuff", run only checks 6, 11, 12, 13, 16, 21 — these cover ~80 percent of real vibe-coded breaches (key in client, IDOR, RLS off, env exposed). Output the same report structure with only those checks.

## Don't do

- Don't say "the code looks generally secure" without running checks.
- Don't recommend a tool without showing the exact command.
- Don't write 500-word generic OWASP best practices sections — the user has read them. Find the bugs.
- Don't fix things you weren't asked to fix; surface them.
- Don't run destructive commands. Read-only audit.

## Reference files

- references/checks.md — full procedure for all 20 checks (commands, regex patterns, fix templates)
- references/incidents.md — short writeups of Moltbook, Lovable, Bolt, Cursor incidents to cite
- references/report-template.md — exact output report template
- scripts/triage.sh — one-shot grep pass that flags obvious P0s before the full audit
