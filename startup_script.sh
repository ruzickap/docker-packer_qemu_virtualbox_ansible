#!/bin/sh

# https://github.com/boxboat/fixuid
eval "$( fixuid -q )"

if [ -n "$PACKER_RUN_TIMEOUT" ]; then
  timeout --preserve-status --foreground "$PACKER_RUN_TIMEOUT" /usr/local/bin/packer "$@"
else
  /usr/local/bin/packer "$@"
fi
