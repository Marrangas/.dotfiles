#!/bin/bash
# scripts/manage_plugin.sh <name> <url> <dest_path> [branch_or_tag]

NAME=$1
URL=$2
DEST=$3
PIN=$4

if [ ! -d "$DEST" ]; then
    echo "Cloning $NAME..."
    if [ -n "$PIN" ]; then
        git clone --branch "$PIN" "$URL" "$DEST"
    else
        git clone "$URL" "$DEST"
    fi
else
    if [ -n "$PIN" ]; then
        # Check for newer versions without pulling (since we are pinned)
        LATEST=$(git ls-remote --tags "$URL" | grep -o 'v[0-9.]*$' | sort -V | tail -n 1)
        # Try to get the current tag, fallback to branch name if not exactly on a tag
        CURRENT=$(git -C "$DEST" describe --tags 2>/dev/null || git -C "$DEST" rev-parse --abbrev-ref HEAD)
        
        if [ -n "$LATEST" ] && [ "$LATEST" != "$CURRENT" ]; then
            echo "Warning: A newer version of $NAME is available ($LATEST). Local is $CURRENT (pinned to $PIN)."
        else
            echo "$NAME is up to date ($CURRENT)."
        fi
    else
        # Standard update for unpinned plugins
        echo "Updating $NAME..."
        git -C "$DEST" pull
    fi
fi
