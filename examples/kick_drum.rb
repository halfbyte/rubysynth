require 'synth_blocks'

#
# Demo of the kick drum
#

SRATE = 44100

kick = SynthBlocks::Drum::KickDrum.new(SRATE)
kick.start(0.0)

ws = SynthBlocks::Fx::Waveshaper.new(5)

out = SRATE.times.map {|i| 0.3 * ws.run(kick.run(i)) }

SynthBlocks::Core::WaveWriter.write_if_name_given(out)