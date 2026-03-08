---
description: Install Synaptiq, index the codebase, and verify the MCP connection is working.
argument-hint: "[--force]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh:*)"]
---

Execute the setup script:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh" $ARGUMENTS
```

After the script completes:

1. If the script reports success, confirm to the user that Synaptiq is ready and the MCP tools are available.
2. If the script reports errors, help the user troubleshoot based on the output.
