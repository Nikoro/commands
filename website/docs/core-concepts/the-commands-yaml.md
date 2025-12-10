---
sidebar_label: 'The commands.yaml file'
---

# The `commands.yaml` file

The `commands.yaml` file is the heart of `commands_cli`. It's where you define all your custom commands in a simple, human-readable format.

## Basic Structure

The basic structure of a command in `commands.yaml` is as follows:

```yaml
<command_name>: ## <command_description>
  script: |
    # Your script goes here
```

-   `<command_name>`: The name of your command. This is what you will type in the terminal to run the script.
-   `<command_description>`: An optional description for your command. This will be shown when you run `commands` or `command --help`.
-   `script`: The script to be executed. You can use multi-line scripts using the `|` character.

### Example

Here is a simple example of a command that prints "Hello, World!":

```yaml
# commands.yaml

hello: ## A simple hello world command
  script: echo "Hello, World!"
```

After running `commands` to activate it, you can execute it like this:

```sh
$ hello
Hello, World!
```
