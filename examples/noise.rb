require 'synth_blocks'

#
# Almost white noise
#

SAMPLING_FREQUENCY=44100

out = SAMPLING_FREQUENCY.times.map do
  output = rand() * 2 - 1
  output *= 0.2
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
