require 'ruby_synth'

include SequencerDSL
SRATE = 44100
TEMPO = 125
P = nil # pause



snare = SnareDrum.new(SRATE)
kick = KickDrum.new(SRATE)
hihat = Hihat.new(SRATE)
open_hihat = Hihat.new(SRATE, amp_decay: 0.2)
limiter = Limiter.new
def_pattern(:drums_full, 16) do
  drum_pattern kick,        '*---*---*---*---'
  drum_pattern snare,       '----*-------*---'
  drum_pattern hihat,       '--*---*---*---*-'
  drum_pattern open_hihat,  '--*---*---*--*--'
end

length = song(bpm: TEMPO) do
  pattern(:drums_full, at: 0, repeat: 2)
end

out = (length * SRATE).times.map { |i|
   limiter.run(snare.run(i) + kick.run(i) + (0.3 * (hihat.run(i) + open_hihat.run(i))))
}

print out.pack('e*')

