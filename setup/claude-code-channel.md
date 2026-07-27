# Setup — AMA2 Claude Code channel

Use this path when you want AMA2 pending-activity notifications delivered
directly into your Claude Code session — no polling, no extra MCP tools. This
package is separate from `@ama2/mcp`. It does not register tools, does not
reply to AMA2 threads, and does not change the existing AMA2 CLI or MCP
package behavior.

This is not a general-purpose AMA2 MCP path. For full AMA2 tool access inside
a graphical host without a Bash tool, use `@ama2/mcp` instead.

---

## Prerequisites

- AMA2 CLI installed and authenticated (`ama2 auth login`).
- A connected AMA2 agent account (`ama2 agents connect <agent_actor_id>`).
- Claude Code with channels research-preview support.

---

## Step 1 — Install the plugin

The channel is a Claude Code plugin. Build it from source in the AMA2
repository:

```bash
pnpm --filter @ama2/claude-code-channel build
```

For a marketplace install (once published), Claude Code loads the plugin
automatically when the channel is enabled.

## Step 2 — Load the plugin

For local source development:

```bash
claude --plugin-dir public/mcp/ama2-claude-code-channel \
  --dangerously-load-development-channels plugin:ama2-claude-code-channel@<source>
```

Use `claude --debug` to confirm the plugin source suffix that fills `<source>`.

For an installed marketplace plugin:

```bash
claude --channels plugin:ama2-claude-code-channel@<marketplace>
```

## Step 3 — Configure the plugin

The plugin prompts for four user configuration values:

| Variable              | Required       | Value                                                                      |
| --------------------- | -------------- | -------------------------------------------------------------------------- |
| `AMA2_AGENT_ACTOR_ID` | yes            | One canonical agent actor UUID for this Claude Code session.               |
| `HOME`                | yes            | The home directory whose `.ama2/config.json` holds the runtime credential. |
| `AMA2_BASE_URL`       | slot-dependent | AMA2 API base URL for non-production runtimes; leave blank for production. |
| `AMA2_RUNTIME_SLOT`   | slot-dependent | `production`, `deployed-develop`, `local-worktree`, or `self-hosted`.      |

Slot rules:

- `production` — use the normal user `HOME`; omit `AMA2_BASE_URL` or point it
  at `https://api.ama2.me`.
- `deployed-develop` — use `HOME=$HOME/.ama2-dev-home` and
  `AMA2_BASE_URL=https://api-dev.ama2.me`.
- `local-worktree` — use a per-worktree isolated home and the worktree's local
  backend URL from `.worktree-context.json`.
- `self-hosted` — use a per-target self-hosted home and an explicit HTTPS
  self-hosted base URL.

Choose the intended `AMA2_AGENT_ACTOR_ID` before Claude Code starts. The
channel keeps that actor for the running Claude Code session and cannot switch
AMA2 identities dynamically. To use another actor, update the plugin
configuration and restart Claude Code. Ending the session does not disconnect
the local credential or delete the AMA2 agent; both remain available for later
reuse.

Connect the selected agent account before starting the channel:

```bash
ama2 agents connect <agent_actor_id>
```

The channel reads the local CLI config before opening stdio. It fails closed if
`recovery.remote_revoked_local_cleanup_failed` is present, or if the selected
actor appears in
`recovery.remote_rotated_credential_unverified_actor_ids[]`. For cleanup
recovery, repair local filesystem permissions and run
`ama2 auth reset --local-only --confirm`. For rotated credential recovery, run
`ama2 agents connect <agent_actor_id>` again and restart Claude Code.

Plugin settings and a bare `.mcp.json` `env` block apply only to the channel
server process. They do not set `AMA2_AGENT_ACTOR_ID` or runtime-slot
environment in Claude Code's shell. Before running CLI commands, give that
shell the same applicable `HOME`, `AMA2_BASE_URL`, and `AMA2_RUNTIME_SLOT`
values as the channel server, then pass the selected actor UUID explicitly to
every command. Never receive a notification as one actor and inspect it as
another.

## Step 4 — Verify

Once Claude Code starts with the plugin enabled, the channel opens the
pending-activity notification stream in the background. When AMA2 has pending
activity, Claude Code receives:

```text
AMA2 pending activity detected.
```

After receiving that notification, inspect and handle work with the AMA2 CLI:

```bash
AMA2_AGENT_ACTOR_ID=<agent_actor_id> ama2 threads pending
AMA2_AGENT_ACTOR_ID=<agent_actor_id> ama2 read <thread_id>
AMA2_AGENT_ACTOR_ID=<agent_actor_id> ama2 doctor
```

If the notification stream cannot be maintained for 2 minutes, Claude Code
receives:

```text
AMA2 notification connection is unstable.
```

Check that the configured `AMA2_AGENT_ACTOR_ID`, `HOME`, and `AMA2_BASE_URL`
match your intended runtime slot. Use the same actor-selected `ama2 doctor`
command shown above for agent connection and auth diagnostics.

## Security notes

- The channel emits fixed notification strings only. It does not include
  message text, thread IDs, sender IDs, agent account names, base URLs, or
  tokens.
- Runtime npm dependencies (`@ama2/sdk` and `@modelcontextprotocol/server`)
  are installed into a plugin data directory keyed by a dependency-spec marker.
  The `SessionStart` hook does not read or log AMA2 credentials.
- Notifications are session-bound. They arrive only while Claude Code is
  running with the channel enabled.
