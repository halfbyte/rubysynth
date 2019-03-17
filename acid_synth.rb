require_relative 'lib/envelope'
require_relative 'lib/state_variable_filter'
require_relative 'lib/g_verb'

SFREQ = 44100
NOTES = [24, 24, 48, 37]
OFFSETS = [0, 0, 3, 7]
TEMPO = 120

def n2f(n)
  (2.0 ** ((n - 69) / 12.0)) * 440.0
end

filter = StateVariableFilter.new(SFREQ)
vol_ar = Envelope.new(0.001,0.1)
flt_ar = Envelope.new(0.02,0.04)
verb = GVerb.new(SFREQ, max_room_size: 200.0, room_size: 5.0, rev_time: 0.3, damping:0.3, spread: 15.0, input_bandwidth: 0.5, early_level:0.8, tail_level: 0.5)


(4 * SFREQ).times do |sample|
  t = sample.to_f / SFREQ.to_f # time in seconds
  s_per_b = 15.0 / TEMPO.to_f # seconds per quarternote
  b = t / s_per_b # quarternote
  t_in_b = t % s_per_b #time in quarternote
  l = (b / 4).floor # loop
  freq = n2f(NOTES[b % NOTES.length] + OFFSETS[l % OFFSETS.length])
  period = 1.0 / (freq.to_f)
  v = 1.0
  v *= -1.0 if t % period > (period / 2)
  v = filter.run(v, 200 + flt_ar.run(t_in_b) * 400, 3)
  v *= vol_ar.run(t_in_b)
  v = (v*0.7) + 0.3 * verb.run(v).first
  v *= 0.33
  # v = [1.0, [-1.0, v].max].min

  print [v].pack('e')
end
