class Parser

token CLASS
# token IF ELSE # leave out if and if-else for now
token ID
token NEWLINE
token NUMBER
token STRING
token TRUE FALSE NIL
token IDENTIFIER
token CONSTANT
token INDENT DEDENT

rule

  # All parsing will end in this rule, being the trunk of the AST.
  Root:
    /* nothing */                     { result = Nodes.new([]) }
  | Expressions                       { result = val[0] }
  ;


  # Any list of expressions, class or method body, seperated by line breaks.
  Expressions:
    Expression                        { result = Nodes.new(val) }
  | Expressions Terminator Expression { result = val[0] << val[2] }
    # To ignore trailing line breaks
  | Expressions Terminator            { result = Nodes.new([val[0]]) }
  ;

  # All types of expressions in our language
  Expression:
    Literal
  | Call
  | Constant
  | Assign
  | Class
  | Id
  # | If # for adding if statements later
  ;

  # All tokens that can terminate an expression
  Terminator:
    NEWLINE
  | ";"
  ;

  # All hard-coded values
  Literal:
    NUMBER                            { result = LiteralNode.new(val[0]) }
  | STRING                            { result = LiteralNode.new(val[0]) }
  | TRUE                              { result = LiteralNode.new(true) }
  | FALSE                             { result = LiteralNode.new(false) }
  | NIL                               { result = LiteralNode.new(nil) }
  ;

  # A method call
  Call:
    # method
    IDENTIFIER                        { result = CallNode.new(nil, val[0]) }
    # receiver.method
  | Expression "." IDENTIFIER         { result = CallNode.new(val[0], val[2]) }
    # no need to implement method calls with arguments at this stage
  ;

  # No need for arg list.
  #

  Constant:
    CONSTANT                          { result = GetConstantNode.new(val[0]) }
  ;

  # assignment to a variable or constant
  Assign:
    IDENTIFIER "=" Expression         { result = SetLocalNode.new(val[0], val[2]) }
    # this might not be needed
  | CONSTANT "=" Expression           { result = SetConstantNode.new(val[0], val[2]) }
  ;

  # no need to use method definitions or param lists

  # Class definition
  Class:
    CLASS CONSTANT Block              { result = ClassNode.new(val[1], val[2]) }
  ;

  # Id definition
  Id:
    ID CONSTANT Block                 { result = IdNode.new(val[1], val[2]) }
  ;

  # if and if-else block
  # If:
  #   IF Expression Block               { result = IfNode.new(val[1],
  #   val[2]) }
  # | IF Expression Block NEWLINE
  #   ELSE Block                        { result = IfNode.new(val[1],
  #   val[2], val[5])  }
  # ;

  # A block of indented code. All of the hard work is done by the lexer.
  Block:
    INDENT Expressions DEDENT         { result = val[1] }
  ;

  # That's all for now. Keep it simple.
end

---- header
  require "lexer"
  require "nodes"

---- inner
  def parse(code, show_tokens=false)
    @tokens = Flair::Lexer.new(code).tokenize
    puts @tokens.inspect if show_tokens
    do_parse
  end

  def next_token
    @tokens.shift
  end
