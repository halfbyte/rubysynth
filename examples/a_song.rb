require 'synth_blocks'

#
# A full demo song. Please note that this song unfortunately can take several hours to render.
#

include SynthBlocks::Sequencer::SequencerDSL

SRATE = 44100
TEMPO = 125
P = nil # pause

kick_drum = SynthBlocks::Drum::KickDrum.new(SRATE)
kick_drum_channel = SynthBlocks::Mixer::MixerChannel.new(SRATE, kick_drum, insert_effects: [SynthBlocks::Fx::Waveshaper.new(4)], preset: {
  volume: 0.2
})
tom = SynthBlocks::Drum::TunedDrum.new(SRATE, {
  pitch_mod: 200.0,
  pitch_decay: 0.01,
  amp_decay: 0.2
})
tom_channel = SynthBlocks::Mixer::MixerChannel.new(SRATE, tom, sends: [0.5], insert_effects: [SynthBlocks::Fx::Waveshaper.new(3)], preset: {
  volume: 0.05
})
snare_drum = SynthBlocks::Drum::SnareDrum.new(SRATE)
snare_drum_channel = SynthBlocks::Mixer::MixerChannel.new(SRATE, snare_drum, sends: [0.4], preset: {
  volume: 0.15
})

hat_channel_params = {
  volume: 0.05
}

hihat = SynthBlocks::Drum::Hihat.new(SRATE, {
  amp_decay: 0.05
})
hihat_channel = SynthBlocks::Mixer::MixerChannel.new(SRATE, hihat, preset: hat_channel_params)
open_hihat = SynthBlocks::Drum::Hihat.new(SRATE, {
  amp_decay: 0.125
})
open_hihat_channel = SynthBlocks::Mixer::MixerChannel.new(SRATE, hihat, preset: hat_channel_params)

bass = SynthBlocks::Synth::Monosynth.new(SRATE, {
  amp_attack: 0.0001,
  amp_decay: 0.1,
  amp_sustain: 0.8,
  amp_release: 0.02,
  flt_attack: 0.0001,
  flt_decay: 0.05,
  flt_sustain: 0.0,
  flt_release: 0.02,
  flt_envmod: 1600,
  flt_frequency: 200,
  flt_Q: 3,
  osc_waveform: :square,
  lfo_waveform: :sine,
  lfo_frequency: 2
})
bass_channel = SynthBlocks::Mixer::MixerChannel.new(SRATE, bass, insert_effects: [SynthBlocks::Fx::Waveshaper.new(2)], preset: {
  volume: 0.08,
  eq_low_gain: 1.2,
  eq_mid_gain: 0.4,
  eq_high_gain: 0.4
})
lead = SynthBlocks::Synth::Monosynth.new(SRATE, {
  amp_attack: 0.001,
  amp_decay: 0.2,
  amp_sustain: 0.8,
  amp_release: 0.2,
  flt_attack: 0.2,
  flt_decay: 0.2,
  flt_sustain: 0.0,
  flt_release: 0.2,
  flt_envmod: 1000,
  flt_frequency: 2000,
  flt_Q: 3,
  osc_waveform: :sawtooth,
  lfo_waveform: :sine,
  lfo_frequency: 2

})

lead_channel = SynthBlocks::Mixer::MixerChannel.new(SRATE, lead, sends: [0.5, 0.5], insert_effects: [SynthBlocks::Fx::Chorus.new(SRATE)], preset: {
  volume: 0.05,
  duck: 0.8
})

polysynth = SynthBlocks::Synth::Polysynth.new(SRATE, {
  amp_env_attack: 0.001,
  amp_env_release: 0.1,
  flt_env_attack: 0.001,
  flt_env_decay: 0.05,
  flt_env_sustain: 0.1,
  flt_frequency: 300,
  flt_envmod: 2000,
  flt_Q: 1,
  osc_waveform: :square
})
polysynth_channel = SynthBlocks::Mixer::MixerChannel.new(SRATE, polysynth, insert_effects: [], sends: [0.4, 0.5], preset: {
  volume: 0.15, eq_low_gain: 0.4, eq_mid_gain: 1.4
})

