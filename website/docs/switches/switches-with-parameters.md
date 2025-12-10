---
sidebar_label: 'Switches with Parameters'
---

# Switches with Parameters

Each option in a `switch` can have its own set of parameters. This allows you to create complex and powerful commands.

## Defining Parameters for a Switch

You can add a `params` key to any switch option, just like with a regular command.

```yaml
# commands.yaml

deploy: ## Deploy with configuration
  switch:
    - staging: ## Deploy to staging
      script: |
        echo "Deploying to staging with {replicas} replicas"
      params:
        optional:
          - replicas: '-r, --replicas'
            type: int
            default: 2
    - production: ## Deploy to production
      script: |
        echo "Deploying to production with {replicas} replicas"
      params:
        optional:
          - replicas: '-r, --replicas'
            type: int
            default: 5
    - default: staging
```

## Running a Switch with Parameters

You can pass parameters to the switch option as you would with a regular command.

```sh
$ deploy
Deploying to staging with 2 replicas

$ deploy production -r 10
Deploying to production with 10 replicas
```

The parameters for one option are not available for the other options. For example, you can't use the `-r` flag with the `staging` option in this example if it was only defined for `production`.
