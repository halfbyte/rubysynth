require_relative 'lib/oscillator'
require_relative 'lib/envelope'
require_relative 'lib/state_variable_filter'
require_relative 'lib/g_verb'
require_relative 'lib/delay'
require_relative 'lib/eq'
require_relative 'lib/utils'

include Utils

SFREQ = 44100
NOTES = [24, 24, 48, 37]
OFFSETS = [0, 0, 3, 7]
TEMPO = 120

def n2f(n)
  (2.0 ** ((n - 69) / 12.0)) * 440.0
end

oscillator = Oscillator.new(SFREQ)
filter = StateVariableFilter.new(SFREQ)
vol_ar = Envelope.new(0.001,0.1)
flt_ar = Envelope.new(0.02,0.04)
verb = GVerb.new(SFREQ, max_room_size: 1200.0, room_size: 5.0, rev_time: 2.0, damping:0.3, spread: 15.0, input_bandwidth: 0.5, early_level:0.8, tail_level: 0.5)
delay = Delay.new(SFREQ, 15.0 / TEMPO.to_f * 3)
eq = Eq.new(SFREQ)
eq.lg = 0.8
eq.mg = 0.5
eq.hg = 1.0

delay_eq = Eq.new(SFREQ)
delay_eq.lg = 0.2
delay_eq.mg = 0.6


(4 * SFREQ).times do |sample|
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
  v = delay.run(v, 0.4, 0.4) do |f|
    delay_eq.run(f)
  end
  v = verb.run(v, 0.1).first
  v *= 0.33
  v = [1.0, [-1.0, v].max].min

  print [v].pack('e')
end
