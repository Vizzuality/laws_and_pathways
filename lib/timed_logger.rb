module TimedLogger
  def self.log(name)
    puts_box "Starting #{name}"
    starts_at = Time.now
    yield
    delta = Time.now - starts_at
    puts_box "Finished #{name} after #{delta} seconds"
  end

  private_class_method def self.puts_box(text)
    puts '*' * (text.length + 4)
    puts "* #{text} *"
    puts '*' * (text.length + 4)
  end
end
