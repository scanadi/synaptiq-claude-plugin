# Synaptiq Plugin for Claude Code

One-step code intelligence integration for Claude Code. Install this plugin and get structural code understanding — call graphs, impact analysis, dead code detection, and architectural insights — powered by [Synaptiq](https://github.com/scanadi/synaptiq).

## What You Get

| Component | What It Does |
|-----------|-------------|
| **Skill** | Teaches Claude how to use all Synaptiq MCP tools, Cypher patterns, and investigation workflows |
| **MCP Server** | Auto-starts `synaptiq serve --watch` with live re-indexing |
| **Setup Command** | `/synaptiq:setup` — installs Synaptiq, indexes your codebase, verifies everything works |
| **Session Hook** | Injects behavioral rules so Claude uses Synaptiq first for structural questions |

## Installation

### Option 1: Marketplace Install (Recommended)

Register the marketplace and install the plugin:

```bash
claude plugin marketplace add https://github.com/scanadi/synaptiq-claude-plugin
claude plugin install synaptiq
```

### Option 2: Load Directly (Single Session)

Clone the repo and load the plugin for a single session:

```bash
git clone https://github.com/scanadi/synaptiq-claude-plugin.git
claude --plugin-dir ./synaptiq-claude-plugin
```

### Updating

Update the marketplace, then reinstall the plugin:

```bash
claude plugin marketplace update synaptiq-claude-plugin
claude plugin uninstall synaptiq
claude plugin install synaptiq
```

### Setup

After installing, run the setup command in Claude Code:

```
/synaptiq:setup
```

This will:
1. Check if Synaptiq is installed (auto-installs via `uv` or `pip` if not)
2. Verify Python 3.11+
3. Index your codebase into a knowledge graph
4. Add `.synaptiq/` to `.gitignore`
5. Verify the MCP connection

## Prerequisites

- **Python 3.11+**
- **Claude Code** with plugin support
- One of: `uv` (recommended) or `pip`
- **Synaptiq >= 2.0.5** — `/synaptiq:setup` installs or upgrades it automatically

## Usage

Once installed, Claude will automatically:

- Use Synaptiq for structural code questions before falling back to grep/glob
- Delegate broad discovery tasks to subagents with Synaptiq access (preserving main context)
- Check impact before modifying widely-used symbols

### Available MCP Tools

| Tool | Purpose |
|------|---------|
| `synaptiq_query` | Search symbols by name or concept (focus-file biasing via PageRank) |
| `synaptiq_context` | 360-degree view — callers, callees, types, heritage, community |
| `synaptiq_impact` | Blast radius — all affected symbols, grouped by depth |
| `synaptiq_dead_code` | Find unreachable code |
| `synaptiq_detect_changes` | Map git diffs to affected symbols |
| `synaptiq_coupling` | Files that change together in git history (hidden dependencies) |
| `synaptiq_call_path` | Shortest call chain between two symbols |
| `synaptiq_communities` | Leiden architectural clusters and their members |
| `synaptiq_explain` | Narrative explanation of a symbol's role |
| `synaptiq_review_risk` | PR risk score from entry points, coupling, and community crossings |
| `synaptiq_file_context` | Everything about one file: symbols, imports, coupling, dead code |
| `synaptiq_cycles` | Circular dependencies via strongly connected components |
| `synaptiq_test_impact` | Tests likely affected by a diff or symbol list |
| `synaptiq_export` | Graph-aware context packing for a symbol in one response |
| `synaptiq_suggest` | Recommended tool sequence for a natural-language question |
| `synaptiq_remember` / `recall` / `forget` | Persist facts about the codebase across sessions |
| `synaptiq_cypher` | Raw read-only Cypher against the knowledge graph |
| `synaptiq_list_repos` | List indexed repositories |

### Example Prompts

```
"What calls the handleAuth function?"
"What breaks if I change UserModel?"
"Find all dead code in the server package"
"Show me the blast radius for changing validateToken"
"Which files always change together?"
```

## How It Works

Synaptiq indexes your codebase using tree-sitter AST parsing into a LadybugDB knowledge graph. Every function, class, import, call, and type reference becomes a queryable node or edge. The MCP server exposes this graph to Claude Code.

The server runs under a strict resource profile (capped engine threads, 512 MB buffer pool, capped embedding threads) so it stays polite beside your real work even with many agents querying concurrently. Tune via `SYNAPTIQ_DB_THREADS`, `SYNAPTIQ_DB_MEMORY_MB`, and `SYNAPTIQ_EMBED_THREADS` if needed (the older `SYNAPTIQ_KUZU_THREADS` / `SYNAPTIQ_KUZU_MEMORY_MB` names still work as deprecated aliases for one release).

The plugin's session hook ensures Claude reaches for Synaptiq first when asked structural questions, rather than grepping through files. The skill provides Claude with the full tool reference, Cypher query patterns, and troubleshooting guidance.

## Supported Languages

- Python (`.py`)
- TypeScript / JavaScript (`.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs`)
- Ruby (`.rb`, `.rake`, `.gemspec`, `.ru`, `.rbi`, plus suffix-less files like `Rakefile`, `Gemfile`, `Guardfile`, `Capfile`, `Vagrantfile`, `Brewfile`, `Podfile`)
- Go (`.go`)

## License

MIT