reverb_send = SynthBlocks::Mixer::SendChannel.new(SRATE, insert_effects: [
  SynthBlocks::Fx::GVerb.new(SRATE, max_room_size: 120.0, room_size: 80.0, rev_time: 2.0, damping:0.3, spread: 15.0, input_bandwidth: 1.5, early_level:0.8, tail_level: 0.5, mix: 1.0)
], sends: [])

delay_send = SynthBlocks::Mixer::SendChannel.new(SRATE, insert_effects: [
  SynthBlocks::Fx::Delay.new(SRATE, time: 15.0 / TEMPO.to_f * 3, mix: 0.4, feedback: 0.4)
], sends: [0.2])

sum_compressor = SynthBlocks::Fx::Compressor.new(SRATE)
sum_limiter = SynthBlocks::Fx::Limiter.new

def_pattern(:drums_full, 16) do
  drum_pattern kick_drum,   '*---*---*---*---'
  drum_pattern snare_drum,  '----*-------*---'
  drum_pattern hihat,       '--*---*---*---*-'
  drum_pattern open_hihat,  '---------------*'
end

def_pattern(:kick_and_hat, 16) do
  drum_pattern kick_drum,   '*---*---*---*---'
  drum_pattern hihat,       '--*---*---*---*-'
  drum_pattern open_hihat,  '---------------*'
end

def_pattern(:kick, 16) do
  drum_pattern kick_drum,   '*---*---*---*---'
end
def_pattern(:kick_break, 16) do
  drum_pattern kick_drum,   '*---*---*--*--*-'
end

def_pattern(:snare_roll_one, 16) do
  drum_pattern snare_drum, '*---*---*---*---'
end

def_pattern(:snare_roll_two, 16) do
  drum_pattern snare_drum, '*--*--*--*--*--*'
end

def_pattern(:snare_roll_three, 16) do
  drum_pattern snare_drum, '*-*-*-*-*-******'
end

def_pattern(:dubstep, 16) do
  drum_pattern kick_drum,  '*-----*------*--'
  drum_pattern snare_drum, '--------*-------'
  drum_pattern hihat,      '*-*-*-*-*-*-*-*-'
  drum_pattern open_hihat, '-------------*--'
end

def_pattern(:bassline, 16) do
  note_pattern bass, [
    P, P, ['C1', 2], P,
    P, P, P, P,
    P, P, ['C1', 2], P,
    P, P, P, P
  ]
end

def_pattern(:dub_bass, 16) do
  note_pattern bass, [
    ['C1', 1], P, P, P,
    ['C1', 3], P, P, P,
    ['C1', 1], P, P, P,
    ['C#1', 3], P, P, P,
  ]
end

def_pattern(:lead, 32) do
  note_pattern lead, [
    ['A#3', 6], P, P, P,
    P, P, ['G3', 10], P,
    P, P, P, P,
    P, P, P, P,
    ['C3', 6], P, P, P,
    P, P, ['D3', 10], P,
    P, P, P, P,
    P, P, P, P,
  ]
end

def_pattern(:low_chord, 32) do
  note_pattern polysynth, [
    ['C2,E2,G2,C1', 1], P, P,
    ['C2,E2,G2,C1', 1], P, P,
    ['D#2,G2,A#2,D#1', 1], P, P,
    ['D#2,G2,A#2,D#1', 1], P, P,
    ['D#2,G2,A#2,D#1', 1], P, P,
    ['D#2,G2,A#2,D#1', 1], P, P,
    ['F2,A2,C3,F1', 1], P, P,
    ['F2,A2,C3,F1', 1], P, P,
    ['G2,B2,D3,G1', 1], P, P,
    ['G2,B2,D3,G1', 1], P, P,
    ['G2,B2,D3,G1', 1], P
  ]
end
def_pattern(:double_chord, 32) do
  note_pattern polysynth, [
    ['C2,E2,G2,C1,C3,E3,G3', 1], P, P,
    ['C2,E2,G2,C1,C3,E3,G3', 1], P, P,
    ['D#2,G2,A#2,D#1,D#3,G3,A#3', 1], P, P,
    ['D#2,G2,A#2,D#1,D#3,G3,A#3', 1], P, P,
    ['D#2,G2,A#2,D#1,D#3,G3,A#3', 1], P, P,
    ['D#2,G2,A#2,D#1,D#3,G3,A#3', 1], P, P,
    ['F2,A2,C3,F1,F3,A3,C4', 1], P, P,
    ['F2,A2,C3,F1,F3,A3,C4', 1], P, P,
    ['G2,B2,D3,G1,G3,B3,D4', 1], P, P,
    ['G2,B2,D3,G1,G3,B3,D4', 1], P, P,
    ['G2,B2,D3,G1,G3,B3,D4', 1], P
  ]
