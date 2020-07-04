require 'synth_blocks'

#
# Simple Demo of the PolySynth
#

SRATE = 44100

polysynth = SynthBlocks::Synth::Polysynth.new(SRATE, {
  amp_env_attack: 0.001,
  amp_env_release: 0.1,
  flt_env_attack: 0.001,
  flt_env_decay: 0.05,
  flt_env_sustain: 0.1,
  flt_frequency: 300,
  flt_envmod: 1000,
  flt_Q: 1,
  osc_waveform: :square
})

polysynth.start(0, 60)
polysynth.start(0, 60 + 4)
polysynth.start(0, 60 + 7)
polysynth.start(0, 60 - 12)

polysynth.stop(0.125, 60)
polysynth.stop(0.125, 60 + 4)
polysynth.stop(0.125, 60 + 7)
polysynth.stop(0.125, 60 - 12)

out = SRATE.times.map{ |i| 0.6 * polysynth.run(i) }

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
