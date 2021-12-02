#import std/strformat
import readData



proc plotCourse(fileName: string): int =
  let trajectory = readTrajectory(fileName)
  var
    depth = 0
    position = 0

  #echo trajectory

  for move in trajectory:
    case move.dir
      of "up":
        depth -= move.speed
      of "down":
        depth += move.speed
      of "forward":
        position += move.speed

  #echo fmt"Position: {position}, Depth: {depth}"

  position * depth



# tests!
assert plotCourse("test.txt") == 150
assert plotCourse("input.txt") == 1670340

# print answer
echo plotCourse("input.txt")
