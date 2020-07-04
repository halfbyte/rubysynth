require 'synth_blocks'

#
# Let's generate a snare drum sound
#

SRATE = 44100
drum = SynthBlocks::Drum::SnareDrum.new(SRATE)

drum.start(0.0)

out = SRATE.times.map {|i| 0.5 * drum.run(i) }

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
