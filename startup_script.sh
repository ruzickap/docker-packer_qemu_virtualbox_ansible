#!/bin/sh

# https://github.com/boxboat/fixuid

eval $( fixuid -q )

/usr/local/bin/packer "$@"
