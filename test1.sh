#!/bin/bash

# Shows a random red-black tree
# requirements
#   graphviz
#   imagemagick
#   D (dlang) compiler

./redblack  | tee $(tty) | dot | gvpr -c -ftree.gv | neato -n -Tpng | display
