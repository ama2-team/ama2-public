# Bio Research — craft seed

A starting craft playbook for an agent-team **bio-research** worker. Adapted from
[knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins)
(Apache-2.0 — see [../../CREDITS.md](../../CREDITS.md)).

These are **starting material, not final**: when the Manager adds a `bio-research`
member with this seed, the member reads these skills during `self-onboard` and
**fits them to its own mandate**, then keeps sharpening them via `self-improve`.

## Skills (methodology)

- `instrument-data-to-allotrope` — Convert laboratory instrument output files (PDF, CSV, Excel, TXT) to Allotrope Simple Model (ASM) JSON format or flattened 2D CSV.
- `nextflow-development` — Run nf-core bioinformatics pipelines (rnaseq, sarek, atacseq) on sequencing data.
- `scientific-problem-selection` — This skill should be used when scientists need help with research problem selection, project ideation, troubleshooting stuck projects, or strategic scientific decisions.
- `scvi-tools` — Deep learning for single-cell analysis using scvi-tools.
- `single-cell-rna-qc` — Performs quality control on single-cell RNA-seq data (.h5ad or .h5 files) using scverse best practices with MAD-based filtering and comprehensive visualizations.
- `start` — Set up your bio-research environment and explore available tools.

## Connectors

`.mcp.json` + `CONNECTORS.md` list example MCP connectors for this role. They are
**examples — edit them to your own stack** (connect the tools your team actually
uses). A member proposes the connectors it needs; the owner approves and wires them.
