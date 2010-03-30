class Node
  # make CSS with two tabs
  TAB = '  '

  def line_ending
    ';'
  end

end
# Collection of nodes, each one representing an expression.
class Nodes < Node
  attr_reader :nodes

  def initialize(nodes)
    @nodes = nodes
  end

  def <<(node)
    @nodes << node
    self
  end

  # This method is the "interpreter" part of our language.
  # All nodes know how to eval itself and returns the result
  # of its evaluation by implementing the "eval" method.
  # The "context" variable is the environment in which the node
  # is evaluated (local variables, current class, etc.).
  def compile(indent='')
    # The last value evaluated in a method is the return value.
    @nodes.map { |node| node.compile(indent) }.last
  end
end

# Literals are static values
# eg.: a string, true, false, nil, etc.
class LiteralNode < Node
  def initialize(value)
    @value = value
  end

  def compile(indent)
    @value.to_s
  end
end

class CallNode < Node
  def initialize(receiver, method)
    @receiver = receiver
    @method = method
  end

  def compile(indent)
  end
end

# This might be the only thing we need to retrieve
# another class' attributes instead of the CallNode class above.
#
# Retrieving the value of a constant
class GetConstantNode < Node
  def initialize(name)
    @name = name
  end

  def compile(indent)
  end
end

# Setting the value of a constant.
class SetConstantNode < Node
  def initialize(name, value)
    @name = name
    @value = value
  end

  def compile(indent)
  end
end

# Setting the value of a local variable.
class SetLocalNode < Node
  def initialize(name, value)
    @name = name
    @value = value
  end

  def compile(indent)
    "#{@name}: #{@value.compile(indent)};"
  end
end

# Class definition
class ClassNode < Node
  def initialize(name, body)
    @name = name
    @body = body
  end

  def compile(indent)
    ".#{@name.downcase} { \n#{TAB}#{@body.compile}\n}"
  end
end

class IfNode < Node
  def initialize(condition, body, else_body=nil)
    @condition = condition
    @body = body
    @else_body = else_body
  end

  def compile(context)
  end
end

# Id definition
class IdNode < Node
  def initialize(name, body)
    @name = name
    @body = body
  end

  def compile(context)
    "##{@name.downcase} { \n#{TAB}#{@body.compile}\n}"
  end
end
