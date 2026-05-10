# Versioning Policy

## Quick reference

- All public surfaces follow [Semantic Versioning 2.0.0](https://semver.org/).
- CLI / MCP / Skills are versioned **independently**.
- First public release is `1.0.0` for every surface.
- Tags pushed from `main` only. Pre-release tags use `-rc.N`, `-beta.N`, `-alpha.N` suffixes.

## When to expect a bump

| Type | Trigger | Example |
| --- | --- | --- |
| `PATCH` | Bug fix, no behavior change. | 1.0.0 → 1.0.1 |
| `MINOR` | New feature, backwards-compatible. | 1.0.0 → 1.1.0 |
| `MAJOR` | Breaking change, code or config update needed. | 1.0.0 → 2.0.0 |
