require_relative 'lib/snare_drum'
require_relative 'lib/kick_drum'
require_relative 'lib/hihat'
require_relative 'lib/g_verb'
require_relative 'lib/compressor'
SFREQ = 44100


snare = SnareDrum.new(SFREQ)
kick = KickDrum.new(SFREQ)
hihat = Hihat.new(SFREQ)
open_hihat = Hihat.new(SFREQ, amp_decay: 0.2)
kick.start(0)
hihat.start(0.5)
snare.start(1)
hihat.start(1.5)
kick.start(2)
hihat.start(2.5)
snare.start(3)
open_hihat.start(3.5)
hihat.start(3.75)

reverb =GVerb.new(SFREQ, max_room_size: 120.0, room_size: 10.0, rev_time: 1.0, damping:0.3, spread: 15.0, input_bandwidth: 1.5, early_level:0.8, tail_level: 0.5, mix: 0.3)
compressor = Compressor.new(SFREQ, attack: 20.0, release: 200.0, ratio: 0.1, threshold: -50.0)

out = (4 * SFREQ).times.map { |i|
  output = reverb.run(snare.run(i)) + kick.run(i) + (0.3 * (hihat.run(i) + open_hihat.run(i)))
  output = compressor.run(output)
  # reverb.run( output )
}

print out.pack('e*')