end

def_pattern(:tom, 16) do
  note_pattern tom, [
    P, P, P, ['C3', 1],
    P, P, ['A#2', 1], P,
    P, ['G2', 1], P, P,
    P, P, P, P,
  ]
end
def_pattern(:tom_long, 32) do
  note_pattern tom, [
    P, P, P, ['C3', 1],
    P, P, ['A#2', 1], P,
    P, ['G2', 1], P, P,
    ['G2', 1], P, P, ['G2', 1],

    P, P, ['F2', 1], P,
    P, ['F2', 1], P, P,
    ['G2', 1], P, P, ['G2', 1],
    P, P, ['G2', 1], P,
  ]
end
def_pattern(:tom_long_high, 32) do
  note_pattern tom, [
    P, P, P, ['C4', 1],
    P, P, ['A#3', 1], P,
    P, ['G3', 1], P, P,
    ['G3', 1], P, P, ['G3', 1],

    P, P, ['F3', 1], P,
    P, ['F3', 1], P, P,
    ['G3', 1], P, P, ['G3', 1],
    P, P, ['G4', 1], P,
  ]
end

my_song = song(bpm: TEMPO) do
  # 0
  pattern(:kick, at: 0, repeat: 2)
  pattern(:bassline, at: 0, repeat: 26)
  # 2
  pattern(:kick_and_hat, at: 2, repeat: 2)
  # 4
  pattern(:low_chord, at: 4, repeat: 4)
  # 6
  pattern(:snare_roll_one, at: 6, repeat: 2)
  # 8
  pattern(:snare_roll_two, at: 8, repeat: 1)
  # 9
  pattern(:snare_roll_three, at: 9, repeat: 1)
  # 10
  pattern(:double_chord, at: 10, repeat: 8)
  pattern(:drums_full, at: 10, repeat: 16)
  # 12
  # 14
  # 16
  # 18
  # 20
  # 22
  pattern(:lead, at: 18, repeat: 4)
  # 24
  # 26 break
  # 27 tom
  pattern(:tom, at: 26, repeat: 1)
  pattern(:tom, at: 28, repeat: 1)
  pattern(:tom_long, at: 30, repeat: 4)
  pattern(:dubstep, at: 30, repeat: 6)
  pattern(:dub_bass, at: 32, repeat: 4)
  pattern(:tom_long_high, at: 36, repeat: 1)
end
# my_song = song(bpm: TEMPO) do
#   pattern(:dub_bass, at: 0, repeat: 2)
#   pattern(:tom_long, at: 0, repeat: 1)
#   pattern(:dubstep, at: 0, repeat: 2)
#   pattern(:tom_long_high, at: 2, repeat: 1)
# end

32.times do |i|
  lead_channel.duck(i * my_song.per_beat + (my_song.per_bar * 18))
end


output = my_song.render(SRATE) do |i|
  sum_limiter.run(sum_compressor.run((
    kick_drum_channel.run(i) + snare_drum_channel.run(i) + hihat_channel.run(i) +
    open_hihat_channel.run(i) + tom_channel.run(i) +
    bass_channel.run(i) + lead_channel.run(i) + polysynth_channel.run(i) +
    delay_send.run(i,
      kick_drum_channel.send(1) + snare_drum_channel.send(1) + hihat_channel.send(1) +
      open_hihat_channel.send(1) + tom_channel.send(1) +
      bass_channel.send(1) + lead_channel.send(1) + polysynth_channel.send(1)
    ) +
    reverb_send.run(i,
      kick_drum_channel.send(0) + snare_drum_channel.send(0) + hihat_channel.send(0) +
      open_hihat_channel.send(0) + tom_channel.send(0) +
      bass_channel.send(0) + lead_channel.send(0) + polysynth_channel.send(0) +
      delay_send.send(0)
    )
  )))
end
STDERR.puts("LENGTH: #{my_song.length}s")
print output.pack('e*')
