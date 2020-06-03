class AST
end

class BinOp < AST
  attr_reader :left, :op, :right
  
  def initialize(left:, op:, right:)
    @left = left
    @op = op
    @right = right
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
    text.scan(/[[:digit:]]+|[[:punct:]]/) do |match|
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
      else
        tokens << Token.new(type: "int", value: match.to_i)
      end
    end
    tokens << Token.new(type: "eof", value: nil)

    tokens
  end
end

class Parser

  def initialize(tokens)
    @tokens = tokens
  end

  def lookahead
    @tokens[0]
  end

  def eat(token_type)
    token = @tokens.shift
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

  def interpret(tree)
    visit(tree)
  end
end

loop do
  print "calc> "
  text = gets.chomp
  tokens = Tokenizer.new.tokenize(text)
  tree = Parser.new(tokens).expr
  puts Interpreter.new.interpret(tree)
end
