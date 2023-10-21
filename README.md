# cvsbench
I wrote some Nelua code to ingest a 20MB .csv file, ran it, and found it to
be alarmingly slow compared to a reference implementation in Nim. This
repository has that original code, the Nim reference implementation, and some
improvements, and a report of time and space usage.

The 20MB .csv file is included and is an old download of openrussian.org's
sentence table.

some conclusions:
- I was doing a lot of batch work during ingestion that could be delayed to
  later I/O when it would be cheap. I was already annoyed by how long it was
  taking with the reference implementation.
- I was decoding UTF8 in order to match ASCII bytes, which is unnecessary as
  ASCII bytes can't occur in multibyte UTF8 sequences: a tab is always a tab.
- mmap works as well as expected

| Build | Runtime | MaxRSS |
|-|-|-|
| careless | 44.626 s | 2.1 G |
| careless.nogc | 11.264 s | 1.1 G |
| careless.nogc.reserve | 11.021 s | 1.1 G |
| careless.nogc.reserve.rel | 4.544 s | 1.1 G |
| careless.pausegc | 31.139 s | 4.2 G |
| careless.pausegc.reserve | 32.414 s | 4.2 G |
| careless.rel | 18.177 s | 2.1 G |
| | | |
| lazy | 30.908 s | 1.1 G |
| lazy.nogc | 7.077 s | 713.68 MB |
| lazy.nogc.reserve | 6.804 s | 713.57 MB |
| lazy.nogc.reserve.rel | 3.121 s | 713.55 MB |
| lazy.pausegc | 19.743 s | 2.3 G |
| lazy.pausegc.reserve | 20.004 s | 2.3 G |
| lazy.rel | 13.351 s | 1.1 G |
| | | |
| uniwise | 20.384 s | 1.2 G |
| uniwise.nogc | 6.588 s | 571.14 MB |
| uniwise.nogc.reserve | 6.816 s | 571.27 MB |
| uniwise.nogc.reserve.rel | 2.536 s | 571.12 MB |
| uniwise.pausegc | 17.440 s | 2.1 G |
| uniwise.pausegc.reserve | 17.884 s | 2.1 G |
| uniwise.rel | 7.326 s | 1.2 G |
| | | |
| lazy-uniwise | 5.490 s | 367.24 MB |
| lazy-uniwise.nogc | 2.739 s | 162.57 MB |
| lazy-uniwise.nogc.reserve | 2.721 s | 162.52 MB |
| lazy-uniwise.nogc.reserve.rel | 860.1 ms | 162.38 MB |
| lazy-uniwise.pausegc | 4.718 s | 362.67 MB |
| lazy-uniwise.pausegc.reserve | 4.884 s | 362.50 MB |
| lazy-uniwise.rel | 1.848 s | 369.23 MB |
| | | |
| mmapslice | 14.477 s | 1.2 G |
| mmapslice.nogc | 4.434 s | 525.44 MB |
| mmapslice.nogc.reserve | 4.333 s | 525.50 MB |
| mmapslice.nogc.reserve.rel | 1.757 s | 525.52 MB |
| mmapslice.pausegc | 14.507 s | 2.1 G |
| mmapslice.pausegc.reserve | 13.749 s | 2.1 G |
| mmapslice.rel | 4.842 s | 1.2 G |
| | | |
| careful | 1.179 s | 172.84 MB |
| careful.nogc | 498.2 ms | 116.79 MB |
| careful.nogc.reserve | 455.8 ms | 116.60 MB |
| careful.nogc.reserve.rel | 195.1 ms | 116.50 MB |
| careful.pausegc | 855.5 ms | 166.89 MB |
| careful.pausegc.reserve | 827.9 ms | 166.57 MB |
| careful.rel | 417.2 ms | 171.25 MB |
| | | |
| careful-stream | 368.6 ms | 50.81 MB |
| careful-stream.nogc | 329.3 ms | 50.73 MB |
| careful-stream.nogc.reserve | 317.8 ms | 53.31 MB |
| careful-stream.nogc.reserve.rel | 115.2 ms | 53.27 MB |
| careful-stream.pausegc | 330.7 ms | 50.79 MB |
| careful-stream.pausegc.reserve | 309.9 ms | 50.25 MB |
| careful-stream.rel | 130.8 ms | 50.69 MB |
| | | |
| nim | 3.785 s | 111.22 MB |
| nim.apples.rel | 1.283 s | 238.20 MB |
| nim.rel | 799.2 ms | 112.02 MB |
