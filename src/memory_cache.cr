class MemoryCache(K, V)
  VERSION = "0.1"

  def initialize
    @cache = {} of K => {Time, V}
  end

  def size
    @cache.size
  end

  def delete(k : K) : V?
    if v = @cache.delete(k)
      v[1]
    end
  end

  def exists?(k : K) : Bool
    @cache.has_key?(k)
  end

  def fetch(k : K, expires_in = nil, used_count = nil, &block : -> V) : V
    read(k) || write(k, block.call, expires_in, used_count)
  end

  def read(k : K) : V?
    if v = @cache[k]?
      at, value = v
      if at < Time.now
        @cache.delete(k)
        nil
      else
        value
      end
    end
  end

  def write(k : K, v : V, expires_in = nil, used_count = nil) : V
    expired_at = Time.now + (expires_in || 10.years)
    @cache[k] = { expired_at, v }
    v
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
      at, _ = v
      if at < Time.now
        @cache.delete(k)
        c += 1
      end
    end
    { @cache.size, c }
  end
end
