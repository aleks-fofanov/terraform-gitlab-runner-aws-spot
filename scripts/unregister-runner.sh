#!/usr/bin/env bash

set -e

function Usage() {
    cat <<EOM
##### Unregister Gitlab runner using its authentication token #####

This scripts allows to unregister Gitlab runner via Gitlab API v4 using its
authentication token. Registration token is not the same as authentication
token. It is obtained either automatically when registering a Runner, or
manually when registering the Runner via the Runners API.
Please refer to the following link for more context:
https://docs.gitlab.com/ee/api/runners.html#registration-and-authentication-tokens

It is also possible to pass SSM parameter name that contains the authentication
token instead of passing the authentication token explicitly through arguments.

Author: Aleksandr Fofanov

Required arguments:
    -t | --token              Runner's authentication token
    -p | --ssm-param          A name of SSM param

Optional arguments:
    -u | --gitlab-url         Gitlab URL. Defaults to https://gitlab.com
    -r | --region             AWS Region
    -h | --help               Show this message and exit

Requirements:
    aws:                      AWS CLI
    jq:                       Command line JSON-processor
    curl:                     CLI tool for transferring data with URLs

Example:
    unregister-runner.sh -t AUTH_TOKEN
    unregister-runner.sh -p /gitlab/runner/token
EOM
    exit 127
}

function Require {
    command -v $1 > /dev/null 2>&1 || {
        echo "Some of the required software is not installed: $1"
        exit 1;
    }
}

Require aws
Require jq
Require curl

if [[ $# == 0 ]] ; then Usage; fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--token)
        AUTH_TOKEN="${2}"
        shift
        ;;
    -p|--ssm-param)
        SSM_PARAM_NAME="${2}"
        shift
        ;;
    -r|--region)
        REGION="${2}"
        shift
        ;;
    -u|--gitlab-url)
        GITLAB_URL="${2}"
        shift
        ;;
    -h|--help)
        Usage
        ;;
    *)
        echo "Unknown argument: ${1}. Pass -h or --help to see usage"
        exit 3
        ;;
  esac
  shift
done

GITLAB_URL=${GITLAB_URL:-"https://gitlab.com"}

if [[ -z ${AUTH_TOKEN} ]] && [[ -z ${SSM_PARAM_NAME} ]]; then
    echo "Either runner's authentication token or SSM Parameter name which contains it is required"
    exit 2
fi

if [[ ! -z ${REGION} ]]; then
    REGION_CLAUSE="--region ${REGION}"
fi

if [[ ! -z ${SSM_PARAM_NAME} ]]; then
    AUTH_TOKEN=$(aws ssm get-parameter --with-decryption --name ${SSM_PARAM_NAME} ${REGION_CLAUSE} | jq -r ".Parameter.Value")
fi

if [[ "${AUTH_TOKEN}" == "" ]] || [[ "${AUTH_TOKEN}" == "empty" ]] || [[ "${AUTH_TOKEN}" == "null" ]]; then
    echo "Auth is either an empty string or a string container 'null' or 'empty' value"
    exit 2
fi

# Links:
# https://docs.gitlab.com/ee/api/runners.html#delete-a-registered-runner

curl -X DELETE -sSL "${GITLAB_URL}/api/v4/runners" -F "token=${AUTH_TOKEN}"
