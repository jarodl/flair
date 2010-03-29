$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lexer'
require 'test/unit'

CODE = <<-EOS
class Wrapper:
    background = "rgb(255, 255, 255)"
    padding = 1

id Navigation:
    background = "rgb(40, 40, 40)"
    float = "left"
EOS

EXPECTED = <<-EOS
[[:CLASS, "class"], [:CONSTANT, "Wrapper"], [:INDENT, 4], [:IDENTIFIER, "background"], ["=", "="], [:STRING, "rgb(255, 255, 255)"], [:NEWLINE, "\n"], [:IDENTIFIER, "padding"], ["=", "="], [:NUMBER, 1], [:DEDENT, 0], [:NEWLINE, "\n"], [:NEWLINE, "\n"], [:ID, "id"], [:CONSTANT, "Navigation"], [:INDENT, 4], [:IDENTIFIER, "background"], ["=", "="], [:STRING, "rgb(40, 40, 40)"], [:NEWLINE, "\n"], [:IDENTIFIER, "float"], ["=", "="], [:STRING, "left"], [:DEDENT, 0]]
EOS

class LexerTest < Test::Unit::TestCase
  def test_tokenize
    assert_equal EXPECTED, Flair::Lexer.new(CODE).tokenize
  end
end
