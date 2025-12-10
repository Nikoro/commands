---
sidebar_label: 'Positional Parameters'
---

# Positional Parameters

Positional parameters are arguments that are identified by their position in the command line. They are the simplest way to pass data to your commands.

## Defining Positional Parameters

You can define positional parameters under the `params` key in your `commands.yaml` file. They can be either `required` or `optional`.

```yaml
# commands.yaml

greet:
  script: echo "{greeting} {name}!"
  params:
    required:
      - greeting:
    optional:  
      - name:
```

- `greeting` is a required positional parameter.
- `name` is an optional positional parameter.

## Running commands with Positional Parameters

When you run the command, you need to provide the required parameters in the correct order.

```sh
$ greet Hi dev
Hi dev!

$ greet Yo
Yo !

$ greet
Missing required positional param: greeting
```

As you can see, if you don't provide a required parameter, `commands_cli` will show an error.
