---
sidebar_label: 'Interactive Switches'
---

# Interactive Switches

When no `default` option is specified for a switch command, `commands_cli` presents a beautiful interactive menu to choose from.

## Defining an Interactive Switch

To create an interactive switch, simply define a `switch` without a `default` option.

```yaml
# commands.yaml

deploy: ## Deploy application
  switch:
    - staging: ## Deploy to staging
      script: ./deploy.sh staging
    - production: ## Deploy to production
      script: ./deploy.sh production
```

## Running an Interactive Switch

If you run `deploy` without any arguments, you will see the interactive picker:

```sh
$ deploy

Select an option for deploy:

    1. staging - Deploy to staging
    2. production - Deploy to production

Press number (1-2) or press Esc to cancel:
```

You can still run the command with an argument as usual:

```sh
$ deploy staging
Deploying to staging...
```
