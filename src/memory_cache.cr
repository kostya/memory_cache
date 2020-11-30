class MemoryCache(K, V)
  struct Entry(V)
    getter value, time

    def initialize(@value : V, @time : Time)
    end
  end

  def initialize
    @cache = {} of K => Entry(V)
  end

  # Returns the number of elements in this `MemoryCache` store.
  def size
    @cache.size
  end

  # Deletes the key.
  def delete(key : K) : V?
    if entry = @cache.delete(key)
      entry.value
    end
  end

  # Delete the key if present and older than the max period.
  def delete_if_older(key : K, max_period : Time::Span, time : Time = Time.local) : V?
    if entry = @cache[key]?
      max_time = time - max_period
      if entry.time < max_time
        @cache.delete(key).try &.value
      end
    end
  end

  # Returns `true` when key given by key exists, otherwise `false`.
  def exists?(key : K) : Bool
    @cache.has_key?(key)
  end

  # Returns the value for the key given by key, or when not found calls the given block with the key and returns nil.
  def fetch(key : K, & : K ->)
    @cache.fetch key do
      yield key
      return
    end.value
  end

  # Returns the value for the key, if present.
  def read?(key : K) : V?
    @cache[key]?.try &.value
  end

  # Returns the value and time for the key, if present.
  def read_entry?(key : K) : Entry(V)?
    @cache[key]?
  end

  # Writes the key with the given value and creation time.
  def write(key : K, value : V, time : Time = Time.local) : V
    @cache[key] = Entry.new(value, time)
    value
  end

  # Calls the given block for each key-value pair and passes in the key and the value.
  def each(& : K, V, Time ->) : Nil
    @cache.each do |key, entry|
      yield key, entry.value, entry.time
    end
  end

  # Empties the whole `MemoryCache` store.
  def clear
    @cache.clear
    self
  end

  # Cleans-up all keys older than the max period, and returns the cleaned count.
  def cleanup(max_period : Time::Span, time : Time = Time.local) : Int32
    max_time = time - max_period
    old_size = size
    @cache.reject! do |_, entry|
      entry.time < max_time
    end
    old_size - size
  end
end
