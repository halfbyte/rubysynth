require 'synth_blocks'

#
# A filter envelope shapes the sound even more
#

SAMPLING_FREQUENCY=44100
FREQUENCY=440

filter = SynthBlocks::Core::StateVariableFilter.new(SAMPLING_FREQUENCY)
amp_env = SynthBlocks::Mod::Adsr.new(0.001, 0.2, 0.5, 0.2)
filter_env = SynthBlocks::Mod::Adsr.new(0.01, 0.1, 0.1, 0.1)
in_cycle = 0
out = SAMPLING_FREQUENCY.times.map do |s|
  t  = s.to_f / SAMPLING_FREQUENCY.to_f
  stopped = t >= 0.5 ? 0.5 : nil
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output = filter.run(output, 500.0 + (8000.0 * filter_env.run(t, stopped)), 1)
  output *= 0.3 * amp_env.run(t, stopped)
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
