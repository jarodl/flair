$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lexer'

code = <<-EOS
class Wrapper:
    background = "rgb(255, 255, 255)"
    padding = 1
    if true:
        color = "red"
    test = "true"


id Navigation:
    background = "rgb(40, 40, 40)"
    float = "left"
EOS

p Flair::Lexer.new(code).tokenize
