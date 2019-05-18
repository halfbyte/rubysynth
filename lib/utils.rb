# Some simple utils
module Utils
  # a simple bitreducer using rounding
  # bits is the number of bits you want to reduce to
  def bitreduce(input, bits=8)
    (input * bits.to_f).round.to_f / bits.to_f
  end

  # waveshaper, source http://www.musicdsp.org/en/latest/Effects/41-waveshaper.html
  # a can go from 1 to ... oo
  # the higher a the stronger is the distortion
  def simple_waveshaper(input, a)
    input * (input.abs + a) / (input ** 2 + (a - 1) * input.abs + 1)
  end
end
