require 'synth_blocks/core/wave_writer'

#
# Most simple example. Generates a square wave in 440 Hz for one second
#
SAMPLING_FREQUENCY=44100
FREQUENCY=440


in_cycle = 0
samples = (SAMPLING_FREQUENCY).times.map do
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output * 0.5
end
SynthBlocks::Core::WaveWriter.write_if_name_given(samples)