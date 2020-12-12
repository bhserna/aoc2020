class Passport
  attr_reader :fields, :validator

  def initialize(fields, validator)
    @fields = fields
    @validator = validator
  end

  def valid?
    validator.valid?(self)
  end
end

class Validator
  FIELDS = [:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]

  def valid?(passport)
    FIELDS.all? do |key|
      passport.fields.has_key?(key.to_s)
    end
  end
end

class NewValidator
  FIELDS = {
    "byr" => /^(19[2-9][0-9]|200[0-2])$/,
    "iyr" => /^(201[0-9]|2020)$/,
    "eyr" => /^(202[0-9]|2030)$/,
    "hgt" => /^((1[5-8][0-9]|19[0-3])cm|(59|6[0-9]|7[0-6])in)$/,
    "hcl" => /^#[0-9a-f]{6}$/,
    "ecl" => /^(amb|blu|brn|gry|grn|hzl|oth)/,
    "pid" => /^\d{9}/
  }

  def valid?(passport)
    FIELDS.all? { |key, spec| valid_field?(passport, key, spec) }
  end

  def valid_field?(passport, key, spec)
    value = passport.fields[key.to_s]
    value && spec.match?(value)
  end
end

class Factory
  attr_reader :passports

  def initialize(validator)
    @passports = []
    @fields = {}
    @validator = validator
  end

  def process_file!(file)
    process_lines!(file.lines.map(&:split))
  end

  private

  def process_lines!(lines)
    lines.each do |line|
      if line.any?
        save_fields!(line)
      else
        add_passport!
      end
    end

    add_passport!
  end

  def save_fields!(line)
    @fields.merge!(extract_fields(line))
  end

  def add_passport!
    @passports << Passport.new(@fields, @validator)
    @fields = {}
  end

  def extract_fields(line)
    line.map { |field| field.split(":").map(&:strip) }.to_h
  end
end

factory = Factory.new(Validator.new)
factory.process_file!(File.read("input.txt"))
passports = factory.passports
puts passports.count(&:valid?)

puts ".................."

factory = Factory.new(NewValidator.new)
factory.process_file!(File.read("input.txt"))
passports = factory.passports
puts passports.count(&:valid?)
