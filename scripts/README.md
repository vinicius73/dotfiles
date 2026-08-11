# Legacy Project Maintenance Scripts

These scripts are retained temporarily as reference only. They are not called by `script/bootstrap` or `script/profile`; use the supported commands in [`../maintenance/`](../maintenance/README.md) for new maintenance work.

## Retained Scripts

| Script | Function |
|--------|----------|
| `clean-go-bins.sh` | Remove `bin` directories from Go projects |
| `clean-node-modules.sh` | Remove `node_modules` and `.serverless` from Node.js projects |
| `clean-rust-targets.sh` | Remove `target` directories from Rust projects |
| `check-js-vulnerabilities.sh` | Check vulnerabilities in JavaScript projects |

The legacy commands have their own behavior and safety model. Review each script before using it; do not treat their flags as equivalents of `maintenance/` commands.
