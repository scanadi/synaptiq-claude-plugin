#!/bin/bash
set -euo pipefail

# Synaptiq Setup Script
# Checks installation, indexes codebase, verifies MCP connection

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "\n${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
fail() { echo -e "${RED}[x]${NC} $1"; }
ok()   { echo -e "${GREEN}[ok]${NC} $1"; }

FORCE=false
for arg in "$@"; do
  [[ "$arg" == "--force" ]] && FORCE=true
done

echo "=== Synaptiq Setup ==="

# Minimum synaptiq version this plugin is written against. The skill
# documents tools (coupling, communities, explain, review_risk, export, ...)
# that only work correctly from 1.0.0 onward.
MIN_VERSION="1.0.0"

version_lt() {
  # True when $1 < $2 (semver-ish numeric compare).
  [ "$(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n -k3,3n | head -1)" = "$1" ] \
    && [ "$1" != "$2" ]
}

upgrade_synaptiq() {
  if command -v uv &>/dev/null; then
    step "Upgrading synaptiq via uv..."
    uv tool upgrade synaptiq || uv tool install --force synaptiq
  elif command -v pip &>/dev/null; then
    step "Upgrading synaptiq via pip..."
    pip install --upgrade synaptiq
  else
    fail "Neither uv nor pip found to upgrade synaptiq."
    exit 1
  fi
}

# Step 1: Check if synaptiq is installed
step "Checking if synaptiq is installed..."
if command -v synaptiq &>/dev/null; then
  VERSION=$(synaptiq --version 2>/dev/null || echo "unknown")
  ok "synaptiq found: $VERSION"
  INSTALLED_NUM=$(echo "$VERSION" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
  if [[ -n "$INSTALLED_NUM" ]] && version_lt "$INSTALLED_NUM" "$MIN_VERSION"; then
    warn "synaptiq $INSTALLED_NUM is older than the $MIN_VERSION this plugin requires."
    upgrade_synaptiq
    VERSION=$(synaptiq --version 2>/dev/null || echo "unknown")
    ok "synaptiq upgraded: $VERSION"
  fi
else
  warn "synaptiq is not installed."
  echo ""
  echo "Install options:"
  echo "  uv tool install synaptiq    (recommended)"
  echo "  pip install synaptiq"
  echo ""

  # Try uv first, then pip
  if command -v uv &>/dev/null; then
    step "Installing via uv..."
    uv tool install synaptiq
  elif command -v pip &>/dev/null; then
    step "Installing via pip..."
    pip install synaptiq
  else
    fail "Neither uv nor pip found. Please install Python 3.11+ and run:"
    echo "  pip install synaptiq"
    exit 1
  fi

  if command -v synaptiq &>/dev/null; then
    VERSION=$(synaptiq --version 2>/dev/null || echo "unknown")
    ok "synaptiq installed: $VERSION"
  else
    fail "Installation failed. Please install manually."
    exit 1
  fi
fi

# Step 2: Check Python version
step "Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
if [[ -n "$PYTHON_VERSION" ]]; then
  MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
  MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
  if [[ "$MAJOR" -ge 3 && "$MINOR" -ge 11 ]]; then
    ok "Python $PYTHON_VERSION (3.11+ required)"
  else
    warn "Python $PYTHON_VERSION detected. Synaptiq requires 3.11+"
  fi
else
  warn "Could not detect Python version."
fi

# Step 3: Check if synaptiq server is already running (started by MCP)
SERVER_PID=""
if pgrep -f "synaptiq serve" &>/dev/null; then
  SERVER_PID=$(pgrep -f "synaptiq serve" | head -1)
fi

# Step 4: Index the codebase
if [[ "$FORCE" == "true" ]]; then
  step "Force rebuild requested — running full reindex..."
  if [[ -n "$SERVER_PID" ]]; then
    warn "Stopping MCP server (PID $SERVER_PID) to release DB lock..."
    kill "$SERVER_PID" 2>/dev/null || true
    sleep 1
  fi
  synaptiq analyze . --full
  ok "Full reindex complete."
  if [[ -n "$SERVER_PID" ]]; then
    ok "MCP server will restart automatically on next tool call."
  fi
elif [[ -d ".synaptiq" ]]; then
  step "Checking for existing index..."
  ok "Index found at .synaptiq/"
  if [[ -n "$SERVER_PID" ]]; then
    ok "MCP server is running with --watch (auto-reindexing enabled)"
  else
    echo "  Running incremental update..."
    synaptiq analyze .
  fi
else
  step "No index found. Running initial analysis (this may take a minute)..."
  if [[ -n "$SERVER_PID" ]]; then
    warn "Stopping MCP server to run initial index..."
    kill "$SERVER_PID" 2>/dev/null || true
    sleep 1
  fi
  synaptiq analyze .
fi

if [[ -d ".synaptiq" ]]; then
  ok "Codebase indexed successfully."
else
  fail "Indexing failed. Check synaptiq output above."
  exit 1
fi

# Step 5: Show index stats
step "Index status:"
synaptiq status 2>/dev/null || synaptiq list 2>/dev/null || true

# Step 6: Check .gitignore
step "Checking .gitignore..."
if [[ -f ".gitignore" ]]; then
  if grep -qF ".synaptiq" .gitignore 2>/dev/null; then
    ok ".synaptiq/ is in .gitignore"
  else
    warn ".synaptiq/ not in .gitignore — adding it."
    echo "" >> .gitignore
    echo "# Synaptiq index" >> .gitignore
    echo ".synaptiq/" >> .gitignore
    ok "Added .synaptiq/ to .gitignore"
  fi
else
  warn "No .gitignore found. Consider adding .synaptiq/ to it."
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Synaptiq is ready. The MCP server will start automatically in Claude Code."
echo "Use synaptiq_query, synaptiq_context, synaptiq_impact, and other tools."
