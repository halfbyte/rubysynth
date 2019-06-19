require 'ruby_synth'
include SequencerDSL

SRATE = 44100
TEMPO = 125
P = nil # pause

kick_drum = KickDrum.new(SRATE)
kick_drum_channel = MixerChannel.new(SRATE, kick_drum, insert_effects: [Waveshaper.new(4)], preset: {
  volume: 0.3
})
snare_drum = SnareDrum.new(SRATE)
snare_drum_channel = MixerChannel.new(SRATE, snare_drum, sends: [0.2], preset: {
  volume: 0.4
})

hihat = Hihat.new(SRATE)
hihat_channel = MixerChannel.new(SRATE, hihat)
monosynth = Monosynth.new(SRATE)
monosynth_channel = MixerChannel.new(SRATE, monosynth, insert_effects: [Waveshaper.new(2)], preset: {
  volume: 0.05
})
polysynth = Polysynth.new(SRATE)
polysynth_channel = MixerChannel.new(SRATE, polysynth, insert_effects: [Chorus.new(SRATE)], sends: [0.4, 0.3], preset: {
  volume: 0.1
})

reverb_send = SendChannel.new(SRATE, insert_effects: [
  GVerb.new(SRATE, max_room_size: 120.0, room_size: 80.0, rev_time: 2.0, damping:0.3, spread: 15.0, input_bandwidth: 1.5, early_level:0.8, tail_level: 0.5, mix: 1.0)
], sends: [])

delay_send = SendChannel.new(SRATE, insert_effects: [
  Delay.new(SRATE, time: 15.0 / TEMPO.to_f * 3, mix: 0.4, feedback: 0.4)
], sends: [0.2])


def_pattern(:drums_full, 16) do
  drum_pattern kick_drum,   '*---*---*---*---'
  drum_pattern snare_drum,  '----*-------*---'
  drum_pattern hihat,       '--*---*---*---*-'
end

def_pattern(:bassline, 16) do
  note_pattern monosynth, [
    ['C1', 4], P, P, P,
    P, P, P, P,
    ['C#1', 4], P, P, P,
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


length = song(bpm: TEMPO) do
  pattern(:drums_full, at: 0, repeat: 1)
  pattern(:drums_full, at: 2, repeat: 2)
  pattern(:bassline, at: 0, repeat: 4)
  pattern(:chord, at: 0, repeat: 4)
end

output = (length * SRATE).times.map do |i|
  kick_drum_channel.run(i) + snare_drum_channel.run(i) + hihat_channel.run(i) +
  monosynth_channel.run(i) + polysynth_channel.run(i) +
  delay_send.run(i,
    kick_drum_channel.send(1) + snare_drum_channel.send(1) + hihat_channel.send(1) +
    monosynth_channel.send(1) + polysynth_channel.send(1)
  ) +
  reverb_send.run(i,
    kick_drum_channel.send(0) + snare_drum_channel.send(0) + hihat_channel.send(0) +
    monosynth_channel.send(0) + polysynth_channel.send(0) +
    delay_send.send(0)
  )
end

print output.pack('e*')
