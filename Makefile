.PHONY: all
all:
	nelua --script bench.lua

.PHONY: clean
clean:
	rm -fv bin/* gmon.out prof bench.out membench.out maxrss

maxrss: maxrss.nelua
	nelua -r -o $@ $<
bin/nim:
	nim c -o:$@ nim/bench.nim
bin/nim.rel:
	nim c -o:$@ -d:release nim/bench.nim
bin/nim.apples.rel:
	nim c -o:$@ -d:release nim/apples.nim

P=
bin/$K:
	nelua -o $@ -L$K $K/bench.nelua $P
bin/$K.rel:
	nelua -r -o $@ -L$K $K/bench.nelua $P
bin/$K.pausegc:
	nelua -o $@ -L$K -i 'require("allocators.gc") gc:stop() require("$K.bench") gc:restart()' $P
bin/$K.pausegc.reserve:
	nelua -P reserve -o $@ -L$K -i 'require("allocators.gc") gc:stop() require("$K.bench") gc:restart()' $P
bin/$K.nogc:
	nelua -P nogc -o $@ -L$K $K/bench.nelua $P
bin/$K.nogc.reserve:
	nelua -P nogc -P reserve -o $@ -L$K $K/bench.nelua $P
bin/$K.nogc.reserve.rel:
	nelua -r -P nogc -P reserve -o $@ -L$K $K/bench.nelua $P
bin/$K.nogc.reserve.rel.atoi:
	nelua -r -P atoi -P nogc -P reserve -o $@ -L$K $K/bench.nelua $P

.PHONY: prof
prof:
	rm -fv bin/$T analysis.txt
	make P='--cflags=-pg' bin/$T
	bin/$T
	gprof bin/$T gmon.out > analysis.txt
	rm -fv bin/$T
