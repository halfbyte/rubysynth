require_relative 'lib/polysynth'
require_relative 'lib/mixer_channel'
require_relative 'lib/send_channel'
require_relative 'lib/chorus'
require_relative 'lib/g_verb'
SFREQ = 44100

poly = Polysynth.new(SFREQ)
channel = MixerChannel.new(SFREQ, poly, insert_effects: [Chorus.new(SFREQ)], sends: [0.4], preset: {
  volume: 0.5, eq_high_gain: 1.5, eq_low_gain: 0.8, eq_mid_gain: 1.5, comp_threshold: -80.0,
  duck: 0.8
})

send1 = SendChannel.new(SFREQ, insert_effects: [
  GVerb.new(SFREQ, max_room_size: 120.0, room_size: 80.0, rev_time: 2.0, damping:0.3, spread: 15.0, input_bandwidth: 1.5, early_level:0.8, tail_level: 0.5, mix: 1.0)
], sends: [])


poly.start(0, note: 48)
poly.start(0, note: 48 + 3)
poly.start(0, note: 48 + 7)

poly.stop(2, note: 48)
poly.stop(2, note: 48 + 3)
poly.stop(2, note: 48 + 7)

poly.start(2, note: 48 + 5)
poly.start(2, note: 48 + 3 + 5)
poly.start(2, note: 48 + 7 + 5)

poly.stop(4, note: 48 + 5)
poly.stop(4, note: 48 + 3 + 5)
poly.stop(4, note: 48 + 7 + 5)

channel.set(:eq_low_gain, 4, 1.0, type: :linear)
channel.set(:eq_mid_gain, 4, 1.0, type: :linear)
channel.set(:eq_high_gain, 4, 1.0, type: :linear)

channel.duck(0)
channel.duck(0.5)
channel.duck(1)
channel.duck(1.5)
channel.duck(2)
channel.duck(2.5)
channel.duck(3)
channel.duck(3.5)

out = (4 * SFREQ).times.map { |i|
  out = channel.run(i) + send1.run(i, channel.send(0))
}

print out.pack('e*')
