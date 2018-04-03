require "./spec_helper"

describe MemoryCache do
  it "read" do
    CACHE.read("-----").should eq nil
    CACHE.read("bla").should eq 1
    CACHE.read("haha").should eq 2
  end

  it "size" do
    CACHE.size.should eq 2
  end

  it "exists?" do
    CACHE.exists?("bla").should eq true
    CACHE.exists?("-----").should eq false
  end

  it "delete" do
    CACHE.delete("bla").should eq 1
    CACHE.size.should eq 1
    CACHE.read("bla").should eq nil
    CACHE.delete("bla").should eq nil
  end

  it "clear" do
    CACHE.clear
    CACHE.size.should eq 0
    CACHE.read("bla").should eq nil
  end

  it "write" do
    CACHE.write("jjj", 11).should eq 11
    CACHE.read("jjj").should eq 11
  end

  it "fetch" do
    CACHE.fetch("bla") { 2 }.should eq({:cache, 1})
    CACHE.fetch("----") { 2 }.should eq({:fetch, 2})
    CACHE.fetch("----") { 2 }.should eq({:cache, 2})

    CACHE.read("----").should eq 2
  end

  it "cleanup" do
    CACHE.size.should eq 2
    CACHE.cleanup
    CACHE.size.should eq 2
  end

  it "update" do
    CACHE.update("bla") { |v| v + 1 }.should eq 2
    CACHE.read("bla").should eq 2

    CACHE.update("----") { |v| v + 1 }.should eq nil
    CACHE.read("----").should eq nil
  end

  it "each" do
    h = {} of String => Int32
    CACHE.each { |k, v| h[k] = v }
    h.should eq({"bla" => 1, "haha" => 2})
  end

  describe "expires_in" do
    it "write" do
      CACHE.write("ex1", 22, expires_in: 0.1.seconds)
      100.times do
        CACHE.read("ex1").should eq 22
      end
      CACHE.size.should eq 3
      sleep 0.2
      CACHE.read("ex1").should eq nil
      CACHE.size.should eq 2
    end

    it "fetch" do
      CACHE.fetch("ex2", expires_in: 0.1.seconds) { 22 }
      100.times do
        CACHE.read("ex2").should eq 22
      end
      CACHE.size.should eq 3
      sleep 0.2
      CACHE.read("ex2").should eq nil
      CACHE.size.should eq 2
    end

    it "cleanup" do
      CACHE.fetch("ex2", expires_in: 0.1.seconds) { 22 }
      100.times do
        CACHE.read("ex2").should eq 22
      end
      CACHE.size.should eq 3
      sleep 0.2
      CACHE.cleanup.should eq({2, 1})
      CACHE.size.should eq 2
    end

    it "each" do
      CACHE.fetch("ex2", expires_in: 0.1.seconds) { 22 }
      h = {} of String => Int32
      CACHE.each { |k, v| h[k] = v }
      h.should eq({"bla" => 1, "haha" => 2, "ex2" => 22})
      CACHE.size.should eq 3

      sleep 0.11

      h = {} of String => Int32
      CACHE.each { |k, v| h[k] = v }
      h.should eq({"bla" => 1, "haha" => 2})
      CACHE.size.should eq 2
    end
  end

  it "integration" do
    CACHE.fetch("ex1", expires_in: 0.1.seconds) { 11 }
    CACHE.fetch("ex2", expires_in: 0.2.seconds) { 22 }
    CACHE.write("ex3", 33, expires_in: 0.3.seconds)
    CACHE.write("ex4", 44)
    CACHE.cleanup
    CACHE.size.should eq 6
    100.times do
      CACHE.read("ex1").should eq 11
      CACHE.read("ex2").should eq 22
      CACHE.read("ex3").should eq 33
      CACHE.read("ex4").should eq 44
    end

    sleep 0.21
    CACHE.cleanup
    CACHE.size.should eq 4

    100.times do
      CACHE.read("ex1").should eq nil
      CACHE.read("ex2").should eq nil
      CACHE.read("ex3").should eq 33
      CACHE.read("ex4").should eq 44
    end

    sleep 0.1
    CACHE.read("ex1").should eq nil
    CACHE.read("ex2").should eq nil
    CACHE.read("ex3").should eq nil
    CACHE.read("ex4").should eq 44
  end

  it "cache with complex key, value" do
    cache = MemoryCache({Int32, String}, {String, Int32}).new
    k = {10, "bla"}
    v = {"haha", 11}
    cache.fetch(k) { v }.should eq({:fetch, v})
    cache.read(k).should eq v
    cache.delete(k)
    cache.read(k).should eq nil
  end
end
