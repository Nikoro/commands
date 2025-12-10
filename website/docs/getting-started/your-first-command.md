---
sidebar_label: 'Your First Command'
---

# Your First Command

Let's create a simple "Hello, World!" command to get a feel for how `commands_cli` works.

## 1. Create `commands.yaml`

You can either create a `commands.yaml` file in the root of your project, or you can type:

```sh
commands create
```

This will create a `commands.yaml` file pre-filled with a simple `hello` example:

```yaml
# commands.yaml

hello: ## Prints "Hello {message}"
  script: echo "Hello {message}"
  params:
    required:
    - message:
      default: "World"
```

## 2. Activate your commands

To make your new command available in your shell, run `commands` in your terminal:

```sh
$ commands
hello: Prints "Hello {message}"
```

`commands_cli` will parse your `commands.yaml` file and create executable scripts for each command.

## 3. Run your command

Now you can run your `hello` command directly:

```sh
$ hello
Hello World
```

You can also pass arguments to it:

```sh
$ hello dev
Hello dev
```

Congratulations! You have successfully created and run your first command with `commands_cli`.
