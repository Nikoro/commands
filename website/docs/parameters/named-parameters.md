---
sidebar_label: 'Named Parameters'
---

# Named Parameters

Named parameters are arguments that are identified by their name, not their position. This makes your commands more explicit and easier to read.

## Defining Named Parameters

You can define named parameters by providing flags (e.g., `-n, --name`).

```yaml
# commands.yaml

greet:
  script: echo "{greeting} {value}!"
  params:
    required:
      - greeting: '-g, --greeting'
    optional:  
      - value: '-n, --name'
```

- `greeting` is a required named parameter with the flags `-g` and `--greeting`.
- `value` is an optional named parameter with the flags `-n` and `--name`.

## Running commands with Named Parameters

When you run the command, you need to provide the required parameters using their flags. The order does not matter.

```sh
$ greet --greeting "Hi" --name "Alice"
Hi Alice!

$ greet --name "Bob" --greeting "Yo"
Yo Bob!

$ greet -g "Hi"
Hi !

$ greet
Missing required named param: greeting
```
