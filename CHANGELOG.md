## 0.2.0

### Features
- **Update Command**: Add new `--update` (`-u`) option that intelligently updates commands_cli
  - Auto-detects global vs local installation context
  - Runs `dart pub global activate` for global installations
  - Runs `dart pub upgrade` for local dependencies
  - Preserves installation source (git vs pub.dev) during updates

### Improvements
- **Update Logic**: Simplify git URL handling and improve source detection
  - Use hardcoded public repository URL for git updates
  - Enhanced source detection with regex-based parsing for commands_cli package entry

### Documentation
- Add AGENTS.md with testing workflow instructions
  - Git operations guidelines
  - Integration test workflow requiring global package activation
  - Instructions for activating from specific git branches using `--git-ref` flag
- Expand package description in pubspec.yaml
- Add package topics for better discoverability (cli, makefile, commands, task-runner, script-manager)
- Update repository and issue tracker URLs
- Update pub.dev and GitHub Actions badge URLs

### Testing
- Add comprehensive test coverage for help option flags
- Update integration tests to accept both git and pub.dev update messages

### CI/CD
- Add concurrency control to automatically cancel previous workflow runs

## 0.1.0

Initial release 🎉
