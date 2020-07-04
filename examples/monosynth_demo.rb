require 'synth_blocks'

#
# Simple Demo of the Monosyth
#

SFREQ = 44100

synth = SynthBlocks::Synth::Monosynth.new(SFREQ)

synth.start(0, 48)
synth.stop(1.5, 48)
synth.start(1, 48 + 3)
synth.start(2.5, 48 - 2)
synth.stop(2.7, 48 + 3)
synth.stop(3, 48 - 2)

out = (4 * SFREQ).times.map { |i|
  synth.run(i)
}

SynthBlocks::Core::WaveWriter.write_if_name_given(out)