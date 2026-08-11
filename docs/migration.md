# Migration

The legacy Arch scripts remain in the repository temporarily for reference but are not called by `script/bootstrap` or `script/profile`.

Before deleting the legacy workflow:

1. Apply the Chezmoi source on macOS and Arch.
2. Validate `mise install`, `mise reshim`, and `mise doctor` in Fish and Bash. The bootstrap surfaces `mise doctor` diagnostics but does not fail on advisory output.
3. Verify that Volta, RVM, SDKMAN, direct Deno/Bun installs, pnpm home paths, and language-specific PATH hooks no longer win command resolution.
4. On Arch, verify `paru -Qo "$(command -v rustup)"` after applying the Rust profile.
5. Verify Docker and desktop profiles individually.

The legacy `arch-enviroments.sh`, Volta installer, direct rustup installer, global sysctl changes, and IntelliJ evaluation-reset utility are intentionally excluded from the new workflow.
