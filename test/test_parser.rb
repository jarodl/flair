$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'parser'

code = <<-EOS
class Wrapper:
    background = "rgb(255, 255, 255)"
EOS

puts "From flair:"
puts
puts code
puts
puts "To CSS:"
puts
flair = Parser.new.parse(code).compile
puts flair
