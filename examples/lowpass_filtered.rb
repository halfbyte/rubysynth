require 'synth_blocks'

#
# Lowpass Filter
#

SAMPLING_FREQUENCY=44100
FREQUENCY=440

filter = SynthBlocks::Core::StateVariableFilter.new(SAMPLING_FREQUENCY)

in_cycle = 0
out = SAMPLING_FREQUENCY.times.map do
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output = filter.run(output, 2000.0, 2, type: :lowpass)
  output *= 0.3
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
