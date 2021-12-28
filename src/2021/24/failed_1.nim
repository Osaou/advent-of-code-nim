import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



type
  ModelNumber = array[14, int]

const AOC_INPUT_UNIQUE_VALUES = [
  # 0,  1,  2,  3,  4,   5,  6,   7,  8,  9,  10,  11, 12,  13
  [ 1,  1,  1,  26, 26,  1,  26,  26, 1,  1,  26,  1,  26,  26 ],
  [ 12, 13, 13, -2, -10, 13, -14, -5, 15, 15, -14, 10, -14, -5 ],
  [ 7,  8,  10, 4,  4,   6,  11,  13, 1,  8,  4,   13, 4,   14 ],
]

proc monadProgram(modelNumber: ModelNumber): int =
  var x,y,w,z: int
  for index, digit in modelNumber:
    # inp w
    w = digit

    # mul x 0
    x = 0

    # add x z
    x += z

    # mod x 26
    x = x mod 26

    # div z {0}
    z = floor(z / AOC_INPUT_UNIQUE_VALUES[0][index]).int

    # add x {1}
    x += AOC_INPUT_UNIQUE_VALUES[1][index]

    # eql x w
    if x == w:
      x = 1
    else:
      x = 0

    # eql x 0
    if x == 0:
      x = 1
    else:
      x = 0

    # mul y 0
    y = 0

    # add y 25
    y += 25

    # mul y x
    y *= x

    # add y 1
    y += 1

    # mul z y
    z *= y

    # mul y 0
    y = 0

    # add y w
    y += w

    # add y {2}
    y += AOC_INPUT_UNIQUE_VALUES[2][index]

    # mul y x
    y *= x

    # add z y
    z += y

  z


proc solve*(input: string): int =
  var recordHigh = 0

  for d1 in countdown(9,1):
    for d2 in countdown(9,1):
      for d3 in countdown(9,1):
        echo fmt"  THIRD expo: {d1}, {d2}, {d3}"
        echo "    current record: ", recordHigh
        for d4 in countdown(9,1):
          for d5 in countdown(9,1):
            for d6 in countdown(9,1):
              for d7 in countdown(9,1):
                for d8 in countdown(9,1):
                  for d9 in countdown(9,1):
                    for d10 in countdown(9,1):
                      for d11 in countdown(9,1):
                        for d12 in countdown(9,1):
                          for d13 in countdown(9,1):
                            for d14 in countdown(9,1):
                              if monadProgram([d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14]) == 0:
                                let arr = [d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14]
                                var nr = 0
                                for i, d in arr.reversed():
                                  nr += d * (d ^ i)
                                recordHigh = nr

  recordHigh



#tests:
