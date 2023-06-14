#!/usr/bin/env bash
set -e

# ASCII banner
base64 -d <<<"CgogIF9fX19fICAgICAgICAgICAgICAgICBfX19fX18gX19fX18gIF9fX19fICAgX19fX18gICAgICAgICAgICAgXyAgICAgICAgICAgICAKIHwgIF9fIFwgICAgICAgICAgICAgICB8ICBfX19fLyBfX19ffC8gX19fX3wgfCAgX18gXCAgICAgICAgICAgfCB8ICAgICAgICAgICAgCiB8IHxfXykgfF9fIF8gX19fXyAgX18gfCB8X18gfCB8ICAgIHwgKF9fXyAgIHwgfCAgfCB8IF9fXyBfIF9fIHwgfCBfX18gIF8gICBfIAogfCAgX19fLyBfIFwgJ19fXCBcLyAvIHwgIF9ffHwgfCAgICAgXF9fXyBcICB8IHwgIHwgfC8gXyBcICdfIFx8IHwvIF8gXHwgfCB8IHwKIHwgfCAgfCAgX18vIHwgICA+ICA8ICB8IHxfX198IHxfX19fIF9fX18pIHwgfCB8X198IHwgIF9fLyB8XykgfCB8IChfKSB8IHxffCB8CiB8X3wgICBcX19ffF98ICAvXy9cX1wgfF9fX19fX1xfX19fX3xfX19fXy8gIHxfX19fXy8gXF9fX3wgLl9fL3xffFxfX18vIFxfXywgfAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8IHwgICAgICAgICAgICAgX18vIHwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfF98ICAgICAgICAgICAgfF9fXy8gCgo="

# Designed for use at Perx Health, this script allows us to easily deploy new
# images as ECS tasks with blue-green cutover assistance from CodeDeploy
source /work/common.sh
info "Getting things started..."

# ----- Check preflight variables -----
h1 "Preflight Step 1: Checking preflight environment variables"

if [ -z "$INPUT_PERX-ENV" ]; then
  error "\"\$INPUT_PERX-ENV\" must be set"
  exit 1
fi

if [ -z "$INPUT_PERX-REGION" ]; then
  error "\"\$INPUT_PERX-REGION\" must be set"
  exit 1
fi

if [ -z "$INPUT_PERX-APP-NAME" ]; then
  error "\"\$INPUT_PERX-APP-NAME\" must be set"
  exit 1
fi

if [ -z "$INPUT_TASK-DEFINITION" ]; then
  error "\"\$INPUT_TASK-DEFINITION\" must be set"
  exit 1
fi

if [ -z "$INPUT_IMAGE-NAME" ]; then
  error "\"\$INPUT_IMAGE-NAME\" must be set"
  exit 1
fi

if [ -z "$INPUT_IMAGE-TAG" ]; then
  error "\"\$INPUT_IMAGE-TAG\" must be set"
  exit 1
fi

if [ -z "$INPUT_AWS-ACCESS-KEY-ID" ]; then
  error "\"\$INPUT_AWS-ACCESS-KEY-ID\" must be set"
  exit 1
fi

if [ -z "$INPUT_AWS-SECRET-ACCESS-KEY" ]; then
  error "\"\$INPUT_AWS-SECRET-ACCESS-KEY\" must be set"
  exit 1
fi

if [ -z "$AWS_DEFAULT_REGION" ]; then
  error "\"\$AWS_DEFAULT_REGION\" must be set"
  exit 1
fi

# If we've come this far, we're all good in terms of required vars!
success "Required environment variables OK"

# Set AWS credentials so the CLI can find them
export AWS_ACCESS_KEY_ID=$INPUT_AWS-ACCESS-KEY-ID
export AWS_SECRET_ACCESS_KEY=$INPUT_AWS-SECRET-ACCESS-KEY

# Apply defaults to optional parameters which we'll be using either way
export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-721636788304}
export AWS_ACCOUNT_NAME=${AWS_ACCOUNT_NAME:-nonprod}
export AWS_REGION=${AWS_REGION:=$AWS_DEFAULT_REGION}
export CLUSTER_NAME=${CLUSTER_NAME:=$INPUT_PERX-ENV}
export ECR_REGION=${ECR_REGION:=ap-southeast-2}
export CONTAINER_PORT=${CONTAINER_PORT:-4000}
export FARGATE_CPU_SIZE=${FARGATE_CPU_SIZE:-512}
export FARGATE_MEMORY_SIZE=${FARGATE_MEMORY_SIZE:-1024}

success "Optional environment variables OK"

# ----- Prepare task definition -----
h1 "Preflight Step 2: Prepare task definition"

# TODO: Add checks ensuring conventions in task definition are enforced, e.g.
# that the following env vars are present FARGATE_CPU_SIZE, FARGATE_MEMORY_SIZE,
# CONTAINER_PORT etc

cp $INPUT_TASK-DEFINITION /work/task-definition.tpl.json
success "Task definition prepared OK"

# ----- Prepare final environment -----
h1 "Preflight Step 3: Prepare final environment"
export APP_NAME=$INPUT_PERX-APP-NAME
export IMAGE_NAME=651180711168.dkr.ecr.$ECR_REGION.amazonaws.com/$APP_NAME:$INPUT_IMAGE-TAG
success "Final environment prepared OK"

# ----- Start deployment -----
h1 "Preflight Step 4: Start deployment"

info "Delegating deployment work"
cd /work
bash ./deploy.sh
