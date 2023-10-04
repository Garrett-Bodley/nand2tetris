# frozen_string_literal: true

# Writes VM Code
class VMCodeWriter
  def initialize(path)
    @file = File.open(path, 'w')
    @basename = path.basename('.*').to_s
    @push_pop_translator = VMPushPopTranslator.new(@basename)
    @arithmetic_translator = VMArithmeticTranslator.new
    @compare_count = 0
  end

  def write_push_pop(command_type, seg_sym, index)
    instructions = @push_pop_translator.translate(command_type, seg_sym, index)
    write_instructions(instructions)
  end

  def write_arithmetic(operation_sym)
    instructions = @arithmetic_translator.translate(operation_sym)
    write_instructions(instructions)
  end

  def write_infinite_loop
    instructions = [
      '(INFINITE_LOOP)',
      '@INFINITE_LOOP',
      '0; JMP'
    ]
    write_instructions(instructions)
  end

  def write_instructions(instruction_arr)
    instruction_arr.each do |instruction|
      @file.puts instruction
    end
  end
end
