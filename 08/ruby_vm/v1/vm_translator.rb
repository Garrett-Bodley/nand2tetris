# frozen_string_literal: true

require 'pry-nav'
require 'pathname'

require_relative 'vm_parser'
require_relative 'vm_codewriter'
require_relative 'vm_arithmetic_translator'
require_relative 'vm_push_pop_translator'
require_relative 'vm_function_translator'

raise ArgumentError, "Wrong number of arguments (given #{ARGV.length}, expected 1)" if ARGV.length != 1

path = ARGV.shift
input_path = Pathname.new(File.expand_path(path))
if input_path.extname != '.vm'
  raise ArgumentError, "Invalid file type provided (given #{input_path.extname}, expected .vm)"
end

output_path = input_path.sub_ext('.asm')

parser = VMParser.new(input_path)
writer = VMCodeWriter.new(output_path)

while parser.more_lines?
  parser.advance
  command_type = parser.command_type
  case command_type
  when :push, :pop
    writer.write_push_pop(command_type, parser.arg1, parser.arg2)
  when :arithmetic
    writer.write_arithmetic(parser.arg1)
  when :label
    writer.write_label(parser.arg1)
  when :if_goto
    writer.write_if_goto(parser.arg1)
  when :goto
    writer.write_goto(parser.arg1)
  when :function
    writer.write_function(parser.arg1, parser.arg2)
  when :return
    writer.write_return
  when :call
    writer.write_call(parser.arg1, parser.arg2)
  end
end

writer.write_infinite_loop
