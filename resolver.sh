#!/usr/bin/env bash

echo
echo "Start"
echo
echo "Input arguments:"
echo
echo "ENVS_HOME: ${ENVS_HOME}"
echo
echo "GITHUB_BRANCH: ${GITHUB_BRANCH}"
echo "GITHUB_EVENT_NAME: ${GITHUB_EVENT_NAME}"

PAGES_PRODUCTION_BRANCH="${PAGES_PRODUCTION_BRANCH:-main}"
echo "PAGES_PRODUCTION_BRANCH: ${PAGES_PRODUCTION_BRANCH}"

PRODUCTION_VITE_MODE="${PRODUCTION_VITE_MODE:-production}"
echo "PRODUCTION_VITE_MODE: ${PRODUCTION_VITE_MODE}"

echo "STAGE: ${STAGE}"
echo "PROJECT_NAME: ${PROJECT_NAME}"

echo
DEFAULT_STAGE="${DEFAULT_STAGE:-pre1}"
echo "DEFAULT_STAGE: ${DEFAULT_STAGE}"

DEFAULT_VITE_MODE="${DEFAULT_VITE_MODE:-$DEFAULT_STAGE}"
echo "DEFAULT_VITE_MODE: ${DEFAULT_VITE_MODE}"

DEFAULT_PAGES_BRANCH_NAME="${DEFAULT_PAGES_BRANCH_NAME:-$DEFAULT_STAGE}"
echo "DEFAULT_PAGES_BRANCH_NAME: ${DEFAULT_PAGES_BRANCH_NAME}"
echo

fail() {
  echo "Fail!"
  echo $*
  exit 1
}

success() {
  echo "Success"
  exit 0
}

if [ -z "${PROJECT_NAME}" ]; then
  fail "PROJECT_NAME is not defined"
fi

if [ -z "${ENVS_HOME}" ]; then
  fail "ENVS_HOME is not defined"
fi

if [ -z "${STAGE}" ]; then
  STAGE=${DEFAULT_STAGE}
  echo "Use default stage"
fi

if [ "${GITHUB_EVENT_NAME}" = "workflow_dispatch" ]; then
  echo "Manual dispatch detected"
else
  echo "Auto dispatch detected"
fi

echo
# Подтянуть переменные окружения для приложения

if [ "${STAGE}" == "production" ]; then
  vite_mode=${PRODUCTION_VITE_MODE}
  pages_branch_name=${PAGES_PRODUCTION_BRANCH}
else
  vite_mode=${STAGE}
  pages_branch_name=${STAGE}
fi

echo "Deploy to ${STAGE}, vite_mode=${vite_mode}, pages_branch_name=${pages_branch_name}"

ENVS_LINK="${ENVS_HOME}/${PROJECT_NAME}/.env.${STAGE}"

if echo ${ENVS_LINK} | grep http; then
  echo "Download envs from ${ENVS_LINK}"
  curl --fail -s -o .env ${ENVS_LINK} || fail "Can't download envs file ${ENVS_LINK}"
else
  echo "Copy ${ENVS_LINK} to .env"
  cp ${ENVS_LINK} .env || fail
fi

echo
echo "Output:"

echo "vite-mode: ${vite_mode}"
echo "vite-mode=${vite_mode}" >> $GITHUB_OUTPUT

echo "pages-branch-name: ${pages_branch_name}"
echo "pages-branch-name=${pages_branch_name}" >> $GITHUB_OUTPUT

success
