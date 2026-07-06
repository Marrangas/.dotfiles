#!/usr/bin/env bash

USER=$(gcloud auth list --filter="status:ACTIVE" --format="value(account)" 2>/dev/null)
ORG=449047059751


if [[ -z "$USER" ]]; then
    echo "WARNING: No active gcloud account found. Some functions may not work correctly. Please run 'gcloud auth login'." >&2
    USER="unknown_user"
fi

VERSION="${_CMD}/v0.1(alpha)"
GCP_LOG_PROJECT="${GCP_LOG_PROJECT:-dia-oficina-cloud}"
GCP_LOG_NAME="${GCP_LOG_NAME:-oficina-cloud-custom}"
GCP_LOG_SA="${GCP_LOG_SA:-not_impersonated}"
GCP_LOG_VERSION="${GCP_LOG_VERSION:-v1.0}"
GCP_ORGANIZATION="organizations/449047059751"
VERBOSITY="${VERBOSITY:-INFO}"
SET_INTERACTIVE="${SET_INTERACTIVE:-true}"
JOB_NUM="${JOB_NUM:-1}"

B=$(tput bold)   # bold
nor=$(tput sgr0) # normal mode, reset format

if [[ -t 1 ]] && tput setaf 1 >&/dev/null; then
    r=$(tput setaf 1)  # red
    g=$(tput setaf 2)  # green
    y=$(tput setaf 3)  # yellow
    b=$(tput setaf 4)  # blue
    mg=$(tput setaf 5) # magenta
    cy=$(tput setaf 6) # cyan
    w=$(tput setaf 7)  # white
else
    r="" g="" y="" b="" mg="" cy="" w=""
fi

