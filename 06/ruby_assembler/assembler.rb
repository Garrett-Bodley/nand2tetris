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

symbol_table = SymbolTable.new
code_table = CodeTable.new
parser = Parser.new(input_path)

line_num = 1
machine_code_line_num = 0

while parser.has_more_commands?
  # binding.pry
  current_line = parser.advance
  command_type = parser.command_type(parser.current_line)
  case command_type
    when :l_command
      symbol = parser.symbol(current_line)
      binding.pry
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

binding.pry
