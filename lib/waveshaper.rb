class Waveshaper
  attr_reader :a
  def initialize(a)
    @a = a
  end

  def run(input)
    input * (input.abs + a) / (input ** 2 + (a - 1) * input.abs + 1)
  end
end
