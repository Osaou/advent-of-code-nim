# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import elvis
import utils



# tests
const
  expectedTestResult* = 230
  expectedRunResult* = 6775520



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

type RatingCount = tuple
  ones: int
  zeroes: int
  most: char
  least: char

proc count1s0sInColumnForRating(rating: seq[char]): RatingCount =
  let
    ones   = rating.count('1')
    zeroes = rating.count('0')
  return (
    ones:   ones,
    zeroes: zeroes,
    most:   ones >= zeroes ? '1' ! '0',
    least:  ones <  zeroes ? '1' ! '0'
  )

# logic
proc logic*(input: string): int =
  let
    measurements = input
      # read in as seq[string] of all lines
      .splitLines()
      .filterIt(it.len > 0)
      # convert each measurement to seq[char], resulting in "matrix": seq[seq[char]]
      .mapIt(it.toSeq)
    columnCount = measurements[0].len

  var
    oxy = measurements
    co2 = measurements

  for index in 0 ..< columnCount:

    if oxy.len > 1:
      let oxyColumns = oxy
        .transposeMatrix()[index]
        .count1s0sInColumnForRating()
      oxy = oxy.filterIt(it[index] == oxyColumns.most)

    if co2.len > 1:
      let co2Columns = co2
        .transposeMatrix()[index]
        .count1s0sInColumnForRating()
      co2 = co2.filterIt(it[index] == co2Columns.least)

  let
    # join values back to strings, instead of seq[char], and then parse binary int values from these strings
    oxygenGeneratorRating = oxy[0].join() |> fromBin[int]()
    co2ScrubberRating     = co2[0].join() |> fromBin[int]()

  # end result is oxygen generator multiplied by co2 scrubber
  oxygenGeneratorRating * co2ScrubberRating
