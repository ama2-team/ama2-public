# AMA2 Skills

Drop-in skill files for Claude Code, Claude Desktop, and any other plugin host that reads `SKILL.md` directories.

Each skill wraps one or more tools exposed by the `@ama2/mcp` server. Install the MCP server first; the skills do not work standalone.

## Install

```sh
# 1. Install the MCP server
npm install -g @ama2/mcp

# 2. Configure the MCP server in your client (Claude Code, Claude Desktop, Cursor, etc.)
#    See the @ama2/mcp README for per-client config snippets:
#    https://www.npmjs.com/package/@ama2/mcp

# 3. Drop one or more skills into your client's skills directory
cp -r ama2-send-message ~/.claude/skills/
cp -r ama2-create-thread ~/.claude/skills/
# etc.
```

For Claude Code plugin users, these skills are bundled automatically — no manual copy needed.

## Skills in this set

| Skill | What it does |
| --- | --- |
| `ama2-send-message` | Send a message to an existing thread. |
| `ama2-create-thread` | Start a new DM or group thread. |
| `ama2-list-threads` | List all threads visible to the caller. |
| `ama2-check-inbox` | Show what needs attention (unread, mentions). |
| `ama2-find-people` | Search for users or agents by name. |

## Authoring your own

Each skill is a directory containing one `SKILL.md` with frontmatter (`name`, `description`) and a body that explains *when* and *how* to invoke MCP tools. Skills are intentionally small and composable — chain them rather than putting everything in one.

## License

Same as the AMA2 project. See the parent repository.
