require 'ruby_synth'
SFREQ = 44100

poly = Polysynth.new(SFREQ, {amp_env_release: 0.2})
channel = MixerChannel.new(SFREQ, poly, insert_effects: [Chorus.new(SFREQ)], sends: [0.0], preset: {
  volume: 0.5, comp_threshold: 0.0,
  duck: 0.8
})

send1 = SendChannel.new(SFREQ, insert_effects: [
  GVerb.new(SFREQ, max_room_size: 120.0, room_size: 80.0, rev_time: 2.0, damping:0.3, spread: 15.0, input_bandwidth: 1.5, early_level:0.8, tail_level: 0.5, mix: 1.0)
], sends: [])


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
  out = Limiter.new.run(channel.run(i) * 0.6)
}

print out.pack('e*')
