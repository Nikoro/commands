---
sidebar_label: 'Enum Parameters'
---

# Enum Parameters

You can restrict the values of a parameter to a predefined set using the `values` key. This is useful for parameters that can only have a limited number of values.

## Enum with a default value

When you provide a default value, the user can override it with one of the allowed values.

```yaml
# commands.yaml

deploy: ## Deploy to environment
  script: |
    echo "Deploying to {env}"
  params:
    optional:
      - env: '-e, --environment'
        values: [dev, staging, prod]
        default: staging
```

`commands_cli` will validate the input and show an error if the value is not in the list.

```sh
$ deploy
Deploying to staging

$ deploy -e prod
Deploying to prod

$ deploy -e invalid
Invalid value 'invalid' for parameter env
Allowed values: dev, staging, prod
```

## Interactive Enum Picker

When you define an enum parameter **without** a default value, `commands_cli` will automatically present an interactive picker when the parameter is not provided:

```yaml
# commands.yaml

build: ## Build for platform
  script: |
    echo "Building for {platform}"
  params:
    optional:
      - platform: '-p, --platform'
        values: [ios, android, web]
```

If you run `build` without the `-p` flag, you will see this:

```sh
$ build

Select value for platform:

    1. ios
    2. android
    3. web

Press number (1-3) or press Esc to cancel:
```
