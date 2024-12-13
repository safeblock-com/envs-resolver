#!/usr/bin/env bash

echo "Test selector.sh"

export GITHUB_OUTPUT=".github-output"
echo > ${GITHUB_OUTPUT}

export GITHUB_ENV=".github-env"
echo > ${GITHUB_ENV}

echo "Запустили в ручную на main без стенда, катим не дефолтный разработческий"

GITHUB_BRANCH=main GITHUB_EVENT_NAME=workflow_dispatch DEFAULT_DEV_STAGE=dev ./selector.sh
