# Maintenance

`maintenance/` contains the supported project-maintenance commands. The older `scripts/` directory is preserved as legacy and is not changed by this workflow.

Every supported cleanup command requires an explicit `plan` or `apply` verb and an absolute `--root` path. `plan` does not modify files. `apply` requires an interactive terminal and the exact confirmation `APPLY`.

```sh
maintenance/clean-node-artifacts plan --root "$HOME/projects"
maintenance/clean-node-artifacts apply --root "$HOME/projects"
maintenance/clean-go-artifacts plan --root "$HOME/projects"
maintenance/clean-rust-artifacts plan --root "$HOME/projects"
maintenance/audit-js-vulnerabilities audit --root "$HOME/projects"
```

`audit-js-vulnerabilities fix` is explicitly mutating and requires the same interactive confirmation as cleanup commands.
