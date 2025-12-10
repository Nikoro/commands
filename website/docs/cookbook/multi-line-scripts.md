---
sidebar_label: 'Multi-line Scripts'
---

# Multi-line Scripts

You can write multi-line scripts in your `commands.yaml` file using the `|` character. This is useful for more complex commands.

## Basic Multi-line Script

Here is an example of a command that runs `dart analyze` with some logging:

```yaml
# commands.yaml

analyze: ## dart analyze
  script: |
    echo "Analyzing ignoring warnings..."
    dart analyze --no-fatal-warnings
```

When you run `analyze`, it will execute both lines of the script.

```sh
$ analyze
Analyzing ignoring warnings...
Analyzing example...
No issues found!
```
