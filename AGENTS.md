# Agent Instructions

## Git Operations

**IMPORTANT**: Do NOT use GitHub or GitKraken MCP servers for git operations.

Examples:
- Use `git status` instead of MCP server status checks
- Use `git commit -m "message"` instead of MCP commit operations
- Use `git push`, `git pull`, `git branch`, etc. directly in terminal

## Commit Messages

### Conventional Commits Format

All commit messages **MUST** follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types

Use these standard types:

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, whitespace, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

#### Scope (Optional)

The scope provides additional context about what part of the codebase is affected:

```
feat(auth): add OAuth2 authentication
fix(api): correct validation error handling
docs(readme): update installation instructions
```

#### Description

- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize the first letter
- No period at the end
- Keep it concise but descriptive

#### Examples

✅ **Good:**
```
feat(auth): add user authentication with JWT
```

✅ **Good:**
```
fix: correct validation error in login form
```

✅ **Good with body:**
```
feat(commands): add support for command aliases

Allow users to define custom aliases for frequently used commands.
This improves usability and reduces typing for common operations.
```

✅ **Good with breaking change:**
```
feat(api)!: change authentication endpoint structure

BREAKING CHANGE: The /auth endpoint now requires a different request format.
Update client code to use the new { email, password } structure.
```

❌ **Bad:**
```
Added new feature
```

❌ **Bad:**
```
Fix bug.
```

❌ **Bad:**
```
Updated some stuff
```

### What to Avoid

**DO NOT include** any of the following in commit messages:

- References to AI models (Claude, GPT, etc.)
- "Generated with Claude Code" or similar branding
- Co-authored-by attributions to AI assistants
- Any mentions of AI assistance in the commit process
- Vague descriptions like "updates", "changes", "fixes"
- Emoji (unless part of established team convention)

❌ **Bad:**
```
feat(auth): add user authentication

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

❌ **Bad:**
```
fix: bug fix (created with AI assistance)
```

### Rationale

Following Conventional Commits:
- Creates a clear, standardized git history
- Enables automatic changelog generation
- Makes it easier to understand the nature of changes
- Improves collaboration and code review processes
- Allows for semantic versioning automation

Commit messages should focus on **what** changed and **why**, not the tools used to create the changes.

## Testing Workflow

When implementing new features, refactoring, or making any changes, follow this complete testing workflow:

### 1. Run Unit Tests
First, run unit tests in the root `test/` folder to verify core functionality.

### 2. Run Integration Tests (CRITICAL)
Integration tests are located in `example/test/` and are essential to verify the complete workflow.

**To run integration tests, you MUST:**

1. **Push changes to your working branch:**
   ```sh
   git push origin <branch-name>
   ```

2. **Activate the package globally from your branch:**
   ```sh
   dart pub global activate --source git https://github.com/Nikoro/commands_cli.git --git-ref <branch-name>
   ```
   
   Note: By default (without `--git-ref`), this activates from the `main` branch. Use `--git-ref` to specify a different branch.

3. **Clean all previously generated commands:**
   ```sh
   commands clean
   ```   

4. **Activate all commands:**
   ```sh
   cd example && commands
   ```

5. **Run the integration tests:**
   ```sh
   dart test
   ```

**IMPORTANT**: Integration tests in `example/test/` require the package to be globally activated. Do not skip this step or the tests may fail or not reflect the actual changes.
