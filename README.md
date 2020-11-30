# MemoryCache

[![CI](https://github.com/kostya/memory_cache/workflows/CI/badge.svg)](https://github.com/kostya/memory_cache/actions?query=workflow%3ACI)

Super simple in memory key-value storage with expires for Crystal.

Can be used for a session or token store.

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  memory_cache:
    github: kostya/memory_cache
```

## Usage

### Simple write/read key

```crystal
require "memory_cache"

cache = MemoryCache(String, Int32).new

cache.write("bla", 1)
p cache.read?("bla") # => 1
```

### Fetch a key or add it if not present

```crystal
require "memory_cache"

cache = MemoryCache(String, Int32).new

unless value = cache.read? "key"
  value = cache.write("key", 1)
end

p value
```

### Garbage collector example

Checks each hour to cleans up all keys older than 1 day.

```crystal
require "memory_cache"

cache = MemoryCache(String, Int32).new
loop do
  sleep 1.hour
  count = cache.cleanup max_period: 1.day
  puts "#{count} keys freed"
end
```
