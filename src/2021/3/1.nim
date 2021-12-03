# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import elvis
import utils



# tests
const
  expectedTestResult* = 198
  expectedRunResult* = 2261546



# 00100
# 11110
# 10110
# 10111
# 10101
# 01111
# 00111
# 11100
# 10000
# 11001
# 00010
# 01010

# logic
proc logic*(input: string): int =
  let
    powerConsumption = input
      # read in as seq[string] of all lines
      .splitLines()
      .filterIt(it.len > 0)
      # convert each line to seq[char], resulting in "matrix": seq[seq[char]]
      .mapIt(it.toSeq)
      # transpose the matrix, to be able to iterate over columns
      .transposeMatrix()
      # count 1s and 0s for each column
      .mapIt((
        ones:   it.count('1'),
        zeroes: it.count('0')
      ))
      # gamma: for each column, keep the most common value (1 or 0)
      # epsilon: for each column, keep the least common value (1 or 0)
      .mapIt((
        gamma:   it.ones > it.zeroes ? '1' ! '0',
        epsilon: it.ones < it.zeroes ? '1' ! '0'
      ))
      # wrap back to tuple with first item being gamma, second item being epsilon
      .unzip()

    # join values back to strings, instead of seq[char], and then parse binary int values from these strings
    gamma   = powerConsumption[0].join() |> fromBin[int]()
    epsilon = powerConsumption[1].join() |> fromBin[int]()

  # end result is gamma multiplied by epsilon
  gamma * epsilon
