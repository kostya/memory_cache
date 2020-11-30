# MemoryCache

[![CI](https://github.com/kostya/memory_cache/workflows/CI/badge.svg)](https://github.com/kostya/memory_cache/actions?query=workflow%3ACI)

Super simple in memory key-value storage with expires for Crystal.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  memory_cache:
    github: kostya/memory_cache
```


## Usage


```crystal
require "memory_cache"

cache = MemoryCache(String, Int32).new

cache.write("bla", 1)
p cache.read("bla") # => 1

cache.fetch("haha") { 2 }
p cache.read("haha") # => 2

cache.write("expired1", 1, expires_in: 1.second)
p cache.read("expired1") # => 1
sleep 1
p cache.read("expired1") # => nil

p cache.fetch("expired1", expires_in: 1.second) { 2 } # => 2
p cache.fetch("expired1", expires_in: 1.second) { 3 } # => 2
sleep 1
p cache.fetch("expired1", expires_in: 1.second) { 3 } # => 3
```
