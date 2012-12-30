class Integer
  def prime_divisors
    (2..abs).select { |k| abs%k == 0 and k.is_prime? }
  end

  def is_prime?
    return false if self < 2
    (2..self-1).select { |lesser_num| self % lesser_num == 0 }.size == 0
  end
end

class Range
  def fizzbuzz
    map { |number| choose_mapping_for(number) }
  end

  def choose_mapping_for(number)
    return :fizzbuzz if number % 15 == 0
    return :fizz if number % 3 == 0
    return :buzz if number % 5 == 0
    return number
  end
end

class Hash
  def group_values
    result = {}
    self.each_value do |value|
      result[value]=get_keys value
    end
    result
  end

  def get_keys(v)
    select {|key,value| value==v}.keys
  end
end

class Array
  def densities
    map { |n| count(n) }
  end
end
