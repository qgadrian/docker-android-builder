#!/bin/bash

while [[ $# -gt 1 ]]; do
  case $1 in
    -h|--help)
      # show help
      echo "Showing help"
      exit 0
    ;;
    -d|--devices)
      DEVICES="$2"
      shift # past argument
    ;;
    -s|--sdks)
      SDKS="$2"
      shift # past argument
    ;;
    -l|--locales)
      LOCALES="$2"
      shift # past argument
    ;;
    -p|--project)
      PROJECT="$2"
      shift # past argument
    ;;
    -o|--orientations)
      ORIENTATIONS="$2"
      shift # past argument
    ;;
    -n|--network-profile)
      NETWORK_PROFILE="$2"
      shift # past argument
    ;;
    -r|--apk-release-path)
      PROD_APK_PATH="$2"
      shift # past argument
    ;;
    -t|--apk-test-path)
      TEST_APK_PATH="$2"
      shift # past argument
    ;;
  esac
    shift # past argument or value
done

PROJECT="${PROJECT-""}"
DEVICES="${DEVICES-"Nexus5"}"
SDKS="${SDKS-"23"}"
LOCALES="${LOCALES-"en"}"
ORIENTATIONS="${ORIENTATIONS-"portrait"}"
PROD_APK_PATH="${PROD_APK_PATH-"app-prod-release.apk"}"
NETWORK_PROFILE="${NETWORK_PROFILE-"LTE"}"
TEST_APK_PATH="${TEST_APK_PATH-"app-prod-release-androidTest.apk"}"

echo "Authenticating service account in google cloud..."

gcloud auth activate-service-account ${FIREBASE_SERVICE_ACCOUNT_EMAIL} --key-file=${FIREBASE_API_SECRET_FILE_PATH}

echo "Using project [${PROJECT}] for firebase tests..."
echo ""

gcloud config set project ${PROJECT}

echo "Testing project with the following configurations:"
echo "Devices: [${DEVICES}]"
echo "SDK's: [${SDKS}]"
echo "Network profile: [${NETWORK_PROFILE}]"
echo "Locales: [${LOCALES}]"
echo "Orientations: [${ORIENTATIONS}]"
echo ""

gcloud firebase test android run \
  --type instrumentation \
  --app ${PROD_APK_PATH} \
  --test ${TEST_APK_PATH} \
  --device-ids ${DEVICES} \
  --os-version-ids ${SDKS} \
  --network-profile ${NETWORK_PROFILE} \
  --locales ${LOCALES} \
  --orientations ${ORIENTATIONS}
