class Expr
  def self.build(expression_tree)
    return Expr.new(expression_tree) unless expression_tree.kind_of? Array

    length = expression_tree.size
    operand = expression_tree.first
    expr_1 = expression_tree.fetch(1)
    expr_2 = expression_tree.fetch(2) unless length == 2

    return build_unary_expr(operand,build(expr_1)) if length == 2
    return build_binary_expr(operand,build(expr_1),Expr.build(expr_2)) if length == 3
  end


  def initialize(primitive)
    @expr = primitive
  end

  def evaluate(environment={})
    @expr
  end

  def simplify
    @expr
  end

  def derive(variable)
    @expr
  end

  def to_s
    @expr.to_s
  end

  def ==(other)
    to_s == other.to_s
  end

  private
  def self.build_binary_expr(operation, expr1, expr2)
    case operation
    when :+
        return AdditionExpr.new(expr1,expr2)
    when :*
      return MultiplicationExpr.new(expr1,expr2)
    end
  end

  def self.build_unary_expr(operation,expr1)
    case operation
    when :sin
      SineExpr.new(expr1)
    when :cos
      CosineExpr.new(expr1)
    when :-
        NegateExpr.new(expr1)
    when :number
      NumberExpr.new(expr1)
    when :variable
      VariableExpr.new(expr1)
    end
  end
end

class UnaryExpr < Expr
  def initialize(expr)
    @expr = expr
  end

  def to_s
    @expr.to_s
  end

  def is_constant_expr
    false
  end

  def simplify
    self
  end

end

class BinaryExpr < Expr
  def initialize(expr_a, expr_b)
    @expr_a = expr_a
    @expr_b = expr_b
  end

  def to_string(operation)
    "(#{@expr_a}#{operation}#{@expr_b})"
  end

  def is_constant_expr
    (@expr_a.is_constant_expr) && (@expr_b.is_constant_expr)
  end
end

class AdditionExpr < BinaryExpr
  def evaluate(environment={})
    (@expr_a.evaluate environment) + (@expr_b.evaluate environment)
  end
  def simplify
    simplified_a = @expr_a.simplify
    simplified_b = @expr_b.simplify

    return simplified_a if simplified_b == 0
    return simplified_b if simplified_a == 0

    return NumberExpr.new(Expr.new(evaluate)) if is_constant_expr

    return AdditionExpr.new(simplified_a, simplified_b)
  end

  def derive(variable)
    AdditionExpr.new((@expr_a.derive variable),(@expr_b.derive variable)).simplify
  end

  def to_s
    to_string('+')
  end
end

class MultiplicationExpr < BinaryExpr
  def evaluate(environment={})
    (@expr_a.evaluate environment) * (@expr_b.evaluate environment)
  end

  def simplify
    simplified_a = @expr_a.simplify
    simplified_b = @expr_b.simplify

    if (simplified_a == NumberExpr::ZERO || simplified_b == NumberExpr::ZERO)
      return NumberExpr.new(Expr.new(0))
    end

    return simplified_a if simplified_b == NumberExpr::ONE
    return simplified_b if simplified_a == NumberExpr::ONE

    return NumberExpr.new(Expr.new(evaluate)) if is_constant_expr
    return MultiplicationExpr.new(simplified_a, simplified_b)
  end

  def derive(variable)
    expr_a = MultiplicationExpr.new((@expr_a.derive variable), @expr_b)
    expr_b = MultiplicationExpr.new(@expr_a, (@expr_b.derive variable))
    (AdditionExpr.new(expr_a,expr_b)).simplify
  end

  def to_s
    to_string('*')
  end
end


class VariableExpr < UnaryExpr
  def initialize(expr)
    @expr = expr
  end

  def derive(variable)
    NumberExpr.new(Expr.new(@expr.to_s == variable.to_s ? 1: 0 ))
  end

  def evaluate(environment={})
    return @expr.evaluate unless environment.has_key?(@expr.evaluate)
    environment[@expr.evaluate]
  end

  def is_constant_expr
    false
  end

end

class NumberExpr < UnaryExpr
  ZERO=NumberExpr.new(Expr.new(0))
  ONE=NumberExpr.new(Expr.new(1))
  def initialize(wrapper)
    @expr = wrapper
  end
  def evaluate(environment={})
    @expr.evaluate environment
  end

  def is_constant_expr
    true
  end

  def derive(variable)
    NumberExpr::ZERO
  end

end

class SineExpr < UnaryExpr
  def evaluate(environment={})
    Math.sin(super.evaluate environment)
  end

  def to_s
    "sin(#{super.to_s})"
  end

  def simplify
    return NumberExpr.new(Expr.new(0)) if @expr.simplify == NumberExpr::ZERO
    super
  end

  def derive(variable)
    MultiplicationExpr.new((@expr.derive variable),CosineExpr.new(@expr)).simplify
  end
end

class CosineExpr < UnaryExpr
  def evaluate(environment={})
    Math.cos(super.evaluate environment)
  end

  def to_s
    "cos(#{super.to_s})"
  end

  def derive(variable)
    NegateExpr.new(MultiplicationExpr.new((@expr.derive variable),SineExpr.new(@expr)).simplify)
  end

end

class NegateExpr < UnaryExpr
  def evaluate(environment={})
    MultiplicationExpr.new(NumberExpr.new(Expr.new(-1)), @expr).evaluate environment
  end
end
