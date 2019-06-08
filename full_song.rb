require_relative 'lib/kick_drum'
require_relative 'lib/sequencer_dsl'
include SequencerDSL

SRATE = 44100

kick_drum = KickDrum.new(SRATE)

def_pattern(:drums_full, 16) do
  drum_pattern kick_drum,  '*---*---*---*---'
end

pp @patterns

# def_pattern(:bassline, 16) do

# end



length = song(bpm: 120) do
  pattern(:drums_full, at: 0, repeat: 1)
end

output = []
(length * SRATE).times do |i|
  output << 0.3 * kick_drum.run(i)
end
print output.pack('e*')
