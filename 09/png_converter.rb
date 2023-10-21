# frozen_string_literal: true

require 'chunky_png'
require 'pathname'
require 'pry-nav'

argument = ARGV.shift

file_path = Pathname.new(File.expand_path(argument))
out_path = Pathname.new(Dir.getwd).join("Draw#{file_path.basename('.*').to_s.capitalize}.jack")
output = File.new(out_path, 'w+')
image = ChunkyPNG::Image.from_file(file_path)

width = image.width
height = image.height

white = 0
black = 0
words = []
word = []
(0..height - 1).each do |y|
  (0..width - 1).each do |x|
    color = ChunkyPNG::Color.to_hex(image[x, y])
    word << 0 if color == '#ffffffff'
    word << 1 if color == '#000000ff'
    if word.length == 16
      words << word
      word = []
    end
  end
end

twos_comp_arr = words.map do |word|
  int = word.reverse.join.to_i(2)
  twos_comp = int > 32_767 ? int - 65_536 : int
  twos_comp = '32767 + 1' if twos_comp == -32_768
  twos_comp
  # word.any?(1) ? "    do Memory.poke(memAddr + #{i}, #{twos_comp});" : ''
end

instruction_arr = []
i = 0
while i < twos_comp_arr.length
  num = twos_comp_arr[i]
  if num == 0
    instruction_arr << ''
  elsif num != twos_comp_arr[i + 1]
    instruction_arr << "    do Memory.poke(memAddr + #{i}, #{num});"
  else
    first = i
    i += 1 while twos_comp_arr[i] == twos_comp_arr[i + 1]
    last = i

    loop = %(    let i = #{first};
    while(i < #{last + 1}){
      do Memory.poke(memAddr + i, #{num});
      let i = i + 1;
    })
    instruction_arr << loop
  end
  i += 1
end

instruction_arr.delete_if(&:empty?)
class_name = out_path.basename('.*').to_s
content = %(

class #{class_name}{
  constructor #{class_name} new(){
    return this;
  }

  function void draw(){
    var int i, memAddr;
    let memAddr = 16384;
#{instruction_arr.join("\n")}
    return;
  }
}
)
output.puts content
