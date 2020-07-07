require 'synth_blocks'

#
# Lowpass Filter
#

SAMPLING_FREQUENCY=44100

filter = SynthBlocks::Core::StateVariableFilter.new(SAMPLING_FREQUENCY)

out = SAMPLING_FREQUENCY.times.map do
  output = rand() * 2 - 1
  output = filter.run(output, 2000.0, 2, type: :lowpass)
  output *= 0.3
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
