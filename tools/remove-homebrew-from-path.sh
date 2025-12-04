#!/usr/bin/env zsh

if [[ -d /opt/homebrew/bin ]]; then
    echo "Found /opt/homebrew/bin, listing its contents:"
    ls -l /opt/homebrew/bin
fi


echo "Trying to remove all instances of homebrew from PATH..."

export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '^/opt/homebrew' | tr '\n' ':' | sed 's/:$//')

echo "Updated PATH: $PATH"
