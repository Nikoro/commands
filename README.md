<p align="center">
  <a alt="Commands CLI Logo" href="https://pub.dev/packages/commands_cli"><img src="https://raw.githubusercontent.com/nikoro/commands_cli/main/website/static/img/logo.webp" width="500"/></a>
</p>
<p align="center">
  <a href="https://pub.dev/packages/commands_cli">
    <img alt="Pub Package" src="https://tinyurl.com/2pc2ny7f">
  </a>
  <a href="https://github.com/Nikoro/commands_cli/actions">
    <img alt="Build Status" src="https://img.shields.io/github/actions/workflow/status/Nikoro/commands_cli/ci.yaml?label=build">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT License" src="https://tinyurl.com/3uf9tzpy">
  </a>
  <a href="https://nikoro.github.io/commands_cli/docs">
    <img alt="Documentation" src="https://tinyurl.com/hvzj2wx9">
  </a>
</p>

A simple, yet powerful command-line interface (CLI) tool to define and run project-local commands, similar to a `Makefile`. 

This package allows you to create a `commands.yaml` file in your project's root directory and define a set of keywords, which can then be executed from the command line.

<p align="center">
  <img src="https://raw.githubusercontent.com/nikoro/commands_cli/main/website/static/img/demo.webp" alt="Demo" width="800"/>
</p>

## Why use [`commands`](https://pub.dev/packages/commands_cli) instead of `Makefile`? 🤔

