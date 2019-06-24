##
# waveshaper, source http://www.musicdsp.org/en/latest/Effects/41-waveshaper.html
# amount can go from 1 to ... oo
# the higher a the stronger is the distortion
class Waveshaper
  ##
  # Waveshaper amount
  attr_reader :amount
  ##
  # Create waveshaper instance
  # [amount] Amount can be from 0 to oo
  def initialize(amount)
    @amount = amount
  end
  ##
  # run waveshaper
  def run(input)
    input * (input.abs + amount) / (input ** 2 + (amount - 1) * input.abs + 1)
  end
end
