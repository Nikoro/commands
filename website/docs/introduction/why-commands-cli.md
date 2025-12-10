---
sidebar_label: 'Why commands_cli?'
---

# Why use `commands_cli` instead of `Makefile`? 🤔

While `Makefile` is a powerful and widely used tool, `commands_cli` offers several advantages for modern development workflows, especially for Dart and Flutter projects:

*   **Cross-platform Compatibility:** `commands_cli` is written in Dart and runs on any platform where the Dart SDK is available. This means your commands will work consistently across **macOS**, **Linux**, and **Windows**.

*   **Simplicity and Readability:** `commands.yaml` uses the clean and human-readable YAML format. This makes your scripts easier to read, write, and maintain, even for teammates who aren’t familiar with traditional Makefiles.

*   **Structured Parameters:** `commands_cli` lets you define both **positional** and **named** parameters in a clear, structured way. Parameters can be **required** or **optional**, and you can set **default** values when needed. This makes your commands self-documenting, easy to use, and far more powerful than Makefile's limited and often clumsy parameter handling.

*   **Strong Type System:** Unlike Makefile's string-based approach, `commands_cli` supports a powerful type system with **int**, **double**, **boolean**, and **enum** types. This provides built-in validation, preventing common errors and making your commands more robust.

*   **Built-in Interactive Pickers:** When you define enum parameters or switch commands without defaults, `commands_cli` automatically presents a beautiful interactive menu. No need to parse input manually or write custom prompts—it's all handled for you.

*   **Automatic Help Generation:** Every command automatically gets a `--help` (or `-h`) parameter. It collects information **from your defined parameters and optional comments** directly from the `commands.yaml` file, providing clear, up-to-date guidance without any extra work.

*   **Composable, Human-Readable Commands:** With `commands_cli`, you can define keyword chains that read like plain English. Instead of cryptic flags, you can run natural phrases. This **switch**-based design makes commands easier to discover, remember, and use.
