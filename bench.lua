local function maxrss(t) assert(os.execute('echo "$(./maxrss bin/' .. t .. '|tail -1)" ' .. t .. ' | tee -a membench.out')) end
local function make(k, t) assert(os.execute('make bin/' .. t .. ' K=' .. k)) end
local function bench(t) assert(os.execute('hyperfine --warmup=1 --max-runs=3 bin/' .. t .. ' | tee -a bench.out')) end
local function split(t) local r = {} for x in string.gmatch(t, "[^%s]+") do table.insert(r, x) end return r end

local designs = split([[careless lazy uniwise lazy-uniwise mmapslice careful careful careful-stream]])
local builds = split([[rel pausegc pausegc.reserve nogc nogc.reserve nogc.reserve.rel]])

os.execute 'make bin/nim bin/nim.rel bin/nim.apples.rel'
bench('nim')  bench('nim.rel')  bench('nim.apples.rel')
maxrss('nim') maxrss('nim.rel') maxrss('nim.apples.rel')
for _, design in ipairs(designs) do
  make(design, design)
  bench(design)
  maxrss(design)
  for _, build in ipairs(builds) do
    local target = design .. '.' .. build
    make(design, target)
    bench(target)
    maxrss(target)
  end
end

table.insert(designs, 'nim')
table.insert(builds, 'rel')
table.insert(builds, 'apples.rel')

local time, space, design, build, bin = {}, {}, '', '', ''
local file = io.open('bench.out', 'r')
for line in file:lines() do
  local exe = string.match(line, " bin/([^.]+) ")
  if exe then
    bin, design, build = exe, exe, ''
  else
    local exe, d, b = string.match(line, " bin/(([^.]+)[.]([^%s]+))")
    if d and b then
      bin, design, build = exe, d, b
    else
      local t = string.match(line, " ([0-9][^%s]+ [^%s]+) ±") 
      if t then
        if not time[design] then time[design] = {} end
        if not space[design] then space[design] = {} end
        time[design][build] = t
      end
    end
  end
end

file:close()
file = io.open('membench.out', 'r')
for line in file:lines() do
  local rss, design, build = string.match(line, "([0-9.]+ [a-zA-Z]+) ([^%s.]+)[.]([^%s]+)")
  if rss and design and build then
    space[design][build] = rss
  else
    local rss, design = string.match(line, "([0-9.]+ [a-zA-Z]+) ([^%s.]+)")
    if rss and design then space[design][''] = rss end
  end
end

for _, design in ipairs(designs) do
  print(string.format('| %s | %s | %s |', design, time[design][''], space[design]['']))
  for _, build in ipairs(builds) do
    print(string.format('| %s.%s | %s | %s |', design, build, time[design][build], space[design][build]))
  end
end
