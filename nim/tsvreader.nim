import std/[tables, unicode]

proc split(line: string, c: Rune): seq[string] =
  var col = ""
  for r in line.runes:
    if r == c:
      result.add col
      col = ""
    else: col.add r
  result.add col

type
  Csv* = object
    columns*: Table[string, int]
    row*: seq[seq[string]]

func stripBOM(s: string): string =
  const bom = runeAt("\ufeff", 0)
  for r in s.runes:
    if r == bom: continue
    result.add r

proc readFrom(csv: var Csv, file: File) =
  let firstline = file.readLine
  let clean = stripBOM(firstline)
  let tab = runeAt("\t", 0)
  let header = split(clean, tab)
  csv.columns = initTable[string, int]()
  for col, key in header:
    csv.columns[key] = col
  for line in file.lines:
    csv.row.add split(line, tab)

proc openCsv*(path: string): Csv =
  var file: File
  if not open(file, path): quit "failed to open csv for reading"
  result.readFrom(file)
  file.close
