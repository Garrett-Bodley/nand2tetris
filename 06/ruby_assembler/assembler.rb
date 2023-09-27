# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'pry-nav'
require_relative 'symbol_table'
require_relative 'code_table'
require_relative 'parser'

raise ArgumentError, "Wrong number of arguments (given #{ARGV.length}, expected 1)" if ARGV.length != 1

path = ARGV.shift
input_path = Pathname.new(File.expand_path(path))
if input_path.extname != '.asm'
  raise ArgumentError, "Invalid file type provided (given #{input_path.extname}, expected .asm)"
end

output_path = input_path.sub_ext('.hack')
output_file = File.open(output_path, 'w')

symbol_table = SymbolTable.new
code_table = CodeTable.new
parser = Parser.new(input_path)

# first pass
line_num = 1
machine_code_line_num = 0
while parser.more_commands?
  current_line = parser.advance
  command_type = parser.command_type
  case command_type
  when :l_command

    symbol = parser.symbol
    symbol_table.add_label(symbol, machine_code_line_num)
    puts "LineNum: #{line_num}\nMachine Code Line Num: #{machine_code_line_num}\nCommand Type: #{command_type.to_s}\n\nLine Contents:\n#{current_line}\nADDED TO SYMBOL TABLE\nSymbolTable Key: #{symbol}\nSymbolTable Value: #{symbol_table.get_address(symbol)}\n-------------------------------" # rubocop:disable Layout/LineLength

  when :a_command

    puts "Line Num: #{line_num}\nMachine Code Line Num: #{machine_code_line_num}\nCommand Type: #{command_type.to_s}\n\nSkipping Code Comment on Line #{line_num}\n\nLine Contents:\n#{current_line}\n\n--------------------------------" # rubocop:disable Layout/LineLength
    machine_code_line_num += 1

  when :c_command

    puts "LineNum: #{line_num}\nMachine Code Line Num: #{machine_code_line_num}\nCommand Type: #{command_type.to_s}\n\nLine Contents:\n#{current_line}\nIGNORED ON FIRST PASS\n\n-------------------------------" # rubocop:disable Layout/LineLength
    machine_code_line_num += 1

  when :empty

    puts "Line Num: #{line_num}\nCommand Type: #{command_type}\n\nSkipping Empty Line\n\n--------------------------------" # rubocop:disable Layout/LineLength

  when :comment

    puts "Line Num: #{line_num}\nMachine Code Line Num: #{machine_code_line_num}\nCommand Type: #{command_type}\n\nSkipping Code Comment on Line #{line_num}\n\nLine Contents:\n#{current_line}\n\n--------------------------------" # rubocop:disable Layout/LineLength

  end
  line_num += 1
end

parser.rewind

# second pass
line_num = 1
while parser.more_commands?
  current_line = parser.advance
  command_type = parser.command_type
  case command_type
  when :l_command

    symbol = parser.symbol
    puts "LineNum: #{line_num}\nCommand Type: #{command_type.to_s}\n\nLine Contents:\n#{current_line}\nSKIPPED ON SECOND PASS\nSymbolTable Key: #{symbol}\nSymbolTable Value: #{symbol_table.get_address(symbol)}\n-------------------------------" # rubocop:disable Layout/LineLength

  when :a_command

    machine_code =
      if parser.a_command_is_const?
        parser.a_command_to_b
      elsif symbol_table.contains(parser.symbol)
        symbol_table.get_address(parser.symbol).to_s(2).rjust(15, '0')
      else
        symbol_table.add_variable(parser.symbol).to_s(2).rjust(15, '0')
      end
    output_file.puts("0#{machine_code}")

    puts "LineNum: #{line_num}\nCommand Type: #{command_type}\n\nLine Contents:\n#{current_line}\nTranslated to 16 bit Binary:\n#{machine_code}\n\n-------------------------------" # rubocop:disable Layout/LineLength

  when :c_command

    comp_s = parser.comp
    dest_s = parser.dest
    jump_s = parser.jump

    comp_binary = code_table.comp(comp_s)
    dest_binary = code_table.dest(dest_s)
    jump_binary = code_table.jump(jump_s)

    machine_code = "111#{comp_binary}#{dest_binary}#{jump_binary}"

    output_file.puts(machine_code)

    puts "LineNum: #{line_num}\nCommand Type: #{command_type.to_s}\n\nLine Contents:\n#{current_line}\nTranslated to 16 bit Binary:\n#{machine_code}\n\n-------------------------------" # rubocop:disable Layout/LineLength
  when :empty
    puts "Line Num: #{line_num}\nCommand Type: #{command_type}\n\nSkipping Empty Line\n\n--------------------------------" # rubocop:disable Layout/LineLength
  when :comment
    puts "LineNum: #{line_num}\nCommand Type: #{command_type.to_s}\n\nSkipping Code Comment on Line #{line_num}\n\nLine Contents:\n#{current_line}\n\n-------------------------------" # rubocop:disable Layout/LineLength
  end
  line_num += 1
end

output_file.close
