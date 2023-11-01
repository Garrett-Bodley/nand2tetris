# frozen_string_literal: true

require 'pathname'
require 'pry-nav'

raise ArgumentError, 'Expected a filepath argument (received none)' if ARGV.empty?

argument = ARGV.shift
file_path = Pathname.new(File.expand_path(argument))

raise ArgumentError, 'Provided filepath does not exist' unless file_path.exist?

if file_path.directory?
  files = file_path.children.delete_if { |child| child.extname != '.jack' }
  raise ArgumentError, 'Expected provided directory to contain files of type .jack' if files.empty?
else
  error_msg = "Expected a file of type .jack (received #{file_path.extname})"
  raise ArgumentError, error_msg unless file_path.extname == '.jack'

  files = [file_path]
end

files.each do |file|
  tokenizer = JackTokenizer.new(file)
  compiler = CompilationEngine.new(file)
  output_path = Pathname.new(file).sub_ext('.vm')
  output_file = File.new(out_path, 'w+')

end
