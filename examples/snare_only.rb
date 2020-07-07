require 'synth_blocks'

#
# A simple example of using amp, filter and pitch envelopes to shape a sound
# But now as a draum sound
#

SAMPLING_FREQUENCY=44100
FREQUENCY=110

amp_env = SynthBlocks::Mod::Adsr.new(0.001, 0.1, 0.5, 0.2)
out = SAMPLING_FREQUENCY.times.map do |s|
  t  = s.to_f / SAMPLING_FREQUENCY.to_f
  stopped = t >= 0.15 ? 0.15 : nil
  output = 0.3 * (rand() * 2) - 1
  output *= 0.3 * amp_env.run(t, stopped)
end
SynthBlocks::Core::WaveWriter.write_if_name_given(out)