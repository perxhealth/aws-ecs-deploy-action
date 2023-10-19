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
    perx_env: qa
    perx_region: au
    perx_app_name: behavioural-science-hacks
    image_tag: latest
```

### Inputs

The Action currently expects some required inputs and
some optional inputs.

**NOTE**: Input names are snake_case, not kebab-case.

#### Required

1. `perx_env`

    Name of the Perx Environment which the deploy will target.

2. `perx_region`

    Name of the Perx Region, representing locations on Earth and data
    sovereignty boundaries where the deploy will live.

3. `perx_app_name`

    Name of the application/service itself. This is expected to match the
    application/service's cluster/runner naming convention.

4. `image_tag`

    Append a tag to the image name before pushing. This is not optional as we
    do not recommend encouraging a default of `latest`.

#### Optional

1. `perx_db_env`

    If the application connects to a database, nominate the environment
    from which credentials are pulled

2. `image_name`

    Explicitly nominate the image's name (excluding tag) instead of
    inferring from `perx_app_name`

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

At the time of writing, there's no test suite to run.
