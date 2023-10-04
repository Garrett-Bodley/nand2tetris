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
      "(#{@filename}.#{label})"
    ]
    write_instructions(instructions)
  end

  def write_goto(label)
    instructions = [
      '// goto',
      "@#{@filename}.#{label}",
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
      "@#{@filename}.#{label}",
      'D;JNE'
    ]
    write_instructions(instructions)
  end

  def write_function(function_name, arg_count)
    write_label(function_name)
    count = 0
    while count < arg_count.to_i
      write_push_pop(:push, 'constant', '0')
      count += 1
    end
  end

  def write_return
    save_frame_to_local_variables = %w[
      @LCL
      D=M
      @14
      M=D
    ]
    save_return_address_to_local_variable = %w[
      //\ Saving\ the\ return\ address!
      @LCL
      D=M
      @5
      A=D-A
      D=M
      @15
      M=D
    ]
    pop_to_arg = @push_pop_translator.translate(:pop, :argument, '0')
    # pop_to_arg = %w[
    #   @SP
    #   AM=M-1
    #   D=M
    #   @ARG
    #   M=D
    # ]
    sp_equals_arg_plus_one = %w[
      @ARG
      D=M+1
      @SP
      M=D
    ]
    restore_that = %w[
      @14
      D=M
      @1
      D=D-A
      @THAT
      M=D
    ]
    restore_this = %w[
      @14
      D=M
      @2
      D=D-A
      @THIS
      M=D
    ]
    restore_arg = %w[
      @14
      D=M
      @3
      D=D-A
      @ARG
      M=D
    ]
    restore_lcl = %w[
      @14
      D=M
      @4
      D=D-A
      @LCL
      M=D
    ]
    goto_return_addr = %w[
      //\ Going\ To\ the\ Return\ Address!
      @15
      D=M
      0;JMP
    ]
    instructions = save_frame_to_local_variables + save_return_address_to_local_variable + pop_to_arg + sp_equals_arg_plus_one + restore_that + restore_this + restore_arg + restore_lcl + goto_return_addr
    write_instructions(instructions)
  end

  def write_push_pop(command_type, segment_string, index)
    instructions = @push_pop_translator.translate(command_type, segment_string.to_sym, index)
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
