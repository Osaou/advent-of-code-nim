#import std/strformat
import readData



proc plotCourse(fileName: string): int =
  let trajectory = readTrajectory(fileName)
  var
    aim = 0
    depth = 0
    position = 0

  for move in trajectory:
    case move.dir
      of "up":
        aim -= move.speed
      of "down":
        aim += move.speed
      of "forward":
        position += move.speed
        depth += aim * move.speed

  #echo fmt"Position: {position}, Depth: {depth}"

  position * depth



# tests!
assert plotCourse("test.txt") == 900
assert plotCourse("input.txt") == 1954293920

# print answer
echo plotCourse("input.txt")
