import std/os
import std/times
import std/random
import std/strformat
import std/sequtils
import cputicks
import elvis
import logic



#const WARMUP_RUNS_COUNT: int64 = 50
#const PERF_TEST_RUNS_COUNT: int64 = 250
const
  WARMUP_RUNS_COUNT = 100
  WARMUP_MAX_TIMEOUT_SEC = 5
  PERF_TEST_RUNS_COUNT = 1000
  PERF_TEST_MAX_TIMEOUT_SEC = 10

type
  Reading = tuple
    #start: int64
    #stop: int64
    start: float
    stop: float



echo "TEST: ", splitFile(paramStr(0))[1]

let input = readFile(paramStr(1))
var readings = newSeq[Reading](WARMUP_RUNS_COUNT)

var
  t0 = cpuTime()
  warmupRunCount = 0
randomize()
while warmupRunCount < WARMUP_RUNS_COUNT:
  # adding t0 to logic and answer to t1 is an attempt to force cpu not to reorder these statements
  let
    #t0 = int64(rand 100)
    w0 = float(rand 100)
  discard logic(input)
  let
    #t1 = int64(rand 100)
    w1 = float(rand 100)
    reading = (start: w0, stop: w1)
  readings &= reading

  warmupRunCount += 1
  if (cpuTime() - t0) > WARMUP_MAX_TIMEOUT_SEC:
    break

#readings = newSeq[Reading](PERF_TEST_RUNS_COUNT)

var perfRunCount = 0
t0 = cpuTime()
asm """mfence"""

while perfRunCount < PERF_TEST_RUNS_COUNT:
  ## adding t0 to logic and answer to t1 is an attempt to force cpu not to reorder these statements
  #let
  #  #t0 = getCpuTicksStart()
  #  #i0 = int(float64(t0) * 0.000000001)
  #  t0 = cpuTime()

  #{.emit: """asm volatile ("" : : : "memory");""".}
  #asm """ "mfence" : : : "memory" """
  #asm """mfence"""
  discard logic(input)
  #asm """mfence"""

  #let
  #  #t1 = getCpuTicksEnd()
  #  #reading = (start: t0, stop: t1)
  #  t1 = cpuTime()
  #  reading = (start: t0, stop: t1)
  #readings &= reading

  perfRunCount += 1
  if (cpuTime() - t0) > PERF_TEST_MAX_TIMEOUT_SEC:
    break

asm """mfence"""
let t1 = cpuTime()

#let
#  measurements = readings.mapIt(it.stop - it.start)
#  total = measurements.foldl(a + b, int64(0))
#  avg = total div PERF_TEST_RUNS_COUNT
#  min = measurements.foldl(a < b ? a ! b, high(int64))
#  max = measurements.foldl(a > b ? a ! b, low(int64))
#let
#  measurements = readings.mapIt(it.stop - it.start)
#  total = measurements.foldl(a + b, 0.0)
#  avg = total / float(PERF_TEST_RUNS_COUNT)
#  min = measurements.foldl(a < b ? a ! b, high(float))
#  max = measurements.foldl(a > b ? a ! b, low(float))
let
  total = t1 - t0
  avg = total / float(perfRunCount)

const
  NANO_CUTOFF  = 0.001
  NANO_MUL     = 1_000_000
  MILLI_CUTOFF = 1.0
  MILLI_MUL    = 1_000

func readableTime(sec: float): string =
  if sec < NANO_CUTOFF:    fmt"{sec*NANO_MUL} ns"
  elif sec < MILLI_CUTOFF: fmt"{sec*MILLI_MUL} ms"
  else:                    fmt"{sec} sec"

echo fmt"Time  (mean):         {readableTime(avg)}         {perfRunCount} runs, {warmupRunCount} warmup"
#echo fmt"Range (min … max):    {readableTime(min)} … {readableTime(max)}"
