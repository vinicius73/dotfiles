#!/bin/sh

profile_packages_plan() {
  profile_packages_platform=$(dotfiles_platform)
  profile_packages_manifest=$(dotfiles_manifest_path "$1" "$profile_packages_platform") || dotfiles_die "The $1 profile is unsupported on $profile_packages_platform."
  printf '%s\n' "Platform: $profile_packages_platform"
  printf '%s\n' "Manifest: $profile_packages_manifest"
  if [ "$profile_packages_platform" = arch ]; then dotfiles_read_manifest "$profile_packages_manifest"; fi
}

profile_packages_apply() {
  profile_packages_platform=$(dotfiles_platform)
  profile_packages_manifest=$(dotfiles_manifest_path "$1" "$profile_packages_platform") || dotfiles_die "The $1 profile is unsupported on $profile_packages_platform."
  if [ "$profile_packages_platform" = macos ]; then
    dotfiles_install_brewfile "$profile_packages_manifest"
  else
    dotfiles_install_arch_manifest "$profile_packages_manifest"
  fi
}

profile_desktop_plan() {
  profile_packages_plan desktop
  if [ "$profile_packages_platform" = arch ]; then
    profile_desktop_aur_manifest="$DOTFILES_REPO_ROOT/packages/arch/aur-desktop.txt"
    printf '%s\n' "AUR packages:"
    dotfiles_read_manifest "$profile_desktop_aur_manifest"
  fi
}

profile_desktop_apply() {
  profile_packages_apply desktop
  if [ "$profile_packages_platform" = arch ]; then
    profile_desktop_aur_manifest="$DOTFILES_REPO_ROOT/packages/arch/aur-desktop.txt"
    dotfiles_confirm "Install the displayed AUR packages."
    dotfiles_install_arch_manifest "$profile_desktop_aur_manifest"
  fi
}

profile_docker_apply() {
  profile_docker_platform=$(dotfiles_platform)
  profile_packages_apply docker
  if [ "$profile_docker_platform" = macos ]; then
    printf '%s\n' "Start Docker Desktop and complete its first-run setup before using Docker."
  else
    printf '%s\n' "Docker is installed but not enabled. To enable it, run: sudo systemctl enable --now docker"
    printf '%s\n' "Adding a user to the docker group grants root-equivalent access and is intentionally manual."
  fi
}
