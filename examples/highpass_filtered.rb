require 'synth_blocks'

#
# Highpass Filter
#

SAMPLING_FREQUENCY=44100

filter = SynthBlocks::Core::StateVariableFilter.new(SAMPLING_FREQUENCY)

out = SAMPLING_FREQUENCY.times.map do
  output = rand() * 2 - 1
  output = filter.run(output, 6000.0, 2, type: :highpass)
  output *= 0.1
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
