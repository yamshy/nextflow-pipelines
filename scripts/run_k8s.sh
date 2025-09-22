#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <pipeline-key> [run-id]" >&2
  echo "Known keys: rnaseq, viralrecon, ampliseq" >&2
  exit 1
fi

PIPELINE_KEY=$1
RUN_ID=${2:-$(date -u +"%Y%m%dT%H%M%SZ")}

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "${REPO_ROOT}/common/versions.env"

case "${PIPELINE_KEY}" in
  rnaseq)
    WF="nf-core/rnaseq"
    TAG="${RNASEQ}"
    ;;
  viralrecon)
    WF="nf-core/viralrecon"
    TAG="${VIRALRECON}"
    ;;
  ampliseq)
    WF="nf-core/ampliseq"
    TAG="${AMPLISEQ}"
    ;;
  *)
    echo "Unknown pipeline key: ${PIPELINE_KEY}" >&2
    exit 1
    ;;
esac

PARAMS_FILE="${REPO_ROOT}/pipelines/${PIPELINE_KEY}/params/toy.json"
RESULTS_PREFIX=${RESULTS_BUCKET:-${REPO_ROOT}}
OUTDIR="${RESULTS_PREFIX}/runs/${RUN_ID}"

DEFAULT_NXF_VERSION=25.04.7

case "${PIPELINE_KEY}" in
  ampliseq)
    PIPELINE_NXF_VERSION=24.04.4
    ;;
  *)
    PIPELINE_NXF_VERSION=${DEFAULT_NXF_VERSION}
    ;;
esac

export NXF_WAVE_ENABLED=${NXF_WAVE_ENABLED:-true}
export NXF_ENABLE_FUSION=${NXF_ENABLE_FUSION:-true}
export NXF_VERSION=${NXF_VERSION:-${PIPELINE_NXF_VERSION}}

nextflow run "${WF}" \
  -c "${REPO_ROOT}/common/nextflow.config" \
  -r "${TAG}" \
  -profile k8s \
  --params-file "${PARAMS_FILE}" \
  --outdir "${OUTDIR}"
