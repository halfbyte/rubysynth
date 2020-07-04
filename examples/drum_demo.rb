require 'synth_blocks'

include SynthBlocks::Sequencer::SequencerDSL

SRATE = 44100
TEMPO = 125
P = nil # pause

snare = SynthBlocks::Drum::SnareDrum.new(SRATE)
kick = SynthBlocks::Drum::KickDrum.new(SRATE)
hihat = SynthBlocks::Drum::Hihat.new(SRATE)
open_hihat = SynthBlocks::Drum::Hihat.new(SRATE, amp_decay: 0.2)
limiter = SynthBlocks::Fx::Limiter.new
def_pattern(:drums_full, 16) do
  drum_pattern kick,        '*---*---*---*---'
  drum_pattern snare,       '----*-------*---'
  drum_pattern hihat,       '--*---*---*---*-'
  drum_pattern open_hihat,  '--*---*---*--*--'
end

my_song = song(bpm: TEMPO) do
  pattern(:drums_full, at: 0, repeat: 2)
end

out = my_song.render(SRATE) do |i|
   limiter.run(snare.run(i) + kick.run(i) + (0.3 * (hihat.run(i) + open_hihat.run(i))))
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)


