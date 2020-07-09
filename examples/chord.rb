require 'synth_blocks'
SRATE = 44100
include SynthBlocks::Sequencer::SequencerDSL
polysynth = SynthBlocks::Synth::Polysynth.new(SRATE)

def_pattern(:chord, 16) do
  note_pattern polysynth, [
    P, P, ['C2,D#2,G2', 2], P,
    P, P, P, P,
    ['C#2,E2,G#2', 2], P, P, P,
    P, P, P, P
  ]
end

my_song = song(bpm: 135) do
  pattern(:chord, at: 0, repeat: 2)
end

out = my_song.render(SRATE) do |i|
  0.8 * polysynth.run(i)
end
SynthBlocks::Core::WaveWriter.write_if_name_given(out)