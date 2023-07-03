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

if [ -z "$INPUT_PERX_ENV" ]; then
  error "\"\$INPUT_PERX_ENV\" must be set"
  exit 1
fi

if [ -z "$INPUT_PERX_REGION" ]; then
  error "\"\$INPUT_PERX_REGION\" must be set"
  exit 1
fi

if [ -z "$INPUT_PERX_APP_NAME" ]; then
  error "\"\$INPUT_PERX_APP_NAME\" must be set"
  exit 1
fi

if [ -z "$INPUT_TASK_DEFINITION" ]; then
  error "\"\$INPUT_TASK_DEFINITION\" must be set"
  exit 1
fi

if [ -z "$INPUT_IMAGE_TAG" ]; then
  error "\"\$INPUT_IMAGE_TAG\" must be set"
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  error "\"\$AWS_ACCESS_KEY_ID\" must be set. Have you assumed a role?"
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  error "\"\$AWS_SECRET_ACCESS_KEY\" must be set. Have you assumed a role?"
  exit 1
fi

if [ -z "$AWS_SESSION_TOKEN" ]; then
  error "\"\$AWS_SESSION_TOKEN\" must be set. Have you assumed a role?"
  exit 1
fi

if [ -z "$AWS_DEFAULT_REGION" ]; then
  error "\"\$AWS_DEFAULT_REGION\" must be set"
  exit 1
fi

# If we've come this far, we're all good in terms of required vars!
success "Required environment variables OK"

# Apply defaults to optional parameters which we'll be using either way
export AWS_REGION=${AWS_REGION:=$AWS_DEFAULT_REGION}
export CLUSTER_NAME=${CLUSTER_NAME:=$INPUT_PERX_ENV}
export ECR_REGION=${ECR_REGION:=ap-southeast-2}
export CONTAINER_PORT=${CONTAINER_PORT:-4000}
export FARGATE_CPU_SIZE=${FARGATE_CPU_SIZE:-512}
export FARGATE_MEMORY_SIZE=${FARGATE_MEMORY_SIZE:-1024}

# Set AWS_REGION according to the cluster we're
# deploying in to
if [[ $CLUSTER_NAME -eq "au" ]]
then
  export AWS_REGION="ap-southeast-2"
else
  export AWS_REGION="us-east-1"
fi

success "Optional environment variables OK"

# ----- Prepare task definition -----
h1 "Preflight Step 2: Prepare task definition"

# TODO: Add checks ensuring conventions in task definition are enforced, e.g.
# that the following env vars are present FARGATE_CPU_SIZE, FARGATE_MEMORY_SIZE,
# CONTAINER_PORT etc

cp $INPUT_TASK_DEFINITION /work/task-definition.tpl.json
success "Task definition prepared OK"

# ----- Prepare final environment -----
h1 "Preflight Step 3: Prepare final environment"

export AWS_ACCOUNT_ID=721636788304 # TODO: add prod compatibility
export AWS_ACCOUNT_NAME=nonprod # TODO: add prod compatibility

export PERX_ENV=$INPUT_PERX_ENV
export PERX_APP_NAME=$INPUT_PERX_APP_NAME
export PERX_REGION=$INPUT_PERX_REGION

export APP_NAME=$PERX_APP_NAME
export IMAGE_NAME=651180711168.dkr.ecr.$ECR_REGION.amazonaws.com/$APP_NAME:$INPUT_IMAGE_TAG

success "Final environment prepared OK"

# ----- Start deployment -----
h1 "Preflight Step 4: Start deployment"

info "Delegating deployment work"
cd /work
bash ./deploy.sh
