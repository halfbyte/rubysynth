DrumSound.start(t)
DrumSound.stop(t)
DrumSound.set(time, value)
DrumSound.automate(:linear, time, value) # linearRampToValueAtTime
DrumSound.gen(sample, length)

require_relative 'lib/sequencer'
include SequencerDSL

def_pattern(:drums_full, 16) do
  drum_pattern DrumSound,  '*---*---*---*---'
  drum_pattern SnareSound, '----*-------*---'
  drum_pattern Hihat,      '--*---*---*---*-'
end

def_pattern(:bassline, 16) do

end



song do
  pattern(:bassline, at: 0, repeat: 8)
  pattern(:drums_intro, at: 2, repeat: 6)

end
