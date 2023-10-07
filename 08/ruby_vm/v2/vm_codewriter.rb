# frozen_string_literal: true

# Writes VM Code
class VMCodeWriter

  def initialize(path)
    @file = File.open(path, 'w')
  end

  def write_infinite_loop
    basename = File.basename(@file.path, '.*')
    instructions = %W[
      (#{basename}.INFINITE_LOOP)
      @#{basename}INFINITE_LOOP
      0; JMP
    ]
    write_instructions(instructions)
  end

  def write_instructions(instruction_arr)
    binding.pry if instruction_arr.nil? || instruction_arr.length.zero?
    instruction_arr.each do |instruction|
      @file.puts instruction
    end
  end
end
