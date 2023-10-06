# frozen_string_literal: true

# Writes VM Code
class VMCodeWriter
  attr_reader :filename

  def initialize(path)
    @file = File.open(path, 'w')
    @filename = path.basename('.*').to_s
    @push_pop_translator = VMPushPopTranslator.new(@filename)
    @arithmetic_translator = VMArithmeticTranslator.new(@filename)
    @return_count = 0
  end

  def filename=(filename)
    @filename = filename
    @push_pop_translator.filename = filename
    @arithmetic_translator.filename = filename
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
      //\ Saving\ LCL\ to\ register\ 14!
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
    sp_equals_arg_plus_one = %w[
      @ARG
      D=M+1
      @SP
      M=D
    ]
    # restore that is broken
    # NEED TO GRAB RAM[316]
    restore_that = %w[
      @14
      D=M
      @1
      A=D-A
      D=M
      @THAT
      M=D
    ]
    restore_this = %w[
      @14
      D=M
      @2
      A=D-A
      D=M
      @THIS
      M=D
    ]
    restore_arg = %w[
      @14
      D=M
      @3
      A=D-A
      D=M
      @ARG
      M=D
    ]
    restore_lcl = %w[
      @14
      D=M
      @4
      A=D-A
      D=M
      @LCL
      M=D
    ]
    goto_return_addr = %w[
      //\ Going\ To\ the\ Return\ Address!
      @15
      A=M
      0;JMP
    ]
    instructions = save_frame_to_local_variables + save_return_address_to_local_variable + pop_to_arg + sp_equals_arg_plus_one + restore_that + restore_this + restore_arg + restore_lcl + goto_return_addr
    write_instructions(instructions)
  end

  def write_call(function_name, arg_count)
    # 1. Push return_address
    #   a. generate label
    #   b. push label value to stack
    # 2. push LCL
    # 3. push ARG
    # 4. push THIS
    # 5. push THAT
    # 6. ARG = SP - 5 - nArgs
    # 7. LCL = SP
    # 8. goto function
    # 9. (return_address) # inject return address into assembly code
    return_label_s = make_return_label

    # 1. Push return_address
    #   a. generate label
    #   b. push label value to stack
    push_return = %W[
      //\ Pushing\ Return\ Address!
      @#{return_label_s}
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]
    # 2. push LCL
    push_lcl = %w[
      @LCL
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]
    # 3. push ARG
    push_arg = %w[
      @ARG
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]
    # 4. push THIS
    push_this = %w[
      @THIS
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]
    # 5. push THAT
    push_that = %w[
      @THAT
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]

    # 6. ARG = SP - 5 - nArgs
    set_arg = %W[
      @SP
      D=M
      @5
      D=D-A
      @#{arg_count}
      D=D-A
      @ARG
      M=D
    ]

    # 7. LCL = SP
    set_lcl = %w[
      @SP
      D=M
      @LCL
      M=D
    ]
    # 8. goto function
    goto_function = %W[
      @#{@filename}.#{function_name}
      0;JMP
    ]
    # 9. (return_address) # inject return address into assembly code
    inject_return_label = %W[
      (#{return_label_s})
    ]
    instructions = push_return + push_lcl + push_arg + push_this + push_that + set_arg + set_lcl + goto_function + inject_return_label
    write_instructions(instructions)
  end

  def make_return_label
    label = "#{@filename}.RETURN.#{@return_count}"
    @return_count += 1
    label
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
