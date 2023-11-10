# frozen_string_literal: true

# Writes the VM Code
class VMWriter
  def initialize(output_path)
    @file = File.open(output_path, 'w+')
  end

  def write_push(segment, index)
    @file.puts "push #{segment} #{index}"
  end

  def write_pop(segment, index)
    @file.puts "pop #{segment} #{index}"
  end

  def write_arithmetic(command)
    @file.puts command
  end

  def write_label(string)
    @file.puts "label #{string}"
  end

  def write_goto(string)
    @file.puts "goto #{string}"
  end

  def write_if(string)
    @file.puts "if-goto #{string}"
  end

  def write_function(string, n_locals)
    @file.puts "function #{string} #{n_locals}"
  end

  def write_return
    @file.puts 'return'
  end
end
