require 'synth_blocks'

#
# A more complex example on how to compose synth blocks
# 

include SynthBlocks::Utils

SFREQ = 44100
NOTES = [24, 24, 48, 37]
OFFSETS = [0, 0, 3, 7]
TEMPO = 120

def n2f(n)
  (2.0 ** ((n - 69) / 12.0)) * 440.0
end

oscillator = SynthBlocks::Core::Oscillator.new(SFREQ)
filter = SynthBlocks::Core::StateVariableFilter.new(SFREQ)
vol_ar = SynthBlocks::Mod::Envelope.new(0.001,0.1)
flt_ar = SynthBlocks::Mod::Envelope.new(0.02,0.04)
verb = SynthBlocks::Fx::GVerb.new(SFREQ, max_room_size: 1200.0, room_size: 5.0, rev_time: 2.0, damping:0.3, spread: 15.0, input_bandwidth: 0.5, early_level:0.8, tail_level: 0.5)
delay = SynthBlocks::Fx::Delay.new(SFREQ, time: 15.0 / TEMPO.to_f * 3)
eq = SynthBlocks::Fx::Eq.new(SFREQ)
eq.low_gain = 0.8
eq.mid_gain = 0.5
eq.high_gain = 1.0

delay_eq = SynthBlocks::Fx::Eq.new(SFREQ)
delay_eq.low_gain = 0.2
delay_eq.mid_gain = 0.6


out = (4 * SFREQ).times.map do |sample|
  t = sample.to_f / SFREQ.to_f # time in seconds
  s_per_b = 15.0 / TEMPO.to_f # seconds per quarternote
  b = t / s_per_b # quarternote
  t_in_b = t % s_per_b #time in quarternote
  l = (b / 4).floor # loop
  freq = n2f(24 + NOTES[b % NOTES.length] + OFFSETS[l % OFFSETS.length])
  v = oscillator.run(freq, waveform: :sawtooth)
  v = filter.run(v, 200 + flt_ar.run(t_in_b) * 1500, 4)
  v *= vol_ar.run(t_in_b)
  v = simple_waveshaper(v, 2)
  v = eq.run(v)
  v = delay.run(v) do |f|
    delay_eq.run(f)
  end
  v = v + (verb.run(v) * 0.2)
  v *= 0.33
  [1.0, [-1.0, v].max].min
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
