class Numeric

  def second
    self
  end

  def minute
    self * 60
  end

  def hour
    self * 3600
  end

  alias :seconds :second
  alias :minutes :minute
  alias :hours   :hour

end
