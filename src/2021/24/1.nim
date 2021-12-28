import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils



const AOC_INPUT_UNIQUE_VALUES = [
  # 0,  1,  2,  3,  4,   5,  6,   7,  8,  9,  10,  11, 12,  13
  [ 1,  1,  1,  26, 26,  1,  26,  26, 1,  1,  26,  1,  26,  26 ],
  [ 12, 13, 13, -2, -10, 13, -14, -5, 15, 15, -14, 10, -14, -5 ], # x
  [ 7,  8,  10, 4,  4,   6,  11,  13, 1,  8,  4,   13, 4,   14 ], # y
]

proc push(stack: var seq[int], value: int) =
  stack.add(value)

proc pop(stack: var seq[int]): int =
  result = stack[^1]
  stack.setLen(stack.len - 1)



proc solve*(input: string): int =
  var
    answer: array[14, int]
    stack: seq[int]

  for index, action in AOC_INPUT_UNIQUE_VALUES[0]:
    # 1 means "push to stack"
    if action == 1:
      # we only need to store the index, since we can use the LUT to get the values of x and y
      stack.push(index)

    # 26 means "pop from stack"
    else:
      let
        otherIndex = stack.pop()
        # x(this) + y(other)
        add = AOC_INPUT_UNIQUE_VALUES[1][index] + AOC_INPUT_UNIQUE_VALUES[2][otherIndex]

      # "digit = otherDigit + add", but constrain all numbers between 1-9
      # ergo, take the largest of [digit, otherDigit] and set it to 9...
      var digit, otherDigit: int
      if add > 0:
        digit = 9
        otherDigit = digit - add
      else:
        otherDigit = 9
        digit = otherDigit + add

      answer[index] = digit
      answer[otherIndex] = otherDigit

      #echo answer

  answer
    .mapIt($it)
    .join()
    .parseInt()
