# frozen_string_literal: true

require 'pry-nav'
require 'pathname'

require_relative 'vm_parser'
require_relative 'vm_codewriter'
require_relative 'vm_arithmetic_translator'
require_relative 'vm_push_pop_translator'
require_relative 'vm_function_translator'

raise ArgumentError, "Wrong number of arguments (given #{ARGV.length}, expected 1)" if ARGV.length != 1

# if path.extname == '.vm' file, continue as currently written
# if path.directory?, get children recursively and write each .vm file
# if
FileTypeError = Class.new(StandardError)

def get_vm_filepaths(path)
  return unless path.directory?
  unless path.children.any? { |child| child.extname == '.vm' }
    raise FileTypeError 'Directory does not contain any .vm files!'
  end

  paths = []
  path.children.each do |child|
    paths << child if child.extname == '.vm'
    paths += get_vm_filepaths(child) if child.directory?
  end
  paths
end

arg_path = ARGV.shift
input_path = Pathname.new(File.expand_path(arg_path))
if input_path.extname != '.vm' && !input_path.directory?
  raise ArgumentError, "Invalid file type provided (given #{input_path.extname}, expected .vm)"
end

if input_path.directory?
  paths = get_vm_filepaths(input_path)
  paths.sort_by! { |path| path.basename.to_s == 'Sys.vm' ? 0 : 1 }
  output_path = input_path.join(input_path.basename).sub_ext('.asm')
else
  output_path = input_path.sub_ext('.asm')
  paths = [input_path]
end

parser = VMParser.new
writer = VMCodeWriter.new(output_path)

push_pop_translator = VMPushPopTranslator.new
arithmetic_translator = VMArithmeticTranslator.new
function_translator = VMFunctionTranslator.new

bootstraps_instructions = function_translator.bootstraps
writer.write_instructions(bootstraps_instructions)

paths.each do |path|
  parser.read_new_file(path)

  filename = path.basename('.*')
  push_pop_translator.filename = filename

  while parser.more_lines?
    parser.advance
    command_type = parser.command_type
    case command_type
    when :comment, :empty
      next
    when :push, :pop
      instructions = push_pop_translator.translate(command_type, parser.arg1, parser.arg2)
    when :arithmetic
      instructions = arithmetic_translator.translate(parser.arg1)
    when :label, :if_goto, :goto
      instructions = function_translator.translate_program_flow(command_type, parser.arg1)
    when :function
      instructions = function_translator.declare_function(parser.arg1, parser.arg2)
    when :call
      instructions = function_translator.call_function(parser.arg1, parser.arg2)
    when :return
      instructions = function_translator.return
    end
    binding.pry if instructions.nil? || instructions.empty?
    writer.write_instructions(instructions)
  end
end

loop_instructions = function_translator.infinite_loop
writer.write_instructions(loop_instructions)
