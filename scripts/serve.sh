#!/bin/bash
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
if ! command -v synaptiq &>/dev/null; then
  echo "Error: synaptiq not found" >&2
  exit 1
fi
exec synaptiq "$@"
