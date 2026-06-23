# Credits

## Craft seeds — `templates/craft-seeds/`

The role craft seeds under `templates/craft-seeds/` are adapted from
[**anthropics/knowledge-work-plugins**](https://github.com/anthropics/knowledge-work-plugins),
licensed under the **Apache License 2.0**. A copy of that license is included at
`templates/craft-seeds/LICENSE`.

These seeds are starting points: a new team member reads the matching seed during
`self-onboard` and fits it to its own mandate, then keeps refining it via
`self-improve`. They are not used verbatim.

### Modifications (Apache-2.0 §4(b))

Per role we copied `skills/`, `CONNECTORS.md`, and `.mcp.json` (and `commands/`
where present); we did **not** copy the upstream `.claude-plugin/` plugin wrapper.
We then adapted the material from its upstream "Cowork plugin" shape into our
agent-team **craft-seed** shape:

- **`.mcp.json`**: connector entries with an empty `url` (unwired placeholders —
  Gmail / Google Calendar / Snowflake / Databricks) were removed; the hardcoded
  Slack OAuth `clientId` was replaced with the placeholder `<your-oauth-client-id>`.
- **Skills (`SKILL.md`) / commands**: the slash-command wrapper was stripped
  (`argument-hint` frontmatter, `# /name` heading slashes, `## Usage` blocks of
  `/command $ARGUMENTS`, `@$1` lines) so they read as auto-invoked craft
  methodology; `claude plugins add …` install lines were removed; "Cowork"
  references were generalized. The **methodology bodies are otherwise unchanged.**
- **`README.md`**: each role's README was replaced with a short craft-seed README
  (purpose + skill list + connector note).

Connectors in every seed are **examples to edit to your own stack** — see each
role's `CONNECTORS.md`. The seeds are starting material; members fit them to their
mandate via `self-onboard` and refine via `self-improve`.
