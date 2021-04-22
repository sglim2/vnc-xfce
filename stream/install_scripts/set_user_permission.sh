#!/usr/bin/env bash

set -e

for f in "$@"
do
    echo "setiting permission for $f"

    find "$f"/ -name '*.sh' -exec chmod  a+x {} +
    
    chgrp -R 0 "$f" && \
    chmod -R  a+rw "$f" && \
    find "$f" -type d -exec chmod  a+x {} +
done
