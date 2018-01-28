#!/bin/bash

# exit if a command fails
set -e

#
# Required parameters
if [ -z "${app_path}" ] ; then
  echo " [!] Missing required input: app_path"
  exit 1
fi
if [ ! -f "${app_path}" ] ; then
  echo " [!] File doesn't exist at specified path: ${app_path}"
  exit 1
fi
if [ -z "${app_center_app}" ] ; then
  echo " [!] Missing required input: app_center_app"
  exit 1
fi
if [ -z "${app_center_token}" ] ; then
  echo " [!] Missing required input: app_center_token"
  exit 1
fi


# ---------------------
# --- Configs:

echo " (i) Provided app path: ${app_path}"
echo " (i) Provided app center app: ${app_center_app}"
echo " (i) Provided app center token: ********"
echo

# ---------------------
# --- Main

LAUNCH_TEST_DIR="${BITRISE_SOURCE_DIR}/app-center-launch-test-android"
OUTPUT_PATH="${LAUNCH_TEST_DIR}/GeneratedTest"
ARTIFACTS_DIR="${LAUNCH_TEST_DIR}/Artifacts"
SOLUTION="${OUTPUT_PATH}/AppCenter.UITest.Android.sln"
BUILD_DIR="${OUTPUT_PATH}/AppCenter.UITest.Android/bin/Release"
MANIFEST_PATH="${ARTIFACTS_DIR}/manifest.json"

npm install appcenter-cli@1.0.8 -g
appcenter test generate uitest --platform android --output-path "${OUTPUT_PATH}"
nuget restore -NonInteractive "${SOLUTION}"
msbuild "${SOLUTION}" /p:Configuration=Release
appcenter test prepare uitest --artifacts-dir "${ARTIFACTS_DIR}" --app-path "${app_path}" --build-dir "${BUILD_DIR}" --debug --quiet
appcenter test run manifest --manifest-path "${MANIFEST_PATH}" --app-path "${app_path}" --app "${app_center_app}" --devices any_top_1_device --test-series launch-tests --locale en_US --debug --quiet --token "${app_center_token}"

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
