require "byebug"

class AST
end

class BinOp < AST
  attr_reader :left, :op, :right, :token
  
  def initialize(left:, op:, right:)
    @left = left
    @op = op
    @token = op
    @right = right
  end
end

class RPNOp < AST
  attr_reader :child, :op

  def initialize(child:, op:)
    @child = child
    @op = op
  end
end

class LISPOp
  attr_reader :child, :op

  def initialize(child:, op:)
    @child = child
    @op = op
  end
end

class Num < AST
  attr_reader :token

  def initialize(token:)
    @token = token
  end
end

class Token
  attr_reader :type, :value

  def initialize(type:, value:)
    @type = type
    @value = value
  end
  def to_s
    "Token type: #{type}, value: #{@value}"
  end
end

class Tokenizer
  def tokenize(text)
    tokens = []
    text.scan(/[[:digit:]]+|[[:punct:]]|[[:word:]]+/) do |match|
      case match
      when "+"
        tokens << Token.new(type: "plus", value: match)
      when "-"
        tokens << Token.new(type: "minus", value: match)
      when "*"
        tokens << Token.new(type: "times", value: match)
      when "/"
        tokens << Token.new(type: "division", value: match)
      when "("
        tokens << Token.new(type: "lPAREN", value: match)
      when ")"
        tokens << Token.new(type: "rPAREN", value: match)
      when "rpn"
        tokens << Token.new(type: "rpn", value: match)
      when "lisp"
        tokens << Token.new(type: "lisp", value: match)
      else
        if match.match(/[[:digit:]]+/)
          tokens << Token.new(type: "int", value: match.to_i)
        else
          raise "Invalid token #{match}"
        end
      end
    end
    tokens << Token.new(type: "eof", value: nil)

    tokens
  end
end

# grammar rules (proposed solution):
# expr: (term (( + | - |) term)*) | (RPN|LISP) expr
# term: factor ((MULT|DIV)  factor)*
# factor: int | pOPEN expr pCLOSE
class Parser

  def initialize(tokens)
    @tokens = tokens
  end

  def lookahead
    @tokens[0]
  end

  def eat(token_type = nil)
    token = @tokens.shift
    return token if token_type.nil?
    return token if token.type == token_type

    raise "Invalid Syntax, expected #{token_type}"
  end

  # Rules
  def factor
    if lookahead.type != "lPAREN"
      node = Num.new(token: eat("int"))
    elsif lookahead.type == "lPAREN"
      eat "lPAREN"
      node = expr
      eat "rPAREN"
    end

    node
  end

  def term
    node = factor

    while ["times", "division"].include? lookahead.type
      token = lookahead
      if token.type == "times"
        eat "times"
      elsif token.type == "division"
        eat "division"
      end
      node = BinOp.new(left: node, op: token, right: factor)
    end

    node
  end

  def expr
    if ["lisp", "rpn"].include? lookahead.type
      token = eat
      node = RPNOp.new(child: expr, op: token) if token.type == "rpn"
      node = LISPOp.new(child: expr, op: token) if token.type == "lisp"
    else
      node = term
      while ["plus", "minus"].include? lookahead.type
        token = lookahead
        if token.type == "plus"
          eat "plus"
        elsif token.type == "minus"
          eat "minus"
        end
        node = BinOp.new(left: node, op: token, right: term)
      end
    end

    node
  end

end

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

  def visit_RPNOp(node)
    result = ''
    expr = node.child
    rpn(expr, result)

    result
  end

  def visit_LISPOp(node)
    expr = node.child

    lisp(expr)
  end

  def interpret(tree)
    visit(tree)
  end

  def rpn(node, result)
    return if node.nil?
    return result << node.token.value.to_s + ' ' if node.class == Num

    rpn(node.left, result)
    rpn(node.right, result)
    result << node.token.value.to_s + ' '
  end

  def lisp(node)
    return if node.nil?
    return node.token.value if node.class == Num

    left = lisp(node.left)
    right = lisp(node.right)
    
    "(#{node.op.value} #{right} #{left})"
  end

end

loop do
  print "calc> "
  text = gets.chomp
  tokens = Tokenizer.new.tokenize(text)
  tree = Parser.new(tokens).expr
  puts Interpreter.new.interpret(tree)
end
