---
sidebar_label: 'Default Values'
---

# Default Values

You can provide default values for optional parameters. This is useful when you want to make your commands easier to use.

## Defining Default Values

You can define a default value using the `default` key.

```yaml
# commands.yaml

goodbye:
  script: echo "Goodbye, {name}{punctuation}"
  params:
    optional:
      - name:
        default: "World"
      - punctuation:
        default: "!"
```

- `name` is an optional positional parameter with a default value of "World".
- `punctuation` is an optional positional parameter with a default value of "!".

## Running commands with Default Values

If you don't provide a value for an optional parameter, the default value will be used.

```sh
$ goodbye
Goodbye, World!

$ goodbye Bob .
Goodbye, Bob.
```

You can also use default values with named parameters:

```yaml
# commands.yaml

hello: ## Prints "Hello {message}"
  script: echo "Hello {message}"
  params:
    optional:
    - message: '-m, --message'
      default: "World"
```

```sh
$ hello
Hello World

$ hello -m dev
Hello dev
```
