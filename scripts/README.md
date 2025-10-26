# Project Maintenance Scripts

Bash scripts for cleaning and maintaining development projects.

## Available Scripts

| Script | Function |
|--------|----------|
| `maintain-git-repos.sh` | Git repository maintenance (fetch, gc, prune, fsck) |
| `clean-go-bins.sh` | Remove `bin` directories from Go projects |
| `clean-node-modules.sh` | Remove `node_modules` and `.serverless` from Node.js projects |
| `clean-rust-targets.sh` | Remove `target` directories from Rust projects |
| `check-js-vulnerabilities.sh` | Check vulnerabilities in JavaScript projects |

## Basic Usage

```bash
# Make executable
chmod +x *.sh

# Run (interactive mode)
./maintain-git-repos.sh
./clean-go-bins.sh
./clean-node-modules.sh
./clean-rust-targets.sh
./check-js-vulnerabilities.sh

# Simulate operations (dry-run)
./clean-go-bins.sh --dry-run
./clean-node-modules.sh --dry-run
./clean-rust-targets.sh --dry-run

# Force cleanup (no confirmation)
./clean-go-bins.sh --force
./clean-node-modules.sh --force
```

## Common Options

- `--help` - Show help
- `--verbose` - Verbose output
- `--dry-run` - Simulate without executing
- `--force` - Execute without confirmation (cleanup only)

## Requirements

- Bash 4.0+
- Git
- Specific tools: Go, Node.js/npm, Rust/Cargo

## Security

- All scripts verify Git repositories
- Use `--dry-run` to test before executing
