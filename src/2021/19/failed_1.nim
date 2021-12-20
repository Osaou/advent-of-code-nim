import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils
import matrix



type
  Point = object
    x,y,z: int

  ScannerReport = object
    beacons: seq[Point]
    #min, max: Point

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
  var probeRotations = newSeqWith(24, newSeq[Point](beacons.len))
  for b, beacon in beacons:
    var r = 0
    for rotated in rotations24(beacon):
      probeRotations[r][b] = rotated
      r += 1

  var rotations = newSeq[ScannerReport]()
  for r in 0..<24:
    let
      rotated = probeRotations[r]
      #xs = rotated.mapIt(it.x)
      #ys = rotated.mapIt(it.y)
      #zs = rotated.mapIt(it.z)
    rotations &= ScannerReport(
      beacons: rotated,
      #min: Point(x:xs.min(), y:ys.min(), z:zs.min()),
      #max: Point(x:xs.max(), y:ys.max(), z:zs.max())
    )

  Scanner(id:id, reportRotations: rotations)

proc parseScannerReports(input: string): seq[Scanner] =
  result = newSeq[Scanner]()

  for report in input.split("\n\n"):
    let
      beacons = report.parseScannerReport()
      scanner = newScanner(result.len, beacons)
    result &= scanner



proc `-`(a,b: Point): Point =
  Point(
    x: a.x - b.x,
    y: a.y - b.y,
    z: a.z - b.z,
  )

proc `==`(a,b: Point): bool =
  a.x == b.x and
  a.y == b.y and
  a.z == b.z

proc `$`(p: Point): string =
  fmt"({p.x},{p.y},{p.z})"



type
  ReportOverlapStatus = enum
    OverlappingProbes
    NoOverlappingProbes
    IdenticalProbeData

  ReportOverlap = object
    case kind: ReportOverlapStatus:
      of OverlappingProbes:
        offset: Point
        matchingBeacons: seq[Point]
        missingFromA: seq[Point]
        missingFromB: seq[Point]
      of NoOverlappingProbes:
        discard
      of IdenticalProbeData:
        discard

proc checkReportOverlap(a,b: ScannerReport, matchesNeeded: int): ReportOverlap =
  for i, aSignatureCandidate in a.beacons:
    let
      bFirstBeacon = b.beacons[0]
      signature = aSignatureCandidate - bFirstBeacon
    var
      matchingBeacons = newSeq[Point]()
      #indicesFromBMissingInA = initHashSet[int]()
      #indicesFromAMissingInB = initHashSet[int]()
      missingFromA = initHashSet[Point]()
      missingFromB = initHashSet[Point]()

    for aIndex, aBeacon in a.beacons:
      #if aIndex == i:
      #  continue
      for bIndex, bBeacon in b.beacons:
        if (aBeacon - bBeacon) == signature:
          matchingBeacons &= aBeacon
        else:
          #indicesFromBMissingInA.incl(bIndex)
          #indicesFromAMissingInB.incl(aIndex)
          missingFromA.incl(bBeacon)
          missingFromB.incl(aBeacon)

    # if at least [matches needed] amount of beacon locations matched, we know these scanners are overlapping
    if matchingBeacons.len >= matchesNeeded:
      #var
      #  missingFromA = newSeq[Point]()
      #  missingFromB = newSeq[Point]()
      #
      #for bIndex, bBeacon in b.beacons:
      #  if indicesFromBMissingInA.contains(bIndex):
      #    missingFromA.add(bBeacon)
      #
      #for aIndex, aBeacon in a.beacons:
      #  if indicesFromAMissingInB.contains(aIndex):
      #    missingFromB.add(aBeacon)

      # check if ALL beacons overlapped, if so there is no new data to collect here
      if missingFromA.len <= 0 and missingFromB.len <= 0:
        return ReportOverlap(kind:IdenticalProbeData)

      return ReportOverlap(kind:OverlappingProbes,
        offset: signature,
        matchingBeacons: matchingBeacons,
        missingFromA: missingFromA.items.toSeq(),
        missingFromB: missingFromB.items.toSeq()
      )

  return ReportOverlap(kind:NoOverlappingProbes)



