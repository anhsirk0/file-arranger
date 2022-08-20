#!/usr/bin/env bash

url="https://raw.githubusercontent.com/anhsirk0/file-arranger/master/arng.pl"

echo "Downloading the script ..."
curl $url --output arng

if [[ -f "arng" ]]; then
    echo "Making it executable ..."
    chmod +x arng

    install_path="$HOME/.local/bin"
    read -p "Move the script to $install_path ? (y/N) " ans
    if [[ "${ans,,}" == "y" ]]; then
        echo "Moving the script to $install_path ..."
        # create $install_path if not exists
        [[ -d "" ]] || mkdir $install_path -p
        mv -v arng $install_path
        echo "Script moved to $install_path"
    else
        echo "Script not moved"
    fi
    echo "arng is installed"
else
    echo "Unable to download the script"
fi

