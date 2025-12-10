---
sidebar_label: 'Aliases'
---

# Aliases

You can use `commands_cli` to create simple aliases for longer commands. This is useful for commands that you use frequently.

## Basic Alias

Here is an example of how to create an alias for the `dart` command:

```yaml
# commands.yaml

d: ## dart alias
  script: dart ...args
```

Here, `...args` is a placeholder that automatically forwards any parameters you pass to the alias into the underlying command. We will learn more about this in the next section.

After activating the command with `commands`, you can run `d --version` which will expand to `dart --version`.

<pre><code class="language-sh">$ d --version
Dart SDK version: 3.9.0...</code></pre>

This allows you to create concise aliases while still keeping the flexibility to inject flags, options, or arguments dynamically at runtime.
