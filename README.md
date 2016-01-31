# MemoryCache

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
cache.read("bla") # => 1

cache.fetch("haha") { 2 }
cache.read("haha") # => 2

cache.write("expired1", 1, expires_in: 1.second)
cache.read("expired1") # => 1
sleep 1
cache.read("expired1") # => nil

cache.fetch("expired1", expires_in: 1.second) { 2 }
cache.read("expired1") # => 2
sleep 1
cache.read("expired1") # => nil
```
