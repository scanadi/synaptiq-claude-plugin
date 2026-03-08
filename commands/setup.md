---
description: Install Synaptiq, index the codebase, and verify the MCP connection is working.
argument-hint: "[--force]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh:*)", "Bash(synaptiq:*)"]
---

Execute the setup script:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh"
```

After the script completes:

1. If the script reports success, confirm to the user that Synaptiq is ready and the MCP tools are available.
2. If the script reports errors, help the user troubleshoot based on the output.
3. If the user passed `--force`, run `synaptiq analyze . --full` after the setup script to force a full rebuild of the index.
