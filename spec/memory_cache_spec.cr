require "spec"
require "../src/memory_cache"

describe MemoryCache do
  it "read?" do
    cache = MemoryCache(String, Int32).new
    cache.write("a", 1)
    cache.write("b", 2)
    cache.read?("-----").should be_nil
    cache.read?("a").should eq 1
    cache.read?("b").should eq 2
  end

  it "read_entry?" do
    cache = MemoryCache(String, Int32).new
    time = Time.local
    cache.write("a", 1, time)
    entry = cache.read_entry?("a").should_not be_nil
    entry.time.should eq time
    entry.value.should eq 1
  end

  it "size" do
    cache = MemoryCache(String, Int32).new
    cache.write("one", 1)
    cache.write("two", 2)
    cache.size.should eq 2
  end

  it "exists?" do
    cache = MemoryCache(String, Int32).new
    cache.write("bla", 1)
    cache.exists?("bla").should be_true
    cache.exists?("-----").should be_false
  end

  it "delete" do
    cache = MemoryCache(String, Int32).new
    cache.write("bla", 1)
    cache.delete("bla").should eq 1
    cache.size.should eq 0
    cache.read?("bla").should be_nil
    cache.delete("bla").should be_nil
  end

  describe "delete_if_older" do
    it "deletes the old key" do
      cache = MemoryCache(String, Int32).new
      cache.write("bla", 1)
      cache.delete_if_older("bla", 9.second).should be_nil
    end

    it "keeps the key" do
      cache = MemoryCache(String, Int32).new
      cache.write("bla", 1)
      cache.delete_if_older("bla", 0.second).should eq 1
    end
  end

  it "clear" do
    cache = MemoryCache(String, Int32).new
    cache.write("bla", 1)
    cache.size.should eq 1
    cache.clear
    cache.size.should eq 0
    cache.read?("bla").should be_nil
  end

  it "write" do
    cache = MemoryCache(String, Int32).new
    cache.write("a", 11).should eq 11
    cache.read?("a").should eq 11
  end

  describe "fetch" do
    it "a value" do
      cache = MemoryCache(String, Int32).new
      cache.write("a", 11)
      cache.fetch("a") { 2 }.should eq 11
    end

    it "not present value" do
      cache = MemoryCache(Int32, Int32).new
      k = 1
      not_found = false
      cache.fetch(k) do
        not_found = true
      end.should be_nil
      cache.read?(k).should be_nil
      not_found.should be_true
    end
  end

  describe "cleanup" do
    it "cleans old keys" do
      cache = MemoryCache(String, Int32).new
      cache.write("a", 1)
      cache.size.should eq 1
      cache.cleanup(0.second).should eq 1
      cache.size.should eq 0
    end

    it "keeps yound keys" do
      cache = MemoryCache(String, Int32).new
      cache.write("a", 1)
      cache.size.should eq 1
      cache.cleanup(9.seconds).should eq 0
      cache.size.should eq 1
    end
  end

  it "each" do
    h = Hash(String, Int32).new
    cache = MemoryCache(String, Int32).new
    cache.write("a", 1)
    cache.write("b", 2)
    cache.each { |k, v| h[k] = v }
    h.should eq({"a" => 1, "b" => 2})
  end

  it "cache with complex key, value" do
    cache = MemoryCache({Int32, String}, {String, Int32}).new
    k = {10, "bla"}
    v = {"haha", 11}
    cache.write(k, v).should eq v
    cache.fetch(k) { v }.should eq(v)
    cache.read?(k).should eq v
    cache.delete(k)
    cache.read?(k).should eq nil
  end

  it "fetch with control flow" do
    cache = MemoryCache(Int32, Int32).new
    k = 10
    cache.fetch(k) do
      break 5
      99
    end.should eq(5)
  end
end
