require_relative 'lib/envelope'
require_relative 'lib/moog_filter'
require_relative 'lib/g_verb'

SFREQ = 44100
FREQ = 50

pEnv = Envelope.new(0.001, 0.05)
vEnv = Envelope.new(0.001, 0.1)
fEnv = Envelope.new(0.001, 0.025)

filter = MoogFilter.new


verb = GVerb.new(SFREQ, max_room_size: 100.0, room_size: 20.0, rev_time: 0.5, damping:0.4, spread: 15.0, input_bandwidth: 0.5, early_level:0.8, tail_level: 0.5)

in_cycle = 0
File.open('debug.txt', 'w') do |debug|
  (SFREQ*5).times do |sample|
    t = sample.to_f / SFREQ.to_f # time in seconds
    freq = (FREQ.to_f + (pEnv.run(t) * 200.0))
    period = SFREQ.to_f / freq
    in_cycle = 0 if (in_cycle > 1)
    debug.puts "#{sample},#{t}, #{pEnv.run(t)}, #{freq},#{period},#{in_cycle}"
    v = (in_cycle > 0.5) ? 1.0 : -1.0
    v = filter.run(v, 0.05 + (fEnv.run(t) * 0.1), 0.5)
    v *= 0.8 * vEnv.run(t)
    v = (v*0.8) + 0.2 * verb.run(v).first
    print [v].pack('e')
    in_cycle += (1.0 / period)
  end
end
