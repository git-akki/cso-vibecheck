#!/usr/bin/env bash
# Quick triage — flags obvious P0s in <30 seconds. Run before the full audit.
# Usage: bash triage.sh [path]   (defaults to current dir)
set -uo pipefail
ROOT="${1:-.}"
cd "$ROOT" || exit 1
echo "==> cso-vibecheck triage on $(pwd)"

flag() { echo "  [P0] $*"; }
ok()   { echo "  [ok] $*"; }

echo
echo "## env / secrets"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git log --all --full-history --source -- '.env*' 2>/dev/null | grep -q commit; then
    flag ".env in git history — rotate keys + scrub history"
  else
    ok "no .env in git history"
  fi
fi
if grep -rEq "NEXT_PUBLIC_.*(SECRET|KEY|TOKEN|SERVICE_ROLE)" --include='*.env*' --include='*.ts' --include='*.tsx' --include='*.js' . 2>/dev/null; then
  flag "secret-looking value behind NEXT_PUBLIC_*"
fi
if grep -rEq "(sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|AIzaSy[0-9A-Za-z_-]{33}|ghp_[0-9A-Za-z]{36}|xoxb-)" --include='*.ts' --include='*.tsx' --include='*.js' . 2>/dev/null; then
  flag "hardcoded API-key-shaped string in source"
fi

echo
echo "## auth identity"
if grep -rnE "req\.body\.userId|searchParams\.get\(['\"]userId|body\.user_id" --include='*.ts' --include='*.tsx' . 2>/dev/null | head -5; then
  flag "user identity read from request, not session"
fi

echo
echo "## unsafe sinks"
grep -rnE "\beval\(|new Function\(" --include='*.ts' --include='*.tsx' --include='*.js' . 2>/dev/null | head -5
grep -rnE "shell:\s*true" --include='*.ts' --include='*.js' . 2>/dev/null | head -5
grep -rnE "yaml\.load\(|pickle\.loads?" --include='*.py' . 2>/dev/null | head -5

echo
echo "## hardcoded creds"
grep -rnE "password['\"]?\s*[:=]\s*['\"](password123|admin|changeme|secret)" --include='*.ts' --include='*.js' --include='*.py' . 2>/dev/null | head -5

echo
echo "## supabase quick check"
grep -rnE "createClient\([^)]+SERVICE_ROLE" --include='*.ts' --include='*.tsx' . 2>/dev/null | grep -v "server\|api\|route" && flag "service_role key used outside server-only file"

echo
echo "==> done. Run the full /cso-vibecheck audit for the remaining 14 checks."
