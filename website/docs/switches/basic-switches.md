---
sidebar_label: 'Basic Switches'
---

# Basic Switches

The `switch` feature allows you to create commands with multiple named sub-options, enabling natural command structures like `build ios`, `build android`, or `run tests`.

## Defining a Switch

Instead of a `script`, you can define a `switch` with a list of options. Each option has a name, a description, and a script.

```yaml
# commands.yaml

build: ## Build application
  switch:
    - ios: ## Build for iOS
      script: flutter build ios
    - android: ## Build for Android
      script: flutter build apk
    - web: ## Build for web
      script: flutter build web
```

## Running a Switch Command

You can run a switch command by providing the name of the option as an argument.

```sh
$ build android
Building Android...

$ build web
Building web app...
```

## Default Switch

You can also provide a `default` option. This option will be executed if no other option is provided.

```yaml
# commands.yaml

build: ## Build application
  switch:
    - ios: ## Build for iOS
      script: flutter build ios
    - android: ## Build for Android
      script: flutter build apk
    - default: ios
```

```sh
$ build
Building iOS...
```
