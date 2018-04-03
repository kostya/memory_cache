require "spec"
require "../src/memory_cache"

CACHE = MemoryCache(String, Int32).new

module Spec
  before_each do
    CACHE.clear
    CACHE.write("bla", 1)
    CACHE.write("haha", 2)
  end
end
