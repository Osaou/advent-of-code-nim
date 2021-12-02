#!/bin/sh

# build aoc cli tool
nim compile --out:./tmp/aoc aoc.nim

# move it to /usr/local/bin
sudo mv ./tmp/aoc /usr/local/bin/aoc
