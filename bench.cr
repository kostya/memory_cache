require "./src/memory_cache"
require "benchmark"

hash = {} of String => String
cache = MemoryCache(String, String).new

1000.times do |i|
  hash["key#{i}"] = "value#{i}"
  cache.write "key#{i}", "value#{i}"
end

Benchmark.ips do |b|
  b.report("hash write") { hash["bla"] = "haha" }
  b.report("cache write") { cache.write "bla", "haha" }
end

Benchmark.ips do |b|
  b.report("hash read") { hash["bla"]? }
  b.report("cache read") { cache.read "bla" }
end

Benchmark.ips do |b|
  b.report("hash fetch") { if v = hash["bla"]?
    v
  else
    v = "haha"; hash["bla"] = v; v
  end }
  b.report("cache fetch") { cache.fetch("bla") { "haha" } }
end
