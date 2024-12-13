#!/usr/bin/env bash

ENVS_FILE=envs-list.txt
ENVS_FILE_URL="${ENVS_HOME}/${ENVS_FILE}"

echo "Input arguments:"
echo
echo "ENVS_HOME: ${ENVS_HOME}"
echo
echo "GITHUB_BRANCH: ${GITHUB_BRANCH}"
echo "GITHUB_EVENT_NAME: ${GITHUB_EVENT_NAME}"
echo "GITHUB_PRODUCTION_BRANCH: ${GITHUB_PRODUCTION_BRANCH}"

PAGES_PRODUCTION_BRANCH="${PAGES_PRODUCTION_BRANCH:-main}"
echo "PAGES_PRODUCTION_BRANCH: ${PAGES_PRODUCTION_BRANCH}"

PRODUCTION_VITE_MODE="${PRODUCTION_VITE_MODE:-production}"
echo "PRODUCTION_VITE_MODE: ${PRODUCTION_VITE_MODE}"

echo "STAGE: ${STAGE}"
echo "PROJECT_NAME: ${PROJECT_NAME}"

echo
DEFAULT_DEV_STAGE="${DEFAULT_DEV_STAGE:-pre1}"
echo "DEFAULT_DEV_STAGE: ${DEFAULT_DEV_STAGE}"

DEFAULT_VITE_MODE="${DEFAULT_VITE_MODE:-$DEFAULT_DEV_STAGE}"
echo "DEFAULT_VITE_MODE: ${DEFAULT_VITE_MODE}"

DEFAULT_PAGES_BRANCH_NAME="${DEFAULT_PAGES_BRANCH_NAME:-$DEFAULT_DEV_STAGE}"
echo "DEFAULT_PAGES_BRANCH_NAME: ${DEFAULT_PAGES_BRANCH_NAME}"
echo

if [ -n "${ENVS_HOME}"]; then
  fail "ENVS_HOME is not defined"
fi

fail() {
  echo $*
  exit 1
}

success() {
  echo "Success"
  exit 0
}

if [ "${GITHUB_EVENT_NAME}" = "workflow_dispatch" ]; then
  echo "Manual dispatch detected"

  if [-n "${STAGE}"]; then
    $vite_mode=${DEFAULT_VITE_MODE}
    $pages_branch_name=${DEFAULT_PAGES_BRANCH_NAME}
    echo "Deploy to default dev stage ${pages_branch_name}"
  else
    # TODO Download list?
    #
    curl -sq --failt ${ENVS_FILE_URL} > ${ENVS_FILE} || fail "Can't download ${ENVS_FILE_URL}"
    grep ${STAGE} ${ENVS_FILE} || fail "No such stage (${STAGE}) found in the list ${ENVS_FILE}"
    $vite_mode=${STAGE}
    $pages_branch_name=${STAGE}
    echo "Deploy to stage ${STAGE}"

  fi

else
  echo "Auto dispatch detected"

  if [ "${GITHUB_PRODUCTION_BRANCH}" = "${GITHUB_BRANCH}"]; then
    echo "Deploy to production!"
    $vite_mode=${PRODUCTION_VITE_MODE}
    $pages_branch_name=${PAGES_PRODUCTION_BRANCH}
  else
    $vite_mode=${DEFAULT_VITE_MODE}
    $pages_branch_name=${DEFAULT_PAGES_BRANCH_NAME}
    echo "Deploy to default dev stage ${pages_branch_name}"
  fi
fi

echo
# Подтянуть переменные окружения для приложения
echo "Setup variables for stage ${STAGE}"

ENVS_LINK="${ENVS_HOME}/${PROJECT_NAME}/.env.${STAGE}"


if echo ${ENVS_LINK} | grep http; then
  echo "Download envs from ${ENVS_LINK}"
  curl --fail -s -o .env ${ENVS_LINK} || fail "Can't download envs file ${ENVS_LINK}"
else
  echo "Copy ${ENVS_LINK} to .env"
  cp ${ENVS_LINK} .env
fi

echo
echo "Output:"

echo "vite-mode: ${vite_mode}"
echo "vite-mode=${vite_mode}" >> $GITHUB_OUTPUT

echo "pages-branch-name: ${pages_branch_name}"
echo "pages-branch-name=${pages_branch_name}" >> $GITHUB_OUTPUT

success
