require_relative 'lib/monosynth'
require_relative 'lib/g_verb'
SFREQ = 44100


synth = Monosynth.new(SFREQ)

synth.start(0, note: 48)
synth.stop(1.5, note: 48)
synth.start(1, note: 48 + 3)
synth.stop(2.5)
synth.start(2.5, note: 48 - 2)
synth.stop(2.7)

reverb =GVerb.new(SFREQ, max_room_size: 120.0, room_size: 10.0, rev_time: 1.0, damping:0.3, spread: 15.0, input_bandwidth: 1.5, early_level:0.8, tail_level: 0.5)

out = (4 * SFREQ).times.map { |i|
  reverb.run(synth.run(i), 0.2)[0]
}
print out.pack('e*')
