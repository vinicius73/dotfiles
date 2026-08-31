# Private macOS configuration

`private/macos/` is an ignored local directory for macOS-only work configuration. It is intentionally outside `home/`, so the public Chezmoi source and public CI never read or apply it.

## Precedence

1. Run `script/bootstrap apply` to provision and apply the public configuration.
2. Review the private checkout under `private/macos/`.
3. Run `script/private-macos plan`.
4. Run `script/private-macos apply` to install optional private packages and apply private configuration.

Private application refuses to run unless `chezmoi verify --source home --destination "$HOME"` succeeds. It also rejects every destination managed by the public source, so the private configuration can add work-specific settings but cannot override portable configuration. The private source cannot manage `~/.agents/**`; local agent skills must use a separate installer and cannot reuse names declared by `home/dot_agents/skills/`.

## Private layout

```text
private/macos/
  private-macos.conf
  home/
  packages.Brewfile
```

`private-macos.conf` is a strict data-only file:

```text
schema_version=1
chezmoi_source=home
brewfile=packages.Brewfile
```

`brewfile` is optional. In schema version 1, the accepted source and Brewfile names are fixed; arbitrary paths, symbolic links, duplicate keys, and unknown entries are rejected.

The local reference currently manages OpenCode, Claude Code, Cursor, and Zed settings. It intentionally excludes credentials, caches, extensions, histories, workspaces, session state, and generated files. Store credentials through the existing Keychain or local secret mechanisms instead.

The private directory is ignored by Git. Initialize it as a private repository when ready; no remote, organization name, or private path is stored in tracked files. Updating that private repository is separate from application: review and update it using the organization-approved Git workflow, then run `plan` and `apply` again.

`script/private-macos verify` checks the extension schema, target isolation, and both applied Chezmoi sources. It does not fetch, install, or modify files.
