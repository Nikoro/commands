---
sidebar_label: 'Passthrough Arguments'
---

# Passthrough Arguments

The `...args` placeholder allows you to pass arguments from your command to the underlying script. This is what makes aliases so powerful.

## Basic Usage

When you add `...args` to your script, `commands_cli` will replace it with any extra arguments that you provide when you run the command.

```yaml
# commands.yaml

d: ## dart alias
  script: dart ...args
```

When you run `d --version`, `commands_cli` will execute `dart --version`.

## With Multi-line Scripts

You can also use `...args` in multi-line scripts. This is useful when you want to add some logging or other commands around your main script.

```yaml
# commands.yaml

analyze: ## dart analyze
  script: |
    echo "Analyzing ignoring warnings..."
    dart analyze ...args --no-fatal-warnings
```

Now, when you run `analyze --fatal-infos`, it will execute the following:

```sh
echo "Analyzing ignoring warnings..."
dart analyze --fatal-infos --no-fatal-warnings
```

```sh
$ analyze --fatal-infos
Analyzing ignoring warnings...
Analyzing example...                  0.5s
No issues found!
```
