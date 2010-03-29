require 'strscan'

module Flair
  # The Lexer for Flair. This will take a string and convert
  # it to tokens for parsing.
  class Lexer

    KEYWORDS = ["class", "id", "true", "false", "nil"]

    REGEX = {
      :identifier => /\A([a-z]\w*)/,
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
      # Collection of all parsed tokens in the form [:TOKEN_TYPE, value]
      @tokens = []
    end

    def tokenize
      while !@scanner.eos?
        if token = identifier || constant || number || string || indent || whitespace || single_character
          @tokens << token
        else
          skip
        end
      end
      @tokens
    end

    def skip
      REGEX.values.each do |regex|
        return if @scanner.skip_until(regex)
      end
    end

    # class, id, etc.
    def identifier
      return unless t = @scanner.scan(REGEX[:identifier])
      # Keywords are special identifiers with their own name, for example
      # 'class' would have the token [:CLASS, "class"]
      if KEYWORDS.include?(t)
        [t.upcase.to_sym, t]
      else
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
      return unless t = @scanner.scan(REGEX[:newline])
      [:NEWLINE, t]
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

#    def tokenize
#      # Current character position we are parsing
#      i = 0
#
#      # Current indent level is the number of spaces in the last indent.
#      current_indent = 0
#      # We keep track of the indentation levels we are in so that when we dedent,
#      # we can check if we're on the correct level.
#      indent_stack = []
#
#      # This is how to implement a very simple scanner.
#      # Scan one character at a time until you find something to parse.
#      while i < @code.size
#        chunk = @code[i..-1]
#
#        # Matching standard tokens.
#        #
#        # Matching class, id, etc.
#        if identifier = chunk[/\A([a-z]\w*)/, 1]
#          # Keywords are special identifiers tagged with their own name, 'class'
#          # wil result in an [:CLASS, "class"] token
#          if KEYWORDS.include?(identifier)
#            @tokens << [identifier.upcase.to_sym, identifier]
#            # Non-keyword identifiers include method and variable names
#          else
#            @tokens << [:IDENTIFIER, identifier]
#          end
#
#          # skip what we just parsed
#          i += identifier.size
#
#        # Matching class names and constants starting with a capital letter
#        elsif constant = chunk[/\A([A-Z]\w*)/, 1]
#          @tokens << [:CONSTANT, constant]
#          i += constant.size
#
#        elsif number = chunk[/\A([0-9]+)/, 1]
#          @tokens << [:NUMBER, number.to_i]
#          i += number.size
#
#        elsif string = chunk[/\A"(.*?)"/, 1]
#          @tokens << [:STRING, string]
#          i += string.size + 2
#
#          # Match other KEYWORDS here..
#          #
#
#
#          # Indentation magic!
#          # We have to take care of 3 cases:
#          #
#          #   if true: # 1) the block is created
#          #     line 1
#          #     line 2 # 2) new line inside of block
#          #   continue # 3) dedent
#          #
#          # This elsif takes care of the first case. The number of spaces will
#          # determine the indent level.
#        elsif indent = chunk[/\A\:\n( +)/m, 1] # Matches ": <newline> <spaces>"
#          # When we create a new block we expect the indent level to go up
#          if indent.size <= current_indent
#            raise "Bad indent level, got #{indent.size} indents, " +
#              "expected > #{current_indent}"
#          end
#          # Adjust the current indentation level
#          current_indent = indent.size
#          indent_stack.push(current_indent)
#          @tokens << [:INDENT, indent.size]
#          i += indent.size + 2
#
#          # This elsif takes care of the last two cases:
#          # Case 2: We stay in the same block if the indent level (number of
#          #         spaces) is the same as the current_indent.
#          # Case 3: Close the current block, if the indent level (number of
#          #         spaces) is lower than current_indent
#        elsif indent = chunk[/\A\n( *)/m, 1] # Matches "<newline> <spaces>"
#          if indent.size == current_indent # Case 2
#            # Nothing to do, still in the same block
#            @tokens << [:NEWLINE, "\n"]
#          elsif indent.size < current_indent # Case 3
#            indent_stack.pop
#            current_indent = indent_stack.first || 0
#            @tokens << [:DEDENT, indent.size]
#            @tokens << [:NEWLINE, "\n"]
#          else # indent.size > current_indent, error!
#            # Cannot increase indent level without using ":", so this is an error.
#            raise "Missing ':'"
#          end
#          i += indent.size + 1
#
#          # Ignore whitespace
#        elsif chunk.match(/\A /)
#          i += 1
#
#          # We treat all other single characters as a token. Eg.: ( ) , . !
#        else
#          value = chunk[0, 1]
#          @tokens << [value, value]
#          i += 1
#        end
#
#      end
#
#      # Close all open blocks
#      while indent = indent_stack.pop
#        @tokens << [:DEDENT, indent_stack.first || 0]
#      end
#
#      @tokens
#    end
  end
end
