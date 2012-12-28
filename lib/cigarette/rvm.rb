module RVM
  include Colors

  @@rvm = true

  def self.use_it!
    @@rvm = true
  end

  def self.use_system!
    @@rvm = false
  end

  def self.run(ruby)
    if block_given?
      h = {}
      h[:time]   = Time.now
      h[:ruby]   = ruby
      if @@rvm
        h[:output] = `rvm #{ruby} do #{yield} 2>&1`
      else
        h[:output] = `#{yield} 2>&1`
      end
      h[:status] = $?.success? ? "SUCCESS" : "ERROR(S)"
      h[:color]  = $?.success? ? GREEN : RED
      h
    else
      raise "You need to pass a block for RVM.run method."
    end
  end

end
