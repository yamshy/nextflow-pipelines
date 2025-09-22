# nextflow-pipelines

Pinned configuration, params, and helper scripts for nf-core demo runs. The Control API uses this repository as its source of truth for pipeline tags, params, and config defaults.

## How to run locally

```bash
# Example: nf-core/rnaseq
./scripts/run_local.sh rnaseq
```

The helper script sources `common/versions.env`, pins the release tag, and executes with `-profile test,docker` so contributors can validate changes without extra setup. It disables both Wave and Fusion by default and pins `NXF_VERSION=24.04.4` so no Seqera credentials or bleeding-edge Nextflow features are required. Outputs land under `runs/<pipeline>-local/`.

## How to run on a cluster

The Control API (or a human) can mirror production behavior with:

```bash
export WORK_BUCKET=s3://your-work-bucket
export RESULTS_BUCKET=s3://your-results-bucket
export RUN_ID=demo-001
export NXF_S3_ENDPOINT=https://minio.example.com
export TOWER_ACCESS_TOKEN=... # required when enabling Wave
./scripts/run_k8s.sh rnaseq "$RUN_ID"
```

Required environment variables:

- `WORK_BUCKET` – location for the Nextflow work directory
- `RESULTS_BUCKET` – base path for published results (`runs/<RUN_ID>` will be appended)
- `NXF_S3_ENDPOINT` – optional if using a custom object store
- `TOWER_ACCESS_TOKEN` – needed when `NXF_WAVE_ENABLED=true`
- `NXF_WAVE_ENABLED=true`, `NXF_ENABLE_FUSION=true`, and `NXF_VERSION=24.04.4` are exported by the k8s script by default; override as needed.

## Pipelines included

| Pipeline key | nf-core pipeline | Tag | Expected artifacts |
| --- | --- | --- | --- |
| `rnaseq` | `nf-core/rnaseq` | `3.14.0` | MultiQC report, alignment stats |
| `viralrecon` | `nf-core/viralrecon` | `2.6.0` | Consensus FASTA, QC reports |
| `ampliseq` | `nf-core/ampliseq` | `2.7.0` | Variant tables, MultiQC report |

## Control API contract

- `pipelineKey` must be one of `rnaseq`, `viralrecon`, or `ampliseq`
- `paramsPath` is fixed to `pipelines/<pipelineKey>/params/toy.json`
- `tag` values are sourced from `common/versions.env`
- Runtime environment injects `WORK_BUCKET`, `RESULTS_BUCKET`, `NXF_S3_ENDPOINT`, `NXF_WAVE_ENABLED` (true only if a Tower token is present), `NXF_ENABLE_FUSION=true`, and sets `RUN_ID`
- The Control API launches Nextflow with `--outdir ${RESULTS_BUCKET}/runs/${RUN_ID}`

## CI

`.github/workflows/ci.yml` runs a smoke test matrix over all three pipelines. Each job executes:

```bash
nextflow run nf-core/<pipeline> -r <tag> -profile test,docker --outdir runs/<pipeline>-ci
```

Brief outputs are uploaded as artifacts so maintainers can spot regressions quickly before upgrading Control API images.

## Licenses & data notes

All pipelines rely on nf-core-provided test datasets when the `test` profile is specified. No proprietary data is stored in this repository. Consult the upstream nf-core licenses for downstream usage terms.
