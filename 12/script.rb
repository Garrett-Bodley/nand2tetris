require 'pathname'
require 'pry-nav'

wd = Pathname.new(Dir.getwd)

os_files = []

os_files << wd.join('Array.jack')
os_files << wd.join('Keyboard.jack')
os_files << wd.join('Math.jack')
os_files << wd.join('Memory.jack')
os_files << wd.join('Output.jack')
os_files << wd.join('Screen.jack')
os_files << wd.join('String.jack')
os_files << wd.join('Sys.jack')

os_dir = Pathname.new(File.expand_path('MyOS'))

pong_dir = Pathname.new(File.expand_path('../11/Pong'))
pong_files = pong_dir.children.filter { |child| child.extname == '.jack' }

os_files.each do |file|
  FileUtils.cp(file, os_dir)
end

pong_files.each do |file|
  FileUtils.cp(file, os_dir)
end

puts 'Success!'
