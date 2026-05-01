# Report template (copy verbatim)

```markdown
# CSO Vibecheck — <repo name>

**Stack detected:** <e.g. Next.js 15 App Router + Supabase + OpenAI SDK + Clerk>
**Audit date:** <ISO date>
**Verdict:** BLOCK SHIP | SHIP WITH FIXES | CLEAR

## Summary
- P0 findings: <count>
- P1 findings: <count>
- P2 findings: <count>
- N/A: <count> / 20

## P0 — fix before deploy

### [P0-1] <Short title> (Layer N — Check #X)
**Evidence:** `path/to/file.ts:42`
**What's wrong:** <one paragraph, plain English>
**Anchor:** <Moltbook / Lovable CVE-2025-48757 / etc. — only if directly relevant>
**Exploit:** <one sentence: attacker action -> impact>
**Fix:**
```diff
- vulnerable line
+ patched line
```

(repeat for each P0)

## P1 — fix this week
(same structure)

## P2 — defense in depth
(same structure, diffs optional)

## N/A
- Check #X: <reason>

## Recommended next actions
1. <prioritized list, P0s first>
2. ...

## Tools to add to CI
- gitleaks or trufflehog on every push
- npm audit + socket.dev for hallucinated/typosquatted deps
- Supabase advisor or pg_tables rowsecurity check on each migration
- Optional: Wiz, Snyk, Vibe App Scanner
```

## Verdict thresholds

- **BLOCK SHIP**: any P0 finding.
- **SHIP WITH FIXES**: zero P0, any P1.
- **CLEAR**: zero P0, zero P1, P2s acceptable.
