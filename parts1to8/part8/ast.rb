class AST
end

class BinOp < AST
  attr_reader :left, :op, :right, :token
  
  def initialize(left:, op:, right:)
    @left = left
    @op = op
    @token = @op
    @right = right
  end
end

class UnaryOp
  attr_reader :child, :op, :token
  def initialize(child:, op:)
    @child = child
    @op = op
    @token = @op
  end
end

class Num < AST
  attr_reader :token

  def initialize(token:)
    @token = token
  end
end
