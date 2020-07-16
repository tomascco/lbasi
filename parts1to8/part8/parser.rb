# current grammar rules:
# expr: term ((plus|minus|) term)*
# term: factor ((MULT|DIV)  factor)*
# factor: (plus|minus) factor | int | pOPEN expr pCLOSE

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
    if ["plus", "minus"].include? lookahead.type
      token = eat
      node = UnaryOp.new(child: factor, op: token)
    elsif lookahead.type != "lPAREN"
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
