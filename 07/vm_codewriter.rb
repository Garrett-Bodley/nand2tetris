# rubocop:disable Metrics/MethodLength
# frozen_string_literal: true

# Writes VM Code
class VMCodeWriter
  ARITHMETIC_OPTIONS = %w[add sub neg eq gt lt and or not].freeze

  def initialize(path)
    binding.pry
    @output_file = File.open(path, 'w')
    @label_basename = path.basename('.*').to_s
    @label_count = 0
  end

  def write_push_pop(command_type, segment, index)
    write_push(segment.to_sym, index) if command_type == :push

  end

  def write_push(segment, val)
    write_constant if segment == :constant
  end

  def write_constant(val)
    # load new val into D
    @output_file.puts "@#{val}"
    @output_file.puts 'D=A'
    # set A to SP
    @output_file.puts '@SP'
    # set A to RAM[SP] (ADDRESS SP POINTS TO) THIS IS AN AVAILABLE ADDRESS
    @output_file.puts 'A=M'
    # WRITE VAL TO TOP OF STACK
    @output_file.puts 'M=D'
    # INCREMENT SP
    @output_file.puts '@SP'
    @output_file.puts 'M=M+1'
  end

  def write_arithmetic(string)
    case string.to_sym
    when :add
      write_add
    when :sub
      write_sub
    end
  end

  def write_add
    %w[@SP AM=M-1 D=M A=A-1 M=M+D].each do |assembly_instruction|
      output_file.puts assembly_instruction
    end
  end

  def write_sub
    %w[@SP AM=M-1 D=M A=A-1 M=M-D].each do |command|
      @output_file.puts command
    end
  end

  def write_eq
    %w[@SP A=M-1 D=M A=A-1]

    # @SP
    # AM=M-1
    # D=M
    # A=A-1
    # M=M-D
    # 

    # (SET_TRUE)

    # (SET_FALSE)


  end

  def write_infinite_loop
    @output_file.puts '(INFINITE_LOOP)'
    @output_file.puts '@INFINITE_LOOP'
    @output_file.puts '0; JMP'
  end
end



# PUSH CONSTANT 7
#
# LOAD 3 INTO D REGISTER
# @7
# D = A
# GET ADDRESS IN STACK POINTER
# @STACK_POINTER
# A = M
# PUSH 3 ONTO STACK
# M = D
# INCREMENT SP
# @STACK_POINTER
# M = M + 1

# rubocop:enable Metrics/MethodLength
