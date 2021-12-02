#!/bin/sh

# build aoc cli tool
nim compile --out:./aoc aoc.nim

# move it to /usr/local/bin
sudo mv ./aoc /usr/local/bin/aoc
