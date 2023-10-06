# frozen_string_literal: true

# Writes VM Code
class VMCodeWriter
  attr_reader :filename

  def initialize(path)
    @file = File.open(path, 'w')
    @filename = path.basename('.*').to_s
    @push_pop_translator = VMPushPopTranslator.new(@filename)
    @arithmetic_translator = VMArithmeticTranslator.new(@filename)
    @function_translator = VMFunctionTranslator.new(@filename)
    @return_count = 0
  end

  def filename=(filename)
    @filename = filename
    @push_pop_translator.filename = filename
    @arithmetic_translator.filename = filename
    @function_translator.filename = filename
  end

  def write_label(label)
    instructions = @function_translator.label(label)
    write_instructions(instructions)
  end

  def write_goto(label)
    instructions = @function_translator.goto(label)
    write_instructions(instructions)
  end

  def write_if_goto(label)
    instructions = @function_translator.if_goto(label)
    write_instructions(instructions)
  end

  def write_function(function_name, arg_count)
    instructions = @function_translator.declare_function(function_name, arg_count)
    write_instructions(instructions)
  end

  def write_return
    instructions = @function_translator.return
    write_instructions(instructions)
  end

  def write_call(function_name, arg_count)
    instructions = @function_translator.call(function_name, arg_count)
    write_instructions(instructions)
  end

  def write_push_pop(command_type, segment_string, index)
    instructions = @push_pop_translator.translate(command_type, segment_string.to_sym, index)
    write_instructions(instructions)
  end

  def write_arithmetic(op_string)
    instructions = @arithmetic_translator.translate(op_string.to_sym)
    binding.pry if !instructions
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
