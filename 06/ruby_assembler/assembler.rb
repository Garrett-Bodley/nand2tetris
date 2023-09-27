require 'fileutils'
require 'pathname'
require 'pry-nav'
require_relative 'symbol_table.rb'
require_relative 'code_table.rb'
require_relative 'parser.rb'

if ARGV.length != 1
  raise ArgumentError.new("wrong number of arguments (given #{ARGV.length}, expected 1)")
end


path = ARGV.shift
input_path = Pathname.new(File.expand_path(path))
if input_path.extname != ".asm"
  raise ArgumentError.new("invalid file type provided (given #{input_path.extname}, expected .asm)")
end

output_path = input_path.sub_ext(".hack")
output_file = File.open(output_path, "w")

symbol_table = SymbolTable.new
code_table = CodeTable.new
parser = Parser.new(input_path)

# first pass
line_num = 1
machine_code_line_num = 0
while parser.has_more_commands?
  current_line = parser.advance.current_line
  command_type = parser.command_type
  case command_type
    when :l_command
      symbol = parser.symbol
      symbol_table.add_label(symbol, machine_code_line_num)
      puts "LineNum: #{line_num}\nMachine Code Line Num: #{machine_code_line_num}\nCommand Type: #{command_type.to_s}\n\nLine Contents:\n#{current_line}\nADDED TO SYMBOL TABLE\nSymbolTable Key: #{symbol}\nSymbolTable Value: #{symbol_table.get_address(symbol)}\n-------------------------------"
    when :a_command
      puts "Line Num: #{line_num}\nMachine Code Line Num: #{machine_code_line_num}\nCommand Type: #{command_type.to_s}\n\nSkipping Code Comment on Line #{line_num}\n\nLine Contents:\n#{current_line}\n\n--------------------------------"
      machine_code_line_num += 1
    when :c_command
      puts "LineNum: #{line_num}\nMachine Code Line Num: #{machine_code_line_num}\nCommand Type: #{command_type.to_s}\n\nLine Contents:\n#{current_line}\nIGNORED ON FIRST PASS\n\n-------------------------------"
      machine_code_line_num += 1
    when :empty
      puts "Line Num: #{line_num}\nCommand Type: #{command_type}\n\nSkipping Empty Line\n\n--------------------------------"
    when :comment
      puts "Line Num: #{line_num}\nMachine Code Line Num: #{machine_code_line_num}\nCommand Type: #{command_type}\n\nSkipping Code Comment on Line #{line_num}\n\nLine Contents:\n#{current_line}\n\n--------------------------------"
  end
  line_num += 1
end

parser.rewind


# second pass
line_num = 1
while parser.has_more_commands?
  current_line = parser.advance.current_line
  command_type = parser.command_type
  case command_type
    when :l_command
      symbol = parser.symbol
      puts "LineNum: #{line_num}\nCommand Type: #{command_type.to_s}\n\nLine Contents:\n#{current_line}\nSKIPPED ON SECOND PASS\nSymbolTable Key: #{symbol}\nSymbolTable Value: #{symbol_table.get_address(symbol)}\n-------------------------------"
    when :a_command
      if parser.a_command_is_const?
        machine_code = parser.a_command_to_b
      else
        if(symbol_table.contains(parser.symbol))
          machine_code = symbol_table.get_address(parser.symbol).to_s(2).rjust(15, "0")
        else
          machine_code = symbol_table.add_variable(parser.symbol).to_s(2).rjust(15, "0")
        end
      end
      output_file.puts("0#{machine_code}")

      puts "LineNum: #{line_num}\nCommand Type: #{command_type}\n\nLine Contents:\n#{current_line}\nTranslated to 16 bit Binary:\n#{machine_code}\n\n-------------------------------"
    when :c_command

      comp_s = parser.comp
      dest_s = parser.dest
      jump_s = parser.jump

      comp_binary = code_table.comp(comp_s)
      dest_binary = code_table.dest(dest_s)
      jump_binary = code_table.jump(jump_s)

      machine_code = "111#{comp_binary}#{dest_binary}#{jump_binary}"

      output_file.puts(machine_code)

      puts "LineNum: #{line_num}\nCommand Type: #{command_type.to_s}\n\nLine Contents:\n#{current_line}\nTranslated to 16 bit Binary:\n#{machine_code}\n\n-------------------------------"
    when :empty
      puts "Line Num: #{line_num}\nCommand Type: #{command_type}\n\nSkipping Empty Line\n\n--------------------------------"
    when :comment
      puts "LineNum: #{line_num}\nCommand Type: #{command_type.to_s}\n\nSkipping Code Comment on Line #{line_num}\n\nLine Contents:\n#{current_line}\n\n-------------------------------"
  end
  line_num += 1
end

output_file.close
