#!/usr/bin/env bash
set -e

BLUE='\033[1;34m'; CYAN='\033[1;36m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; DIM='\033[2m'; RESET='\033[0m'

cat <<'BANNER'

[BLUE]  ██████╗███████╗ ██████╗     ██╗   ██╗██╗██████╗ ███████╗
[BLUE] ██╔════╝██╔════╝██╔═══██╗    ██║   ██║██║██╔══██╗██╔════╝
[BLUE] ██║     ███████╗██║   ██║    ██║   ██║██║██████╔╝█████╗  
[BLUE] ██║     ╚════██║██║   ██║    ╚██╗ ██╔╝██║██╔══██╗██╔══╝  
[BLUE] ╚██████╗███████║╚██████╔╝     ╚████╔╝ ██║██████╔╝███████╗
[BLUE]  ╚═════╝╚══════╝ ╚═════╝       ╚═══╝  ╚═╝╚═════╝ ╚══════╝
[CYAN]            ┌─┐┬ ┬┌─┐┌─┐┬┌─    senior-CSO security audit
[CYAN]            │  ├─┤├┤ │  ├┴┐    for vibe-coded apps
[CYAN]            └─┘┴ ┴└─┘└─┘┴ ┴

BANNER

# Replace color tokens
sed_colors() {
  echo "$1" | sed -e "s/\[BLUE\]/$(printf '\033[1;34m')/g" \
                  -e "s/\[CYAN\]/$(printf '\033[1;36m')/g" \
                  -e "s/\[RESET\]/$(printf '\033[0m')/g"
}

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

clear 2>/dev/null || true
print_banner

DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/cso-vibecheck"
REPO="https://github.com/git-akki/cso-vibecheck.git"

echo -e "${DIM}target:${RESET}  $DEST"
echo -e "${DIM}source:${RESET}  $REPO"
echo

if [ -d "$DEST" ]; then
  echo -e "${YELLOW}!${RESET} skill already installed — pulling latest"
  git -C "$DEST" pull --quiet --ff-only || { echo -e "${RED}✗ pull failed${RESET}"; exit 1; }
else
  echo -e "${BLUE}→${RESET} cloning..."
  mkdir -p "$(dirname "$DEST")"
  git clone --depth 1 --quiet "$REPO" "$DEST" || { echo -e "${RED}✗ clone failed${RESET}"; exit 1; }
fi

chmod +x "$DEST/scripts/triage.sh" 2>/dev/null || true

echo
echo -e "${GREEN}✓${RESET} installed 22-check audit + scripts"
echo
echo -e "${BLUE}quickstart${RESET}"
echo "  in any Claude Code session, ask:"
echo -e "    ${CYAN}\"audit my app for security issues\"${RESET}"
echo -e "    ${CYAN}\"/cso-vibecheck quick scan\"${RESET}"
echo
echo "  or run the 30-second triage outside Claude:"
echo -e "    ${CYAN}bash $DEST/scripts/triage.sh /path/to/repo${RESET}"
echo
echo -e "${DIM}docs:    https://github.com/git-akki/cso-vibecheck${RESET}"
echo -e "${DIM}issues:  https://github.com/git-akki/cso-vibecheck/issues${RESET}"
echo
