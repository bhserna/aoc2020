require "set"

class ExpenseReport
  attr_reader :entries

  def initialize(entries)
    @entries = Set.new(entries)
  end

  def selected_pair
    SelectedEntries.new(pair_that_sum(2020))
  end

  def selected_third
    SelectedEntries.new(third_that_sum(2020))
  end

  private

  def find_value
    entries.map { |entry| yield entry }.compact.first
  end

  def third_that_sum(amount)
    find_value do |entry|
      other = amount - entry

      if pair = pair_that_sum(other)
        [entry] + pair
      end
    end
  end

  def pair_that_sum(amount)
    find_value do |entry|
      other = amount - entry

      if entries.include?(other)
        [entry, other]
      end
    end
  end
end

SelectedEntries = Struct.new(:entries) do
  def sum
    entries.reduce(&:+)
  end

  def product
    entries.reduce(&:*)
  end
end

entries = File.read("input.txt").lines.map(&:to_i)
report = ExpenseReport.new(entries)
puts report.selected_pair.inspect
puts report.selected_pair.sum.inspect
puts report.selected_pair.product.inspect

puts "..........."
puts report.selected_third.inspect
puts report.selected_third.sum.inspect
puts report.selected_third.product.inspect
