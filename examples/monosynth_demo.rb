require 'synth_blocks'

#
# Simple Demo of the Monosyth
#

SFREQ = 44100

synth = SynthBlocks::Synth::Monosynth.new(SFREQ,  {
  flt_Q: 8,
  flt_frequency: 100
})

synth.start(0, 48)
synth.stop(0.5, 48)

out = (SFREQ).times.map { |i|
  synth.run(i) * 0.5
}

SynthBlocks::Core::WaveWriter.write_if_name_given(out)