import std/strutils
import std/sequtils
import std/sugar



type Move* = tuple
  dir: string
  speed: int

proc readTrajectory*(fileName: string): seq[Move] =
  readFile(fileName)
    .splitLines
    .filterIt(it.strip() != "")
    .map(str => str.split(" "))
    .map(arr => (dir: arr[0], speed: parseInt(arr[1])))
