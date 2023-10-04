# frozen_string_literal: true

# Writes VM Code
class VMCodeWriter
  attr_reader :filename

  def initialize(path)
    @file = File.open(path, 'w')
    @filename = path.basename('.*').to_s
    @push_pop_translator = VMPushPopTranslator.new(@filename)
    @arithmetic_translator = VMArithmeticTranslator.new
    @compare_count = 0
  end

  def filename=(filename)
    @filename = filename
    @push_pop_translator.filename = filename
  end

  def write_label(label)
    unless label.match(/^[a-zA-Z_:.][a-zA-Z0-9_:.]*$/)
      throw ArgumentError "Invalid label provided. A valid label is a string composed of any sequence of letters, digits, underscore (_), dot (.), and colon (:) that does not begin with a digit. (Received: #{label})" # rubocop:disable Layout/LineLength
    end
    instructions = [
      '// Label',
      "(#{label})"
    ]
    write_instructions(instructions)
  end

  def write_goto(label)
    instructions = [
      '// goto',
      "@#{label}",
      '0; JMP'
    ]
    write_instructions(instructions)
  end

  def write_if_goto(label)
    # if stack[stack.length - 1] == 0
    #   jump
    instructions = [
      '// if-goto',
      '@SP',
      'AM=M-1',
      'D=M',
      "@#{label}",
      'D;JNE'
    ]
    write_instructions(instructions)
  end

  def write_push_pop(command_type, segment, index)
    instructions = @push_pop_translator.translate(command_type, segment.to_sym, index)
    write_instructions(instructions)
  end

  def write_arithmetic(op_string)
    instructions = @arithmetic_translator.translate(op_string.to_sym)
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