While `Makefile` is a powerful and widely used tool, [`commands_cli`](https://pub.dev/packages/commands_cli) offers several advantages for modern development workflows, especially for Dart and Flutter projects:

*   **Cross-platform Compatibility:** [`commands_cli`](https://pub.dev/packages/commands_cli) is written in Dart and runs on any platform where the Dart SDK is available. This means your commands will work consistently across **macOS**, **Linux**, and **Windows**.

*   **Simplicity and Readability:** `commands.yaml` uses the clean and human-readable YAML format. This makes your scripts easier to read, write, and maintain, even for teammates who aren’t familiar with traditional Makefiles.

    ```yaml
    # commands.yaml

    tests: ## Run all tests with coverage
      script: flutter test --coverage --no-pub
    ```

    <pre><code class="language-sh">$ tests
    00:00 <span style="color:#BBD99E;font-weight:bold;">+1</span>: All tests passed!</code></pre>

*   **Structured Parameters:** [`commands_cli`](https://pub.dev/packages/commands_cli) lets you define both **positional** and **named** parameters in a clear, structured way. Parameters can be **required** or **optional**, and you can set **default** values when needed. This makes your commands self-documenting, easy to use, and far more powerful than Makefile's limited and often clumsy parameter handling.

    ```yaml
    # commands.yaml

    tell:
      script: echo "{message} {name}"
      params:
        required:
          - message:
        optional:  
          - name: '-n, --name'
    ```
    <pre><code class="language-sh">$ tell hello
    hello
    
    $ tell Goodbye -n Makefile
    Goodbye Makefile

    $ tell 
    ❌ Missing required positional param: <span style="color:#FFB3B3;font-weight:bold;">message</span></code></pre>
    
*   **Strong Type System:** Unlike Makefile's string-based approach, [`commands_cli`](https://pub.dev/packages/commands_cli) supports a powerful type system with **int**, **double**, **boolean**, and **enum** types. This provides built-in validation, preventing common errors and making your commands more robust.

    ```yaml
    # commands.yaml

    deploy: ## Deploy with replicas
      script: echo "Deploying with {replicas} replicas"
      params:
        optional:
          - replicas: '-r, --replicas'
            type: int
            default: 3
    ```
    <pre><code class="language-sh">$ deploy -r 5
    Deploying with 5 replicas

    $ deploy -r abc
    ❌ Parameter <span style="font-weight:bold;"><span style="color:#FFB3B3;">replicas</span></span> expects an <span style="color:#808997;">[integer]</span>
       Got: "abc" <span style="color:#808997;">[string]</span></code></pre>

*   **Built-in Interactive Pickers:** When you define enum parameters or switch commands without defaults, [`commands_cli`](https://pub.dev/packages/commands_cli) automatically presents a beautiful interactive menu. No need to parse input manually or write custom prompts—it's all handled for you.

    ```yaml
    # commands.yaml

    build: ## Build for platform
      script: echo "Building for {platform}"
      params:
        required:
          - platform: '-p, --platform'
            values: [ios, android, web]
    ```
    <pre><code class="language-sh">$ build
    
    Select value for <span style="color:#ACD1F5;">platform</span>:
    
        <span style="color:#BBD99E;">1. ios     ✓</span>
        2. android
        3. web
    
    <span style="color:#808997;">Press number (1-3) or press Esc to cancel:</span></code></pre>

*   **Automatic Help Generation:** Every command automatically gets a `--help` (or `-h`) parameter. It collects information **from your defined parameters and optional comments** directly from the `commands.yaml` file, providing clear, up-to-date guidance without any extra work.

    ```yaml
    # commands.yaml

    hello: ## Prints "Hello {message}"
      script: echo "Hello {message}"
      params:
        required:
        - message: ## The name to include in the greeting
          default: "World"
    ```
    <pre><code class="language-sh">$ hello --help
    <span style="color:#ACD1F5;font-weight:bold;">hello</span>: <span style="color:#808997;">Prints "Hello {message}"</span>
    params:
      required:
        <span style="color:#C792EA;">message</span>: <span style="color:#808997;">The name to include in the greeting</span>
          default: "World"</code></pre>

*   **Composable, Human-Readable Commands:** With [`commands_cli`](https://pub.dev/packages/commands_cli), you can define keyword chains that read like plain English. Instead of cryptic flags, you can run natural phrases such as: 
    - `build ios`
    - `build android`
    - `build web`
    - `build all`
    - `run all tests`
    - `run integration tests` 
    - …and more

    This **switch**-based design makes commands easier to discover, remember, and use.

## Getting Started 🚀

1.  **Activate the package:**

    ```sh
    $ dart pub global activate commands_cli
    ```

2.  **Create a `commands.yaml` file in the root of your project or type:**

     ```sh
    $ commands create
    ```

    > This will create this `commands.yaml` for you,
    >
    > already pre-filled with a simple `hello` example.

3.  **Define your commands:**
    ```yaml
    # commands.yaml

    hello: ## Prints "Hello {message}"
      script: echo "Hello {message}"
      params:
        required:
        - message:
          default: "World"
    ```
    See the [Usage](#usage) and [Examples](#examples) sections below for more details.

4.  **Activate your defined commands:**

    <pre><code class="language-sh">$ commands
    ✅ <span style="color:#C9E2AF;font-weight:bold;">hello</span>: <span style="color:#808997;">Prints "Hello {message}"</span></code></pre>

5. **Run your defined commands:** 

    ```sh
    $ hello
    Hello World

    $ hello dev
    Hello dev
    ```

## Usage

The `commands.yaml` file has a simple structure:

```yaml
<command_name>: ## <command_description>
  script: |
    # Your script goes here
  params:
    required:
      - <param_name>: '<flags>' ## <param_description>
        default: <default_value>
    optional:
      - <param_name>: '<flags>' ## <param_description>
        default: <default_value>
```

*   `<command_name>`: The name of your command.
*   `<command_description>`: An optional description for your command.
*   `script`: The script to be executed. You can use multi-line scripts using the `|` character.
*   `params`: An optional section to define parameters for your command.
*   `required`: A list of required parameters.
*   `optional`: A list of optional parameters.
*   `<param_name>`: The name of the parameter.
*   `<flags>`: Optional flags for named parameters (e.g., `-n, --name`).
*   `<param_description>`: An optional description for the parameter.
*   `<default_value>`: An optional default value for the parameter.

## Examples

Here are some examples of how to define and use [`commands_cli`](https://pub.dev/packages/commands_cli) in your `commands.yaml` file:

### Basic Command

```yaml
# commands.yaml

hello:
  script: echo "Hello, World!"
```

**Activate your defined commands:**

  <pre><code class="language-sh">$ commands
✅ <span style="color:#C9E2AF;font-weight:bold;">hello</span></code></pre>

**Run:**

```sh
$ hello
Hello, World!
```

### Positional Parameters

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

**Activate your defined commands:**

  <pre><code class="language-sh">$ commands
✅ <span style="color:#C9E2AF;font-weight:bold;">greet</span></code></pre>


**Run:**

<pre><code class="language-sh">$ greet Hi dev
Hi dev!

$ greet Yo
Yo !

$ greet
❌ Missing required positional param: <span style="color:#FFB3B3;font-weight:bold;">greeting</span></code></pre>

### Named Parameters

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

**Activate your defined commands:**

  <pre><code class="language-sh">$ commands
✅ <span style="color:#C9E2AF;font-weight:bold;">greet</span></code></pre>


**Run:**

<pre><code class="language-sh">$ greet --greeting "Hi" --name "Alice"
Hi Alice!

$ greet -g "Hi"
Hi !

$ greet
❌ Missing required named param: <span style="color:#FFB3B3;font-weight:bold;">greeting</span></code></pre>

### Optional Parameters with Default Values

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

**Activate your defined commands:**

  <pre><code class="language-sh">$ commands
✅ <span style="color:#C9E2AF;font-weight:bold;">goodbye</span></code></pre>


**Run:**

```sh
$ goodbye
Goodbye, World!

$ goodbye --name "Bob" -p "."
Goodbye, Bob.
```

### Passthrough Arguments

#### Basic Alias

```yaml
# commands.yaml

d: ## dart alias
  script: dart ...args
```

Here, `...args` is a placeholder that automatically forwards any parameters you pass to the alias into the underlying command.

For example, running `d --version` will expand to `dart --version`.

This allows you to create concise aliases while still keeping the flexibility to inject flags, options, or arguments dynamically at runtime.

**Activate your defined commands:**

  <pre><code class="language-sh">$ commands
✅ <span style="color:#C9E2AF;font-weight:bold;">d</span>: <span style="color:#808997;">dart alias</span></code></pre>


**Run:**

```sh
$ d --version
Dart SDK version: 3.9.0...
```

#### Multiline script with passthrough arguments

```yaml
# commands.yaml

analyze: ## dart analyze
  script: |
    echo "Analyzing ignoring warnings..."
    dart analyze ...args --no-fatal-warnings
```

**Activate your defined commands:**

  <pre><code class="language-sh">$ commands
✅ <span style="color:#C9E2AF;font-weight:bold;">analyze</span>: <span style="color:#808997;">dart analyze</span></code></pre>


**Run:**

```sh
$ analyze --fatal-infos
Analyzing ignoring warnings...
Analyzing example...                  0.5s
No issues found!
```

### Strongly Typed Parameters

[`commands_cli`](https://pub.dev/packages/commands_cli) supports a powerful type system for parameters, allowing you to define explicit types and constrain values for better validation and user experience.

#### Numeric Types

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

**Run:**

<pre><code class="language-sh">$ deploy -p 8080 -t 60.0
Deploying to port 8080 with timeout 60.0s

$ deploy -p abc
❌ Parameter <span style="font-weight:bold;"><span style="color:#FFB3B3;">port</span></span> expects an <span style="color:#808997;">[integer]</span>
   Got: "abc" <span style="color:#808997;">[string]</span></code></pre>

#### Boolean Flags

Boolean parameters can be toggled on/off:

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

**Run:**

```sh
$ build
verbose=false debug=true

$ build -v
verbose=true debug=true

$ build -v -d
verbose=true debug=false
```

#### Enum Parameters with Default

Restrict parameter values to a predefined set using `values`:

```yaml
# commands.yaml

deploy: ## Deploy to environment
  script: |
    echo "Deploying to {env}"
  params:
    optional:
      - env: '-e, --environment'
        values: [dev, staging, prod]
        default: staging
```

**Run:**

<pre><code class="language-sh">$ deploy
Deploying to staging

$ deploy -e prod
Deploying to prod

$ deploy -e invalid
❌ Invalid value 'invalid' for parameter <span style="font-weight:bold;"><span style="color:#FFB3B3;">env</span></span>
💡 Allowed values: <span style="color:#BBD99E;">dev</span>, <span style="color:#BBD99E;">staging</span>, <span style="color:#BBD99E;">prod</span></code></pre>

#### Interactive Enum Picker

When you define an enum parameter **without** a default value, [`commands_cli`](https://pub.dev/packages/commands_cli) will automatically present an interactive picker when the parameter is not provided:

```yaml
# commands.yaml

build: ## Build for platform
  script: |
    echo "Building for {platform}"
  params:
    optional:
      - required: '-p, --platform'
        values: [ios, android, web]
```

**Run:**

<pre><code class="language-sh">$ build -p ios
Building for ios

$ build

Select value for <span style="color:#ACD1F5;">platform</span>:

    <span style="color:#BBD99E;">1. ios ✓</span>
    2. android
    3. web

<span style="color:#808997;">Press number (1-3) or press Esc to cancel:</span></code></pre>

### Switch Commands (Nested Options)

The `switch` feature allows you to create commands with multiple named sub-options, enabling natural command structures like `build ios`, `build android`, or `run tests`.

#### Basic Switch with Default

```yaml
# commands.yaml

build: ## Build application
  switch:
    - ios: ## Build for iOS
      script: flutter build ios
    - android: ## Build for Android
      script: flutter build apk
    - web: ## Build for web
      script: flutter build web
    - default: ios
```

**Activate your defined commands:**

  <pre><code class="language-sh">$ commands
✅ <span style="color:#C9E2AF;font-weight:bold;">build</span>: <span style="color:#808997;">Build application</span></code></pre>

**Run:**

```sh
$ build
Building iOS...

$ build android
Building Android...

$ build web
Building web app...
```

#### Interactive Switch Picker

When no `default` option is specified, [`commands_cli`](https://pub.dev/packages/commands_cli) presents an interactive menu:

```yaml
# commands.yaml

deploy: ## Deploy application
  switch:
    - staging: ## Deploy to staging
      script: ./deploy.sh staging
    - production: ## Deploy to production
      script: ./deploy.sh production
```

**Run:**

<pre><code class="language-sh">$ deploy staging
Deploying to staging...

$ deploy

Select an option for <span style="color:#ACD1F5;">deploy</span>:

    <span style="color:#BBD99E;">1. staging ✓</span> <span style="color:#808997;">- Deploy to staging</span>
    2. production   <span style="color:#808997;">- Deploy to production</span>

<span style="color:#808997;">Press number (1-2) or press Esc to cancel:</span></code></pre>

#### Switch with Parameters

Each switch option can have its own parameters:

```yaml
# commands.yaml

deploy: ## Deploy with configuration
  switch:
    - staging: ## Deploy to staging
      script: |
        echo "Deploying to staging with {replicas} replicas"
      params:
        optional:
          - replicas: '-r, --replicas'
            type: int
            default: 2
    - production: ## Deploy to production
      script: |
        echo "Deploying to production with {replicas} replicas"
      params:
        optional:
          - replicas: '-r, --replicas'
            type: int
            default: 5
    - default: staging
```

**Run:**

```sh
$ deploy
Deploying to staging with 2 replicas

$ deploy production -r 10
Deploying to production with 10 replicas
```

#### Switch with Enum Parameters

Combine switches with enum parameters for even more powerful command structures:

```yaml
# commands.yaml

test: ## Run tests
  switch:
    - unit: ## Run unit tests
      script: |
        echo "Running unit tests on {platform}"
      params:
        optional:
          - platform: '-p, --platform'
            values: [vm, chrome, all]
            default: vm
    - integration: ## Run integration tests
      script: |
        echo "Running integration tests on {platform}"
      params:
        optional:
          - platform: '-p, --platform'
            values: [ios, android, all]
    - default: unit
```

**Run:**

<pre><code class="language-sh">$ test unit
Running unit tests on vm

$ test unit -p chrome
Running unit tests on chrome

$ test integration

Select value for <span style="color:#ACD1F5;">platform</span>:

    <span style="color:#BBD99E;">1. ios     ✓</span>
    2. android
    3. all

<span style="color:#808997;">Press number (1-3) or press Esc to cancel:</span></code></pre>

### Overriding existing commands

In order to override commands like: **clear**, **ls**, **cd**, **make** etc. 

You want your `.pub-cache/bin` dir to be first, not last.
So instead of:

```sh
# .zshrc

export PATH="$PATH:$HOME/.pub-cache/bin"
```

use:

```sh
# .zshrc

export PATH="$HOME/.pub-cache/bin:$PATH"
```

After changing .zshrc, reload it:

```sh
$ source ~/.zshrc
```

zsh (and bash) keep a hash table of command lookups to speed things up, to rehash:
```sh
$ hash -r
```

Define your custom `ls` command and explicitly mark it as overridable using `override: true`:

```yaml
# commands.yaml

ls: ## custom ls
  override: true # required when overriding reserved commands
  script: echo "ls is overridden!"
```

**Activate your defined commands:**

  <pre><code class="language-sh">$ commands
✅ <span style="color:#C9E2AF;font-weight:bold;">ls</span>: <span style="color:#808997;">custom ls</span></code></pre>

**Run:**

```sh
$ ls
ls is overridden!
```

#### Overriding `test` and `which` keywords

On POSIX shells (bash, zsh, sh), `test` and `which` are not just programs in **/bin** — they're also shell builtins.
That means the shell resolves these commands before looking into **$PATH**.

So even if you put executables called `test` or `which` at the front of your **$PATH**, the shell will happily use its own builtins instead.

Shadow them with functions. That way:

- Your functions always override the builtins.
- By default, they just delegate to the system binaries.
- If later you drop custom commands, they will be found first in **$PATH** (just like `ls` case).

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

Define your custom commands:

```yaml
# commands.yaml

test: ## custom test
  override: true   # required when overriding reserved commands
  script: echo "test is overridden!"

which: ## custom which
  override: true   # required when overriding reserved commands
  script: echo "which is overridden!"
```

**Activate your defined commands:**

  <pre><code class="language-sh">$ commands
✅ <span style="color:#C9E2AF;font-weight:bold;">test</span>: <span style="color:#808997;">custom test</span>
✅ <span style="color:#C9E2AF;font-weight:bold;">which</span>: <span style="color:#808997;">custom which</span></code></pre>

**Run:**

```sh
$ test
test is overridden!

$ which
which is overridden!
```
