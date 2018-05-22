#!/bin/sh

# https://github.com/boxboat/fixuid

eval $( fixuid )

/usr/local/bin/packer $*
