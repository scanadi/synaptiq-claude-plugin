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

1. If the output says running server(s) were stopped (look for the "/mcp" reconnect notice), tell the user the Synaptiq MCP connection for this session was dropped and they must run `/mcp` → reconnect synaptiq (or `/reload-plugins`) before the tools work again. Do not claim the tools are available.
2. Otherwise, if the script reports success, confirm to the user that Synaptiq is ready and the MCP tools are available.
3. If the script reports errors, help the user troubleshoot based on the output.
