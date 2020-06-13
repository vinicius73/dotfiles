#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

profiles_path=/org/gnome/terminal/legacy/profiles:
# profile=`gsettings get org.gnome.Terminal.ProfilesList default | tr -d \'\"`
profile=$(dconf read $profiles_path/default)
profiles=($(dconf list $profiles_path/ | grep ^: | sed 's/\///g'))
x=`dconf read /org/gnome/terminal/legacy/profiles:$profile/visible-name`

echo $profiles
echo $profile
echo $x

# bash $DIR/gnome-terminal-dark-install.sh $profile