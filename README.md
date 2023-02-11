![Perx Health](https://user-images.githubusercontent.com/4101096/163123610-9dfa9263-1518-4f5d-8839-9ddc142a513e.png)

# AWS ECS Deploy

**Note:** This action is designed for use within Perx Health's infrastructure...
it might not be very useful for other scenarios!

This repository contains a **GitHub Action** allowing you to deploy new builds
to AWS ECS by creating a new Task Definition and Task from said definition.

## Usage Example

As an example, add the following `step` to a GitHub Actions workflow.

```yaml
- name: 🚀 Deploy QA
  uses: perxhealth/aws-ecs-deploy-action@v1
  with:
    perx-env: qa
    perx-region: au
    perx-app-name: behavioural-science-hacks
    image-name: behavioural-science-hacks
    image-tag: latest
```

### Inputs

The Action currently expects five required inputs, and no further optional
inputs.

1. `perx-env`

    Name of the Perx Environment which the deploy will target.

2. `perx-region`

    Name of the Perx Region, representing locations on Earth and data
    sovereignty boundaries where the deploy will live.

3. `perx-app-name`

    Name of the application/service itself. This is expected to match the
    application/service's cluster/runner naming convention.

4. `image-name`

    Name of the Docker image which will be pushed up to ECR. This is **not**
    expected to contain a tag.

5. `image-tag`

    Append a tag to the image name before pushing. This is not optional as we
    do not recommend encouraging a default of `latest`.

### Outputs

The Action currently produces no outputs.

## AWS Credentials

The Action currently expects AWS credentials to exist in the environment, with
sufficient permissions to perform the following actions.

### ECS

- `DescribeTasks`
- `RegisterTaskDefinition`
- `RunTask`

## Development

As this is a Docker based action which uses bash scripts to do its job, there
is not any specific development steps to follow.

If you wish to contribute, open up `action/entrypoint.sh` and get clacking!

### Docker

[Visit this page](https://docs.docker.com/get-docker/) to get instructions on
how to install Docker, if you haven't already

### Clone the repository

```bash
$ git clone git@github.com:perxhealth/aws-ecs-deploy-action.git
$ cd aws-ecs-deploy-action
```

### Testing

At the time of writing, there's no test suite to run. We will be adding test
coverage soon!
