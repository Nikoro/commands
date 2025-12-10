---
sidebar_label: 'Features'
---

# Features

`commands_cli` is packed with features designed to make your command-line experience as smooth as possible.

## Interactive Pickers

When you define enum parameters or switch commands without defaults, `commands_cli` automatically presents a beautiful interactive menu.

```yaml
# commands.yaml

build: ## Build for platform
  script: echo "Building for {platform}"
  params:
    optional:
      - platform: '-p, --platform'
        values: [ios, android, web]
```

```sh
$ build

Select value for platform:

    1. ios
    2. android
    3. web

Press number (1-3) or press Esc to cancel:
```

## Automatic Help Generation

Every command automatically gets a `--help` (or `-h`) parameter. It collects information **from your defined parameters and optional comments** directly from the `commands.yaml` file, providing clear, up-to-date guidance without any extra work.

```yaml
# commands.yaml

hello: ## Prints "Hello {message}"
  script: echo "Hello {message}"
  params:
    required:
    - message: ## The name to include in the greeting
      default: "World"
```

```sh
$ hello --help
hello: Prints "Hello {message}"
params:
  required:
    message: The name to include in the greeting
      default: "World"
```

## Composable Commands

With `commands_cli`, you can define keyword chains that read like plain English.

- `build ios`
- `build android`
- `build web`
- `build all`
- `run all tests`
- `run integration tests`

This **switch**-based design makes commands easier to discover, remember, and use.
