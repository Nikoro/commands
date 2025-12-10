---
sidebar_label: 'Typed Parameters'
---

# Typed Parameters

`commands_cli` supports a powerful type system for parameters, allowing you to define explicit types for better validation and user experience.

Supported types are: `int`, `double`, and `bool`.

## Numeric Types

You can explicitly specify `int` or `double` types for numeric parameters:

```yaml
# commands.yaml

deploy: ## Deploy application
  script: |
    echo "Deploying to port {port} with timeout {timeout}s"
  params:
    optional:
      - port: '-p, --port'
        type: int
        default: 3000
      - timeout: '-t, --timeout'
        type: double
        default: 30.5
```

`commands_cli` will validate the input and show an error if the type is incorrect.

```sh
$ deploy -p 8080 -t 60.0
Deploying to port 8080 with timeout 60.0s

$ deploy -p abc
Parameter port expects an [integer]
   Got: "abc" [string]
```

## Boolean Flags

Boolean parameters can be used as flags that can be toggled on/off.

```yaml
# commands.yaml

build: ## Build with options
  script: |
    echo "verbose={verbose} debug={debug}"
  params:
    optional:
      - verbose: '-v, --verbose'
        default: false
      - debug: '-d, --debug'
        default: true
```

When you run the command, the flags will toggle the default value.

```sh
$ build
verbose=false debug=true

$ build -v
verbose=true debug=true

$ build --debug
verbose=false debug=false

$ build -v --debug
verbose=true debug=false
```
