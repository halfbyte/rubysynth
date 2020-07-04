require 'synth_blocks'
include SynthBlocks::Sequencer::SequencerDSL

SRATE = 44100
P = nil # pause

kick_drum = SynthBlocks::Drum::KickDrum.new(SRATE)
snare_drum = SynthBlocks::Drum::SnareDrum.new(SRATE)
hihat = SynthBlocks::Drum::Hihat.new(SRATE)
monosynth = SynthBlocks::Synth::Monosynth.new(SRATE)
polysynth = SynthBlocks::Synth::Polysynth.new(SRATE)

def_pattern(:drums_full, 16) do
  drum_pattern kick_drum,   '*---*---*---*---'
  drum_pattern snare_drum,  '----*-------*---'
  drum_pattern hihat,       '--*---*---*---*-'
end

def_pattern(:bassline, 16) do
  note_pattern monosynth, [
    ['C1', 4], P, P, P,
    P, P, P, P,
    ['C#1', 6], P, P, P,
    P, P, P, P
  ]
end

def_pattern(:chord, 16) do
  note_pattern polysynth, [
    P, P, ['C2,D#2,G2', 2], P,
    P, P, P, P,
    ['C#2,E2,G#2', 2], P, P, P,
    P, P, P, P
  ]
end



my_song = song(bpm: 115) do
  pattern(:drums_full, at: 0, repeat: 1)
  pattern(:drums_full, at: 2, repeat: 2)
  pattern(:bassline, at: 0, repeat: 4)
  pattern(:chord, at: 0, repeat: 4)
end

out = my_song.render(SRATE) do |i|
  0.3 * (kick_drum.run(i) + hihat.run(i) + snare_drum.run(i) + monosynth.run(i) + polysynth.run(i))
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
