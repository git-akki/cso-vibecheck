#!/usr/bin/env bash
set -e

BLUE='\033[1;34m'; CYAN='\033[1;36m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; DIM='\033[2m'; RESET='\033[0m'

print_banner() {
  printf "${BLUE}\n"
  printf "  ██████╗███████╗ ██████╗     ██╗   ██╗██╗██████╗ ███████╗\n"
  printf " ██╔════╝██╔════╝██╔═══██╗    ██║   ██║██║██╔══██╗██╔════╝\n"
  printf " ██║     ███████╗██║   ██║    ██║   ██║██║██████╔╝█████╗  \n"
  printf " ██║     ╚════██║██║   ██║    ╚██╗ ██╔╝██║██╔══██╗██╔══╝  \n"
  printf " ╚██████╗███████║╚██████╔╝     ╚████╔╝ ██║██████╔╝███████╗\n"
  printf "  ╚═════╝╚══════╝ ╚═════╝       ╚═══╝  ╚═╝╚═════╝ ╚══════╝\n"
  printf "${CYAN}            ┌─┐┬ ┬┌─┐┌─┐┬┌─${DIM}    senior-CSO security audit${RESET}\n"
  printf "${CYAN}            │  ├─┤├┤ │  ├┴┐${DIM}    for vibe-coded apps${RESET}\n"
  printf "${CYAN}            └─┘┴ ┴└─┘└─┘┴ ┴${RESET}\n\n"
}

print_banner

DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/cso-vibecheck"
REPO="https://github.com/git-akki/cso-vibecheck.git"

printf "${DIM}target:${RESET}  %s\n" "$DEST"
printf "${DIM}source:${RESET}  %s\n\n" "$REPO"

if [ -d "$DEST/.git" ]; then
  printf "${YELLOW}!${RESET} skill already installed — pulling latest\n"
  git -C "$DEST" pull --quiet --ff-only || { printf "${RED}✗ pull failed${RESET}\n"; exit 1; }
elif [ -d "$DEST" ]; then
  printf "${RED}✗ %s exists but is not a git checkout — move it aside first${RESET}\n" "$DEST"
  exit 1
else
  printf "${BLUE}→${RESET} cloning...\n"
  mkdir -p "$(dirname "$DEST")"
  git clone --depth 1 --quiet "$REPO" "$DEST" || { printf "${RED}✗ clone failed${RESET}\n"; exit 1; }
fi

chmod +x "$DEST/scripts/triage.sh" 2>/dev/null || true

printf "\n${GREEN}✓${RESET} installed 22-check audit + scripts\n\n"
printf "${BLUE}quickstart${RESET}\n"
printf "  in any Claude Code session, ask:\n"
printf "    ${CYAN}\"audit my app for security issues\"${RESET}\n"
printf "    ${CYAN}\"/cso-vibecheck quick scan\"${RESET}\n\n"
printf "  or run the 30-second triage outside Claude:\n"
printf "    ${CYAN}bash %s/scripts/triage.sh /path/to/repo${RESET}\n\n" "$DEST"
printf "${DIM}docs:    https://github.com/git-akki/cso-vibecheck${RESET}\n"
printf "${DIM}issues:  https://github.com/git-akki/cso-vibecheck/issues${RESET}\n\n"
