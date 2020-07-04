require 'synth_blocks'

#
# Demo of the Delay/Echo effect
#

SRATE = 44100

snare = SynthBlocks::Drum::SnareDrum.new(SRATE)
delay = SynthBlocks::Fx::Delay.new(SRATE, time: 0.3)
snare.start(0)

out = (SRATE * 2).times.map do |i|
  delay.run(snare.run(i))
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
