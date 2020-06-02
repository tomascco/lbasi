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

class Interpreter
  VALID_EXPR = [
                ["int", "plus", "int"], # expr 1
                ["int", "minus", "int"], # expr 2
                ["int", "times", "int"], #expr 3
                ["int", "division", "int"] # expr 4
               ]

  def initialize(text)
    @text = text
    @tokens = []
    tokenize
  end

  # parser/interpreter code
  def expr
    types = @tokens.map(&:type)
    # check if there is a multiplication or division with more than three tokens
    raise "Unsupported input" if (types & ["times", "division"]).any? && types.size > 3

    while @tokens.size > 3
      operation = @tokens.shift(3)
      @tokens.unshift(evaluate(operation))
    end

    evaluate(@tokens).value
  end

  private

  # lexer code
  def tokenize
    @text.scan(/[[:digit:]]+|[[:punct:]]/) do |match|
      if match == "+"
        @tokens << Token.new(type: "plus", value: match)
      elsif match == "-"
        @tokens << Token.new(type: "minus", value: match)
      elsif match == "*"
        @tokens << Token.new(type: "times", value: match)
      elsif match == "/"
        @tokens << Token.new(type: "division", value: match)
      else
        @tokens << Token.new(type: "int", value: match.to_i)
      end
    end
  end

  def evaluate(tokens)
    expr = VALID_EXPR.index tokens.map(&:type)
    raise "Tamanho inválido" if tokens.size != 3
    raise "Entrada inválida" if expr.nil?

    case expr
    when 0
      result = tokens[0].value + tokens[2].value
    when 1
      result = tokens[0].value - tokens[2].value
    when 2
      result = tokens[0].value * tokens[2].value
    when 3
      result = tokens[0].value / tokens[2].value
    end

    Token.new(type: "int", value: result)
  end
end

loop do
  print "calc> "
  text = gets.chomp
  interpreter = Interpreter.new(text)
  result = interpreter.expr
  puts result
end
