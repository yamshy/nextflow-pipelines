# nf-core/rnaseq toy run

This demo uses the nf-core/rnaseq pipeline with the `test` profile so it can be executed quickly on contributor laptops or in CI. The `params/toy.json` file contains a minimal set of overrides to keep runs predictable.

Expected outputs (when using the nf-core test data) land under the directory supplied via `--outdir` and include basic MultiQC reports.

> Tested with Nextflow `25.04.7` using the nf-core `test` profile (requires Nextflow `>=25.0`).