type ScannerOverlap = tuple
  #a,b: Scanner
  offset: Point
  matchingBeacons: seq[Point]
  missingFromA: seq[Point]
  missingFromB: seq[Point]

proc checkScannerOverlap(a,b: Scanner, matchesNeeded: int = 12): Option[ScannerOverlap] =
  let aReport = a.reportRotations[0]
  for bReport in b.reportRotations:
    let overlap = checkReportOverlap(aReport, bReport, matchesNeeded)
    case overlap.kind:
      of OverlappingProbes:
        #let
        #  aPrim = newScanner(overlap.matchingBeacons & overlap.missingFromA)
        #  bPrim = newScanner(overlap.matchingBeacons & overlap.missingFromB)
        #return some(( a:aPrim, b:bPrim, offset:overlap.offset, beacons:overlap.matchingBeacons ))
        return some (
          offset: overlap.offset,
          matchingBeacons: overlap.matchingBeacons,
          missingFromA: overlap.missingFromA,
          missingFromB: overlap.missingFromB,
        )

      of NoOverlappingProbes:
        discard

      of IdenticalProbeData:
        return none[ScannerOverlap]()

  return none[ScannerOverlap]()



proc solve*(input: string): int =
  var scanners = input.parseScannerReports()

  #for si, s in scanners:
  #  echo "scanner ", si, " (", s.reportRotations.len, " rotations)"
  #  for ri, r in s.reportRotations:
  #    echo "  rotation ", ri+1
  #    for pi, beacon in r.beacons:
  #      echo "    beacon ", pi+1, ": ", fmt"({beacon.x},{beacon.y},{beacon.z})"

  var somethingChanged = true
  while somethingChanged:
    somethingChanged = false
    block compareScanners:
      #type Match = tuple[lo,hi: int]
      #var matches = initHashSet[Match]()

      # compare all scanners' data against each other
      for ia, a in scanners:
        for ib, b in scanners:
          #let match = (lo:min(ia,ib), hi:max(ia,ib))
          #if ia != ib and not matches.contains(match):
          if a.id != b.id:
            case checkScannerOverlap(a, b):
              of Some(@overlap):
                #matches.incl(match)

                echo "scanner ", a.id, " matches ", b.id, " with offset: ", $overlap.offset
                for b in overlap.matchingBeacons:
                  echo "  ", $b

                #let
                #  lo = min(ia, ib)
                #  hi = max(ia, ib)
                #scanners = scanners[0 ..< lo] & scanners[hi ..^ 1] & overlap.a & overlap.b
                #scanners =
                #  scanners.filterIt(cast[pointer](it) != cast[pointer](a) and cast[pointer](it) != cast[pointer](b)) &
                #  overlap.a &
                #  overlap.b
                if overlap.missingFromA.len > 0:
                  let aPrim = newScanner(a.id, overlap.matchingBeacons & overlap.missingFromA)
                  scanners.delete(ia..ia)
                  scanners.add(aPrim)

                  echo "  replaced scanner ", a.id, " with beacons:"
                  for b in aPrim.reportRotations[0].beacons:
                    echo "    ", $b

                  echo "    it previously had:"
                  for b in a.reportRotations[0].beacons:
                    echo "      ", $b

                if overlap.missingFromB.len > 0:
                  let bPrim = newScanner(b.id, overlap.matchingBeacons & overlap.missingFromB)
                  scanners.delete(ib..ib)
                  scanners.add(bPrim)

                  echo "  replaced scanner ", b.id, " with beacons:"
                  for b in bPrim.reportRotations[0].beacons:
                    echo "    ", $b

                  echo "    it previously had:"
                  for b in b.reportRotations[0].beacons:
                    echo "      ", $b

                #somethingChanged = true
                #break compareScanners
                return 0

  0



