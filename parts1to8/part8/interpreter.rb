class NodeVisitor
  def visit(node)
    self.send "visit_#{node.class}", node
  end
end

class Interpreter < NodeVisitor
  SUPPORTED_OPS = ["plus", "minus", "division", "times"]

  def visit_BinOp(node)
    type = node.op.type
    raise "Invalid operation #{type}" unless SUPPORTED_OPS.include? type

    op = node.op.value
    visit(node.left).send op, visit(node.right)
  end

  def visit_Num(node)
    node.token.value
  end

  def visit_UnaryOp(node)
    return +visit(node.child) if node.op.type == "plus"
    return -visit(node.child) if node.op.type == "minus"
  end

  def interpret(tree)
    visit(tree)
  end
end
