require 'strscan'

module Flair
  # The Lexer for Flair. This will take a string and convert
  # it to tokens for parsing.
  class Lexer

    KEYWORDS = ["if", "class", "id", "true", "false", "nil"]

    REGEX = {
      :identifier => /\A([a-z]\w*[-]?\w*)/,
      :constant => /\A([A-Z]\w*)/,
      :number => /\A([0-9]+)/,
      :string => /\A"(.*?)"/,
      :indent => /\A\:\n( +)/m,
      :newline => /\A\n( *)/m,
      :whitespace => /\A /,
      :character => /./
    }

    attr_reader :tokens

    def initialize(code)
      # Cleanup code by removing extra line breaks
      @scanner = StringScanner.new(code.chomp!)
      @indent_stack = []
      @current_indent = 0
      # Collection of all parsed tokens in the form [:TOKEN_TYPE, value]
      @tokens = []
    end

    def tokenize
      while !@scanner.eos?
        if token = identifier || constant || number || string || newline || indent || whitespace || single_character
          # Needs refactored
          if token[0].is_a?(Array)
            token.each {|a| @tokens << a}
          elsif token.is_a?(Array)
            @tokens << token
          end
        else
          skip
        end
      end
      close_open_blocks
      @tokens
    end

    def close_open_blocks
      while indent = @indent_stack.pop
        @tokens << [:DEDENT, @indent_stack.first || 0]
      end
    end

    # Move the scanner pointer forward until we find something.
    def skip
      REGEX.values.each do |regex|
        return if @scanner.skip_until(regex)
      end
    end

    # class, id, etc.
    def identifier
      return unless t = @scanner.scan(REGEX[:identifier])
      if KEYWORDS.include?(t)
        # Keywords are special identifiers with their own name, for example
        # 'class' would have the token [:CLASS, "class"]
        [t.upcase.to_sym, t]
      else
        # Anything that is not a keyword is an identifier, such as
        # [:IDENTIFIER, "background"] for something like background="red"
        [:IDENTIFIER, t]
      end
    end

    # Class names or constants starting with a capital letter
    def constant
      return unless t = @scanner.scan(REGEX[:constant])
      [:CONSTANT, t]
    end

    # Matches numbers (duh)
    def number
      return unless t = @scanner.scan(REGEX[:number])
      [:NUMBER, t.to_i]
    end

    # Matches anything contained in quotes ex: "Bob"
    def string
      return unless t = @scanner.scan(REGEX[:string])
      t.gsub!(/\"/, '')
      [:STRING, t]
    end

    # Spaces determine indent level
    # Matches : <newline> <space>
    #
    # 3 cases:
    #
    # if true: # 1) the block is created
    #   line 1
    #   line 2 # 2) a new line inside of the block
    # continue # dedent the block
    def indent
      return unless t = @scanner.scan(REGEX[:indent])
      t.gsub!(/\n/, '').gsub!(/:/, '')

      if t.size <= @current_indent
        raise "Bad indent level"
      end

      @current_indent = t.size
      @indent_stack.push(@current_indent)
      [:INDENT, t.size]
    end

    # Needs refactored.
    def newline
      return unless t = @scanner.scan(REGEX[:newline])
      t.gsub!(/\n/, '')

      if t.size == @current_indent
        # still in the same block so there is nothing to do
        token = [:NEWLINE, "\n"]
      elsif t.size < @current_indent
        token = []
        @indent_stack.pop
        @current_indent = @indent_stack.first || 0
        # this could be a problem, it was previously returning a DEDENT
        # value of 0 everytime, but returning the amount that was un-indented
        # seemed more appropriate
        token << [:DEDENT, @current_indent]
        token << [:NEWLINE, "\n"]
      else
        raise "Missing ':'"
      end
      token
    end

    # Ignore whitespace
    def whitespace
      @scanner.skip(REGEX[:whitespace])
    end

    # All single characters are treated as a token
    # ex: ( ) , . ! ?
    def single_character
      return unless t = @scanner.scan(REGEX[:character])
      [t, t]
    end

  end
end
