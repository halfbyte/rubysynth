require_relative 'lib/envelope'
require_relative 'lib/state_variable_filter'
require_relative 'lib/g_verb'

SFREQ = 44100
FREQ = 60

vEnv = Envelope.new(0.001, 0.05)

filter = StateVariableFilter.new(SFREQ)
verb = GVerb.new(SFREQ, max_room_size: 200.0, room_size: 50.0, rev_time: 3.0, damping:0.5, spread: 15.0, input_bandwidth: 0.5, early_level:0.8, tail_level: 0.5)

in_cycle = 0
File.open('debug.txt', 'w') do |debug|
  (SFREQ).times do |sample|
    t = sample.to_f / SFREQ.to_f
    v = rand * 2 - 1
    v *= vEnv.run(t)
    v = filter.run(v, 6000, 1, type: :highpass)
    v *= 0.4
    print [v].pack('e')
  end
end
