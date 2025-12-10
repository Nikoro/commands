---
sidebar_label: 'Overriding Commands'
---

# Overriding Commands

You can override built-in shell commands like `ls`, `cd`, or `make`. This allows you to create custom versions of these commands that are specific to your project.

## The `override` flag

To override a command, you need to set the `override` flag to `true`.

```yaml
# commands.yaml

ls: ## custom ls
  override: true # required when overriding reserved commands
  script: echo "ls is overridden!"
```

## PATH configuration

For the overridden commands to be executed, your shell needs to find them before the built-in commands. To achieve this, you need to make sure that the `.pub-cache/bin` directory is at the beginning of your `PATH` environment variable.

Instead of:

```sh
# .zshrc

export PATH="$PATH:$HOME/.pub-cache/bin"
```

You should have:

```sh
# .zshrc

export PATH="$HOME/.pub-cache/bin:$PATH"
```

After changing your `.zshrc` (or equivalent), you need to reload your shell configuration:

```sh
$ source ~/.zshrc
```

And you might need to reset the command hash table:

```sh
$ hash -r
```

## Special cases: `test` and `which`

On POSIX shells (bash, zsh, sh), `test` and `which` are shell builtins. This means the shell will execute its own version of these commands before looking in your `$PATH`.

To work around this, you can shadow them with functions in your shell configuration file:

```sh
# .zshrc

# Shadow the builtin "test" with a function
test() {
  # Explicitly call the system binary unless PATH provides an override
  command test "$@"
}

# Shadow the builtin "which" with a function
which() {
  # Explicitly call the system binary unless PATH provides an override
  command which "$@"
}
```

This will make sure that your custom commands are executed instead of the built-ins.
