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
  VALID_EXPR = [["int", "plus", "int"], ["int", "minus", "int"]]

  def initialize(text)
    @text = text
    @tokens = []
    tokenize
  end

  def expr
    expr = VALID_EXPR.index @tokens.map(&:type)
    raise "Entrada inválida" if expr.nil?
    
    if expr == 0
      @tokens[0].value + @tokens[2].value
    elsif expr == 1
      @tokens[0].value - @tokens[2].value
    end
  end

  private

  def tokenize
    @text.scan(/\d+|\+|\-/) do |match|
      if match.match(/\d+/)
        @tokens << Token.new(type: "int", value: match.to_i)
      elsif match == "+"
        @tokens << Token.new(type: "plus", value: match)
      elsif match == "-"
        @tokens << Token.new(type: "minus", value: match)
      end
    end
  end

end

loop do
  print "calc> "
  text = gets.chomp
  interpreter = Interpreter.new(text)
  result = interpreter.expr
  puts result
end
