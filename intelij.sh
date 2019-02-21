#!/bin/bash

# Thanks @ketos @krishjun @denis111

## declare array of tools
declare -a tools=(
    "DataGrip"
    "CLion"
    "Rider"
    "PhpStorm"
    "GoLand"
    )

for tool in "${tools[@]}"
do
    echo "removing evaluation key for $tool"
    rm -rf ~/.$tool*/config/eval
    rm -rf ~/.$tool*/config/options/other.xml
    rm -rf ~/.java/.userPrefs/jetbrains/${tool,,}
done

for tool in "${tools[@]}"
do
    echo "resetting evalsprt in options.xml for $tool"
    sed -i '/evlsprt/d' ~/.$tool*/config/options/options.xml
done

echo "resetting evalsprt in prefs.xml"
sed -i '/evlsprt/d' ~/.java/.userPrefs/prefs.xml

for tool in "${tools[@]}"
do
    echo "change date file for $tool"
    find ~/.$tool* -type d -exec touch -t $(date +"%Y%m%d%H%M") {} +;
    find ~/.$tool* -type f -exec touch -t $(date +"%Y%m%d%H%M") {} +;
done

echo "Complete"
