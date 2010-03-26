class Parser

token CLASS
token ID
token NEWLINE
token NUMBER
token STRING
token NIL
token IDENTIFIER
token CONSTANT
token INDENT DEDENT

rule

  # All parsing will end in this rule, being the trunk of the AST.
  Root:
    /* nothing */                 { result = Nodes.new([]) }
  | Expressions                   { result = val[0] }
  ;


  # Any list of expressions, class or method body, seperated by line breaks.
  Expressions:
    Expression                    { result = Nodes.new(val) }
  | Expressions Terminator Expression { result = val[0] << val[2] }
    # To ignore trailing line breaks
end
