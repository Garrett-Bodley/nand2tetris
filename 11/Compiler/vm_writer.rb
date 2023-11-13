# frozen_string_literal: true

# Writes the VM Code
class VMWriter
  SEGMENTS = %w[constant argument local static this that pointer temp].freeze
  attr_reader :file

  def initialize(output_path)
    @file = File.open(output_path, 'w+')
  end

  def write_push(segment, index)
    check_segment(segment)
    @file.puts "push #{segment} #{index}"
  end

  def write_pop(segment, index)
    check_segment(segment)
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

  def write_call(name, n_args)
    @file.puts "call #{name} #{n_args}"
  end

  def write_return
    @file.puts 'return'
  end

  private

  def check_segment(segment)
    return if SEGMENTS.include?(segment)

    raise ArgumentError,
          "Invalid segment, expected one of: constant, argument, local, static, this, that, pointer, temp. Received: #{segment}" # rubocop:disable Layout/LineLength
  end
end
