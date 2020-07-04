require 'synth_blocks'

#
# Each mixer channel has a ducking function that allows to simulate sidechain compression
#

SFREQ = 44100

poly = SynthBlocks::Synth::Polysynth.new(SFREQ, {amp_env_release: 0.2})
channel = SynthBlocks::Mixer::MixerChannel.new(SFREQ, poly, insert_effects: [SynthBlocks::Fx::Chorus.new(SFREQ)], sends: [0.0], preset: {
  volume: 0.5, comp_threshold: 0.0,
  duck: 0.8
})

poly.start(0, 48)
poly.start(0, 48 + 3)
poly.start(0, 48 + 7)

poly.stop(2, 48)
poly.stop(2, 48 + 3)
poly.stop(2, 48 + 7)

poly.start(2, 48 + 5)
poly.start(2, 48 + 3 + 5)
poly.start(2, 48 + 7 + 5)

poly.stop(4, 48 + 5)
poly.stop(4, 48 + 3 + 5)
poly.stop(4, 48 + 7 + 5)
channel.duck(0)
channel.duck(0.5)
channel.duck(1)
channel.duck(1.5)
channel.duck(2)
channel.duck(2.5)
channel.duck(3)
channel.duck(3.5)
channel.duck(4.0)
channel.duck(4.5)

out = (5 * SFREQ).times.map { |i|
  SynthBlocks::Fx::Limiter.new.run(channel.run(i) * 0.6)
}

SynthBlocks::Core::WaveWriter.write_if_name_given(out)