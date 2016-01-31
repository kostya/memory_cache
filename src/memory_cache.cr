class MemoryCache(K, V)
  VERSION = "0.1"

  struct Entry(V)
    getter value, expired_at
    def initialize(@value : V, @expired_at = nil)
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
    if v = @cache[k]?
      if v.expired?
        @cache.delete(k)
        nil
      else
        v.value
      end
    end
  end

  def write(k : K, v : V, expires_in = nil, used_count = nil) : V
    expired_at = if expires_in
      expired_at = Time.now + expires_in.to_f.seconds
    end
    @cache[k] = Entry.new(v, expired_at)
    v
  end

  def update(k : K, &block : V -> V)
    if v = @cache[k]?
      if v.expired?
        @cache.delete(k)
        nil
      else
        new_v = block.call(v.value)
        @cache[k] = Entry.new(new_v, v.expired_at)
        new_v
      end
    end
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
    { @cache.size, c }
  end
end
