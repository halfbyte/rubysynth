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

out = (4 * SFREQ).times.map { |i|
  snare.run(i) + kick.run(i) + (0.3 * (hihat.run(i) + open_hihat.run(i)))
}

print out.pack('e*')

