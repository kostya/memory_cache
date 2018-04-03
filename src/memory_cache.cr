class MemoryCache(K, V)
  VERSION = "0.2"

  struct Entry(V)
    getter value, expired_at

    def initialize(@value : V, @expired_at : Time? = nil)
    end

    def expired?(now = Time.now)
      if expired_at = @expired_at
        expired_at < now
      else
        false
      end
    end
  end

  def initialize
    @cache = {} of K => Entry(V)
  end

  def size
    @cache.size
  end

  def delete(k : K) : V?
    if v = @cache.delete(k)
      v.value
    end
  end

  def exists?(k : K) : Bool
    @cache.has_key?(k)
  end

  def fetch(k : K, expires_in = nil, used_count = nil, &block : -> V) : {Symbol, V}
    if v = read(k)
      {:cache, v}
    else
      v = write(k, block.call, expires_in, used_count)
      {:fetch, v}
    end
  end

  def read(k : K) : V?
    read_entry(k).try &.value
  end

  def write(k : K, v : V, expires_in = nil, used_count = nil) : V
    expired_at = if expires_in
                   Time.now + expires_in.to_f.seconds
                 end
    @cache[k] = Entry.new(v, expired_at)
    v
  end

  def update(k : K, &block : V -> V)
    if e = read_entry(k)
      new_v = block.call(e.value)
      @cache[k] = Entry.new(new_v, e.expired_at)
      new_v
    end
  end

  def each(&block : K, V ->)
    deleted = [] of K
    @cache.each do |k, v|
      if v.expired?
        deleted << k
      else
        block.call(k, v.value)
      end
    end
    deleted.each { |k| delete(k) }
    self
  end

  def clear
    @cache.clear
    self
  end

  # cleanup all expired values
  def cleanup
    now = Time.now
    c = 0
    @cache.each do |k, v|
      if v.expired?(now)
        @cache.delete(k)
        c += 1
      end
    end
    {@cache.size, c}
  end

  private def read_entry(k : K) : Entry(V)?
    if e = @cache[k]?
      if e.expired?
        @cache.delete(k)
        nil
      else
        e
      end
    end
  end
end
