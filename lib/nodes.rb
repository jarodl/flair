# Collection of nodes, each one representing an expression.
class Nodes
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
  def eval(context)
    # The last value evaluated in a method is the return value.
    @nodes.map { |node| node.eval(context) }.last
  end
end

# Literals are static values that have a Ruby representation,
# eg.: a string, true, false, nil, etc.
class LiteralNode
  def initialize(value)
    @value = value
  end

  def eval(context)
    # Here we access the Runtime, which we'll see in the next section.
    case @value
    when Numeric
      Runtime["Number"].new_value(@value)
    when String
      Runtime["String"].new_value(@value)
    when TrueClass
      Runtime["true"]
    when FalseClass
      Runtime["false"]
    when NilClass
      Runtime["nil"]
    else
      raise "Unknown literal type: " + @value.class.name
    end
  end
end

# Node of a method call or local variable access, can take any
# of these forms:
#
#   method # this form can also be a local variable
#   receiver.method
#
class CallNode
  def initialize(receiver, method) # no arguments for now
    @receiver = receiver
    @method = method
  end

  def eval(context)
    # If there's no receiver and the method name is the name of a local
    # variable then it's local variable access.
    if @receiver.nil? && context.locals[@method]
      context.locals[@method]

    # Method call
    else
      receiver = @receiver.eval(context)
      receiver.call(@method)
    end
  end
end

# This might be the only thing we need to retrieve
# another class' attributes instead of the CallNode class above.
#
# Retrieving the value of a constant
class GetConstantNode
  def initialize(name)
    @name = name
  end

  def eval(context)
    context[@name]
  end
end

# Setting the value of a constant.
class SetConstantNode
  def initialize(name, value)
    @name = name
    @value = value
  end

  def eval(context)
    context[@name] = @value.eval(context)
  end
end

# Setting the value of a local variable.
class SetLocalNode
  def initialize(name, value)
    @name = name
    @value = value
  end

  def eval(context)
    context.locals[@name] = @value.eval(context)
  end
end

# Class definition
class ClassNode
  def initialize(name, body)
    @name = name
    @body = body
  end

  def eval(context)
    # Create the class and put it's value in a constant.
    flair_class = FlairClass.new
    context[@name] = flair_class

    # Evaluate the body of the class in its context. Providing a custom
    # context to control where variables are defined.
    # case, we add them to the newly created class.
    @body.eval(Context.new(flair_class, flair_class))

    flair_class
  end
end

class IfNode
  def initialize(condition, body, else_body=nil)
    @condition = condition
    @body = body
    @else_body = else_body
  end

  def eval(context)
  end
end

# Id definition
class IdNode
  def initialize(name, body)
    @name = name
    @body = body
  end

  def eval(context)
    flair_id = FlairId.new
    context[@name] = flair_id

    @body.eval(Context.new(flair_id, flair_id))

    flair_id
  end
end
