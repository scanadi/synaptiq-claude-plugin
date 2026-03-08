#!/usr/bin/env bash

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "## Synaptiq Code Intelligence Rules\n\nSynaptiq MCP tools are available for structural code understanding. Follow these rules:\n\n1. **Synaptiq FIRST** — For any code discovery, exploration, or structural question (\"find all code related to X\", \"what calls this\", \"what breaks if I change this\"), ALWAYS use Synaptiq MCP tools FIRST — before grep, glob, or Explore agents.\n2. **Delegate to preserve context** — For broad discovery tasks, delegate to a `general-purpose` agent with instructions to use Synaptiq MCP tools. This preserves main conversation context while leveraging Synaptiq's speed.\n3. **Do not duplicate results** — After Synaptiq returns results, STOP. Do not follow up with glob/grep to re-discover the same files. Only use file-based search for gaps Synaptiq cannot fill (config files, env vars, non-code assets).\n4. **Investigation workflow** — Use `synaptiq_query` to find symbols, then `synaptiq_context` for callers/callees, then `synaptiq_impact` before modifying widely-used symbols.\n5. **Load the synaptiq skill** before using any Synaptiq MCP tool for the first time in a session."
  }
}
EOF

exit 0
