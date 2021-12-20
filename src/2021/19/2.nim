import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils
import matrix



type
  Point = object
    x,y,z: int

  ScannerReport = object
    beacons: seq[Point]

  Scanner = object
    id: int
    reportRotations: seq[ScannerReport]

  Axis {.pure.} = enum
    X, Y, Z



proc rotate90Degrees(p: Point, around: Axis, turns: int = 1): Point =
  var rotation: Matrix[int]
  case around:
    of Axis.X:
      rotation = matrix(@[
        @[ 1, 0,  0, 0 ],
        @[ 0, 0, -1, 0 ],
        @[ 0, 1,  0, 0 ],
        @[ 0, 0,  0, 1 ],
      ])

    of Axis.Y:
      rotation = matrix(@[
        @[  0, 0, 1, 0 ],
        @[  0, 1, 0, 0 ],
        @[ -1, 0, 0, 0 ],
        @[  0, 0, 0, 1 ],
      ])

    of Axis.Z:
      rotation = matrix(@[
        @[ 0, -1, 0, 0 ],
        @[ 1,  0, 0, 0 ],
        @[ 0,  0, 1, 0 ],
        @[ 0,  0, 0, 1 ],
      ])

  let point = matrix(@[
    @[ p.x ],
    @[ p.y ],
    @[ p.z ],
    @[  1  ],
  ])

  var rotated = point
  for i in 1..turns:
    rotated = mul(rotation, rotated)

  [@x, @y, @z, all _] := rotated.data
  Point(x:x, y:y, z:z)



iterator rotations24(beacon: Point): Point =
  proc rotations4(beacon: Point, around: Axis): seq[Point] =
    result &= beacon
    for turns in 1..3:
      result &= rotate90Degrees(beacon, around, turns)

  # 4 rotations about Z axis
  for r in rotations4(beacon, Axis.Z):
    yield r

  # rotate 180 about X axis, now shape is pointing down in X axis
  let down = rotate90Degrees(beacon, Axis.X, 2)
  # 4 rotations about Z axis
  for r in rotations4(down, Axis.Z):
    yield r

  # rotate 90 about X axis, now shape is pointing forward in X axis
  let forward = rotate90Degrees(beacon, Axis.X)
  # 4 rotations about Y axis
  for r in rotations4(forward, Axis.Y):
    yield r

  # rotate 270 about X axis, now shape is pointing backward in X axis
  let backward = rotate90Degrees(beacon, Axis.X, 3)
  # 4 rotations about Y axis
  for r in rotations4(backward, Axis.Y):
    yield r

  # rotate 90 about Y axis
  let right = rotate90Degrees(beacon, Axis.Y)
  # 4 rotations about X axis
  for r in rotations4(right, Axis.X):
    yield r

  # rotate 270 about Y axis
  let left = rotate90Degrees(beacon, Axis.Y, 3)
  # 4 rotations about X axis
  for r in rotations4(left, Axis.X):
    yield r



proc parseScannerReport(report: string): seq[Point] =
  result = newSeq[Point]()
  for beacon in report.splitLines().skip(1):
    [@x, @y, @z] := beacon.split(",").map(parseInt)
    result &= Point(x:x, y:y, z:z)

proc newScanner(id: int, beacons: seq[Point]): Scanner =
  # generate all possible 24 rotated versions of beacon locations
  var beaconRotations = newSeqWith(24, newSeq[Point](beacons.len))
  for b, beacon in beacons:
    var r = 0
    for rotated in rotations24(beacon):
      beaconRotations[r][b] = rotated
      r += 1

  var rotations = newSeq[ScannerReport]()
  for r in 0 ..< 24:
    let rotated = beaconRotations[r]
    rotations &= ScannerReport(beacons: rotated)

  Scanner(id:id, reportRotations: rotations)

proc parseScannerReports(input: string): seq[Scanner] =
  result = newSeq[Scanner]()

  for report in input.split("\n\n"):
    let
      beacons = report.parseScannerReport()
      scanner = newScanner(result.len, beacons)
    result &= scanner



proc `+`(a, b: Point): Point =
  Point(
    x: a.x + b.x,
    y: a.y + b.y,
    z: a.z + b.z,
  )

