# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

require_relative 'jack_tokenizer'
require_relative 'compilation_engine'

raise ArgumentError, 'Expected a filepath argument (received none)' if ARGV.empty?

DIRECTORY_NAME = 'Output'

argument = ARGV.shift
file_path = Pathname.new(File.expand_path(argument))

raise ArgumentError, 'Provided filepath does not exist' unless file_path.exist?

if file_path.directory?
  dir_path = file_path.join(DIRECTORY_NAME)

  files = file_path.children.delete_if { |child| child.extname != '.jack' }
  raise ArgumentError, 'Expected provided directory to contain files of type .jack' if files.empty?
else
  error_msg = "Expected a file of type .jack (received #{file_path.extname})"
  raise ArgumentError, error_msg unless file_path.extname == '.jack'

  dir_path = file_path.parent.join(DIRECTORY_NAME)
  files = [file_path]
end

Dir.mkdir(dir_path) unless Dir.exist?(dir_path)

files.each do |file|
  tokenizer = JackTokenizer.new(file)
  # compiler = CompilationEngine.new(file)
  output_path = dir_path.join(file.basename('.*').to_s + 'T').sub_ext('.xml')
  output_file = File.open(output_path, 'w+')
  tokenizer.scan_lines
  if tokenizer.errors?
    tokenizer.errors.each do |err|
      puts "Invalid character(s) '\e[4:3m#{err.string}\e[0m' in #{file.basename} on line #{err.line_num}"
    end
    break
  end
  output_file.puts '<tokens>'
  tokenizer.tokens.each do |token|
    output_file.puts token.to_s
  end
  output_file.puts '</tokens>'
end