tests:
  # scanning
  parseScannerReport("""
    --- scanner 0 ---
    0,2,0
    4,1,0
    3,3,0
  """.unindent.strip) == @[
    Point(x: 0, y: 2, z: 0),
    Point(x: 4, y: 1, z: 0),
    Point(x: 3, y: 3, z: 0),
  ]
  parseScannerReport("""
    --- scanner 1 ---
    -1,-1,0
    -5,0,0
    -2,1,0
  """.unindent.strip) == @[
    Point(x: -1, y: -1, z: 0),
    Point(x: -5, y: 0, z: 0),
    Point(x: -2, y: 1, z: 0),
  ]
  parseScannerReport("""
    --- scanner 0 ---
    -1,-1,1
    -2,-2,2
    -3,-3,3
    -2,-3,1
    5,6,-4
    8,0,7
  """.unindent.strip) == @[
    Point(x: -1, y: -1, z: 1),
    Point(x: -2, y: -2, z: 2),
    Point(x: -3, y: -3, z: 3),
    Point(x: -2, y: -3, z: 1),
    Point(x: 5, y: 6, z: -4),
    Point(x: 8, y: 0, z: 7),
  ]

  # scanning and building rotated variants
  # rotation 1
  parseScannerReports("""
    --- scanner 0 ---
    -1,-1,1
    -2,-2,2
    -3,-3,3
    -2,-3,1
    5,6,-4
    8,0,7
  """.unindent.strip)[0].reportRotations.any(proc (report: ScannerReport): bool =
    let rotated = parseScannerReport("""
      --- rotation 1 ---
      1,-1,1
      2,-2,2
      3,-3,3
      2,-1,3
      -5,4,-6
      -8,-7,0
    """.unindent.strip)
    for p in rotated:
      if not report.beacons.anyIt(it == p):
        return false
    return true
  )

  # rotation 2
  parseScannerReports("""
    --- scanner 0 ---
    -1,-1,1
    -2,-2,2
    -3,-3,3
    -2,-3,1
    5,6,-4
    8,0,7
  """.unindent.strip)[0].reportRotations.any(proc (report: ScannerReport): bool =
    let rotated = parseScannerReport("""
      --- rotation 2 ---
      -1,-1,-1
      -2,-2,-2
      -3,-3,-3
      -1,-3,-2
      4,6,5
      -7,0,8
    """.unindent.strip)
    for p in rotated:
      if not report.beacons.anyIt(it == p):
        return false
    return true
  )

  # rotation 3
  parseScannerReports("""
    --- scanner 0 ---
    -1,-1,1
    -2,-2,2
    -3,-3,3
    -2,-3,1
    5,6,-4
    8,0,7
  """.unindent.strip)[0].reportRotations.any(proc (report: ScannerReport): bool =
    let rotated = parseScannerReport("""
      --- rotation 3 ---
      1,1,-1
      2,2,-2
      3,3,-3
      1,3,-2
      -4,-6,5
      7,0,8
    """.unindent.strip)
    for p in rotated:
      if not report.beacons.anyIt(it == p):
        return false
    return true
  )

  # rotation 4
  parseScannerReports("""
    --- scanner 0 ---
    -1,-1,1
    -2,-2,2
    -3,-3,3
    -2,-3,1
    5,6,-4
    8,0,7
  """.unindent.strip)[0].reportRotations.any(proc (report: ScannerReport): bool =
    let rotated = parseScannerReport("""
      --- rotation 4 ---
      1,1,1
      2,2,2
      3,3,3
      3,1,2
      -6,-4,-5
      0,7,-8
    """.unindent.strip)
    for p in rotated:
      if not report.beacons.anyIt(it == p):
        return false
    return true
  )

  # rotations
  block:
    [@s] := parseScannerReports("""
      --- scanner 0 ---
      1,2,3
    """.unindent.strip)
    echo "\nAll rotations of (1,2,3):"
    for i, r in s.reportRotations:
      for p in r.beacons:
        echo fmt"{i+1}: ({p.x},{p.y},{p.z})"

    true

  # overlapping
  block:
    [@a, @b] := parseScannerReports("""
      --- scanner 0 ---
      0,2,0
      4,1,0
      3,3,0

      --- scanner 1 ---
      -1,-1,0
      -5,0,0
      -2,1,0
    """.unindent.strip)
    checkScannerOverlap(a, b, 3).isSome