proc `-`(a, b: Point): Point =
  Point(
    x: a.x - b.x,
    y: a.y - b.y,
    z: a.z - b.z,
  )

proc `==`(a, b: Point): bool =
  a.x == b.x and
  a.y == b.y and
  a.z == b.z

proc `$`(p: Point): string =
  fmt"({p.x},{p.y},{p.z})"



type
  ReportOverlapStatus = enum
    SubsetMatch
    TooFewMatchingBeacons
    IdenticalBeaconData

  ReportOverlap = object
    case kind: ReportOverlapStatus:
      of SubsetMatch:
        offset: Point
        matchingBeacons: seq[Point]
        newInformation: seq[Point]
      of TooFewMatchingBeacons:
        discard
      of IdenticalBeaconData:
        discard

proc checkReportOverlap(world: seq[Point], rotatedScanner: ScannerReport, matchesNeeded: int): ReportOverlap =
  for worldCandidate in world:
    for scannerCandidate in rotatedScanner.beacons:
      let signature = worldCandidate - scannerCandidate
      var
        matchingBeacons = newSeq[Point]()
        newInformation = initHashSet[Point]()

      for worldBeacon in world:
        for scannerBeacon in rotatedScanner.beacons:
          if (worldBeacon - scannerBeacon) == signature:
            matchingBeacons &= worldBeacon
          else:
            newInformation.incl(scannerBeacon + signature)

      # if at least [matches needed] amount of beacon locations matched, we know these scanners are overlapping
      if matchingBeacons.len >= matchesNeeded:
        # remove info already present in world data
        for beacon in world:
          newInformation.excl(beacon)

        # check if ALL beacons overlapped, if so there is no new data to collect here
        if newInformation.len <= 0:
          return ReportOverlap(kind:IdenticalBeaconData)

        return ReportOverlap(kind:SubsetMatch,
          offset: signature,
          matchingBeacons: matchingBeacons,
          newInformation: newInformation.items.toSeq()
        )

  return ReportOverlap(kind:TooFewMatchingBeacons)



type ScannerOverlap = tuple
  offset: Point
  matchingBeacons: seq[Point]
  newInformation: seq[Point]

proc checkScannerOverlap(world: seq[Point], scanner: Scanner, matchesNeeded: int = 12): Option[ScannerOverlap] =
  for index, rotation in scanner.reportRotations:
    let overlap = checkReportOverlap(world, rotation, matchesNeeded)
    case overlap.kind:
      of SubsetMatch:
        return some (
          offset: overlap.offset,
          matchingBeacons: overlap.matchingBeacons,
          newInformation: overlap.newInformation,
        )

      of TooFewMatchingBeacons:
        # move on to the next rotation and try that version
        discard

      of IdenticalBeaconData:
        return none[ScannerOverlap]()

  return none[ScannerOverlap]()



proc solve*(input: string): int =
  var scanners = input.parseScannerReports()
  var
    # start by having scanner 0 be "the entire world view" as well as the "center of the universe"
    world = scanners[0].reportRotations[0].beacons.dup()
    scannerLocations = @[ Point(x:0,y:0,z:0) ]
    somethingChanged = true

  scanners = scanners[1..^1]

  while somethingChanged:
    somethingChanged = false

    block compareScanners:
      for index, scanner in scanners:
        case checkScannerOverlap(world, scanner):
          of Some(@overlap):
            scannerLocations.add(overlap.offset)

            if overlap.newInformation.len > 0:
              for beacon in overlap.newInformation:
                world.add(beacon)

            # we don't have to care about this scanner anymore
            scanners.delete(index)
            echo scanners.len, " scanners remaining"

            somethingChanged = true
            break compareScanners

  echo "ending with scanners at locations"
  var maxDistance = 0
  for ia, sa in scannerLocations:
    echo "  ", $sa
    for ib, sb in scannerLocations:
      if ia == ib:
        continue
      let
        diff = sb - sa
        manhattanDistance = diff.x + diff.y + diff.z
      if manhattanDistance > maxDistance:
        maxDistance = manhattanDistance

  maxDistance



tests:
  #solve(readFile("input.txt")) == 308
  solve(readFile("test.txt")) == 3621
