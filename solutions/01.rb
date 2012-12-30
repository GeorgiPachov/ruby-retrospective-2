class Integer
  def prime_divisors
    #work with absolute value only
    self_abs = self.abs

    result = []
    (2..self_abs).each do |k|
      if self_abs % k == 0 and k.is_prime?
        then result << k
      end
    end
    result
  end

  #works with positive numbers only, but I will use it only with positives anyway
  def is_prime?
    if self < 2
      return false
    end

    (2..self-1).each { |lesser_num| return false if self % lesser_num == 0 }

    true
  end
end

class Range
  def fizzbuzz
    our_range = self.to_a
    result = our_range.map do |number|
      if number % 15 == 0
        then :fizzbuzz
      elsif number % 3 == 0
        then :fizz
      elsif number % 5 == 0
        then :buzz
      else
        number
      end
    end
    result
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
    result = select {|key,value| value==v}.keys
    result
  end
end

class Array
  def densities
    result = []
    self.map do |each_member|
      member_density = select { |m| m == each_member }.size
      result << member_density
    end
    result
  end
end
