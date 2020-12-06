require "forwardable"

class Password
  attr_reader :policy, :text

  def initialize(policy, text)
    @policy = policy
    @text = text
  end

  def valid?
    policy.valid?(self)
  end
end

class Policy
  attr_reader :lowest, :highest, :letter

  def initialize(lowest, highest, letter)
    @lowest = lowest
    @highest = highest
    @letter = letter
  end

  def valid?(password)
    count = password.text.count(letter)
    count >= lowest && count <= highest
  end
end

class NewPolicy
  attr_reader :first, :second, :letter

  def initialize(first, second, letter)
    @first = first
    @second = second
    @letter = letter
  end

  def valid?(password)
    text = password.text
    letters = [text[first - 1], text[second - 1]]
    letters.join.count(letter) == 1
  end
end

class PolicyExtractor
  def params(text)
    positions_text, letter = text.split(" ")
    first, second = positions_text.split("-").map(&:to_i)
    [first, second, letter]
  end
end

class Factory
  attr_reader :policy_extractor

  def initialize
    @policy_extractor = PolicyExtractor.new
  end

  def build(text, policy_class)
    policy_text, password_text = text.split(":")
    policy_params = policy_extractor.params(policy_text)
    policy = policy_class.new(*policy_params)
    Password.new(policy, password_text.strip)
  end
end

factory = Factory.new
passwords = File.read("input.txt").lines.map { |line| factory.build(line, Policy) }
puts passwords.count
puts passwords.count(&:valid?)

puts "......................."
passwords = File.read("input.txt").lines.map { |line| factory.build(line, NewPolicy) }
puts passwords.count
puts passwords.count(&:valid?)
