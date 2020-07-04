require 'synth_blocks'

#
# Demo of the High Hat drum sound
#

SRATE = 44100
hat = SynthBlocks::Drum::Hihat.new(SRATE)

hat.start(0.0)

out = SRATE.times.map {|i| 0.5 * hat.run(i) }

SynthBlocks::Core::WaveWriter.write_if_name_given(out)