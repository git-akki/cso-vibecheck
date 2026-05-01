# cso-vibecheck

Senior-CSO security audit skill for vibe-coded apps (Cursor / Lovable / Bolt / Replit / v0 / Claude-built).

Runs a deterministic, repeatable 20-layer audit and produces a structured report with `file:line` evidence and copy-paste remediation diffs.

## Why

Vibe-coded apps consistently ship the same shortlist of failures:

- 40-62% of AI-generated code contains a vulnerability
- 73% fail at least one OWASP Top 10 check at deploy
- 11% of public Supabase apps leak service keys
- 78% expose `.env` files
- 91.5% have at least one AI-hallucination flaw (Q1 2026)

Real incidents this skill is anchored to:

- **Moltbook (Feb 2026)** — 1.5M auth tokens + 35K emails leaked via Supabase RLS off + anon key in client bundle, 3 days post-launch.
- **Lovable CVE-2025-48757** — BOLA on `/api/projects/[id]`, 18k user records exposed, 48 days unpatched.
- **Bolt.new** — `sk-` / `AKIA` / `AIzaSy` keys frequently shipped in JS bundles.
- **Cursor** — `.env` / `.cursor/` configs committed to git.
- **Snake game (Claude)** — `pickle.loads` on network input → RCE.


## What 318 vulnerabilities look like

VibeWrench scanned 100 vibe-coded apps (2026):

| Finding | % of apps | Covered by |
|---|---|---|
| Missing CSRF | 70% | Check 21 |
| Exposed secrets / API keys | 41% | Checks 6, 16 |
| Stack-trace leak | 36% | Check 8 |
| Missing input validation | 28% | Checks 3-5 |
| No endpoint auth | 21% | Checks 1, 11, 19 |
| Missing security headers | 20% | Check 22 |
| XSS | 18% | Check 5 |
| Exposed Supabase creds | 12% | Checks 6, 13 |

Wiz Research (2025): 20% of vibe-coded apps ship serious flaws. ETH Zurich BaxBench (2025): **45% of AI-generated code contains an OWASP Top 10 vulnerability.**

## What it covers

22 layered checks:

1. API gateway rate limit + auth on paid-API routes
2. Webhook signature verification (raw body, Stripe/Clerk/Resend)
3. User input never concatenated into system prompt
4. Parameterized DB queries (Supabase/Prisma)
5. HTML sanitization before injection of AI output
6. API keys never in client bundle (`NEXT_PUBLIC_*`/`VITE_*`)
7. `max_tokens` + timeout + canary on every LLM call
8. Generic prod errors; no stack-trace leak
9. RAG/retrieval filters by `tenant_id` at the DB level
10. Action Guard — mutation tools require server-side permission re-check + idempotency
11. Identity from server session, never from request body/header
12. Ownership check on every `/[id]` route (BOLA / IDOR)
13. Supabase RLS enabled on every public table
14. Atomic credit deduction + signup captcha + email normalization
15. Structured logger with redaction; no `console.log(req.body)`
16. `.env*` in `.gitignore` AND not in git history
17. Hallucinated/typosquatted npm deps
18. No `pickle.loads` / `eval` / `yaml.load` / `Function()` / `shell:true` on user input
19. Middleware coverage matches every protected route
20. Server-side gating, not just client `useEffect` redirect
21. CSRF protection on state-changing requests (70% of apps miss this)
22. Security headers (CSP, HSTS, X-Frame-Options) + cookie flags + TLS enforcement

Full procedure for each check: [`references/checks.md`](references/checks.md).

## Install

```bash
git clone https://github.com/git-akki/cso-vibecheck.git ~/.claude/skills/cso-vibecheck
```

Then in any Claude Code session, ask:

> audit my app for security issues

or invoke directly:

> /cso-vibecheck

## Quick triage mode

For a 30-second scan of the 5 most catastrophic categories (key in client, IDOR, RLS off, .env exposed, identity from request):

```bash
bash ~/.claude/skills/cso-vibecheck/scripts/triage.sh /path/to/repo
```

Then ask Claude:

> /cso-vibecheck quick scan

## Output

Structured Markdown report with:

- Verdict: BLOCK SHIP | SHIP WITH FIXES | CLEAR
- P0 / P1 / P2 / N/A counts
- Each finding: layer, check #, `file:line` evidence, plain-English description, anchor incident, one-sentence exploit, copy-paste diff fix
- Recommended next actions
- CI tools to add (gitleaks, socket.dev, Supabase advisor)

See [`references/report-template.md`](references/report-template.md) for the exact template.

## References

- [OWASP LLM Top 10 (2025)](https://genai.owasp.org/llm-top-10/)
- [OWASP Top 10 for Agentic Applications (2026)](https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/)
- [Wiz Research: 20% of vibe apps risky](https://www.wiz.io/blog/common-security-risks-in-vibe-coded-apps)
- [Escape Tech: 2k+ vulns across 5,600 apps](https://escape.tech/blog/methodology-how-we-discovered-vulnerabilities-apps-built-with-vibe-coding/)
- [Moltbook hack writeup](https://blog.ogwilliam.com/post/moltbook-hack-supabase-vibe-coding)
- [Lovable security crisis (TNW)](https://thenextweb.com/news/lovable-vibe-coding-security-crisis-exposed)

## License

MIT

