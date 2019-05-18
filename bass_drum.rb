require_relative 'lib/envelope'
require_relative 'lib/moog_filter'
require_relative 'lib/oscillator'
require_relative 'lib/g_verb'
require_relative 'lib/utils'
require_relative 'lib/delay'
require_relative 'lib/eq'
include Utils

SFREQ = 44100
FREQ = 50

pEnv = Envelope.new(0.001, 0.05)
vEnv = Envelope.new(0.001, 0.1)
fEnv = Envelope.new(0.001, 0.025)

osc = Oscillator.new(SFREQ)

filter = MoogFilter.new


verb = GVerb.new(SFREQ, max_room_size: 1000.0, room_size: 10.0, rev_time: 2.0, damping:0.4, spread: 15.0, input_bandwidth: 0.5, early_level:0.8, tail_level: 0.5)

delay = Delay.new(SFREQ, 0.2)

eq = Eq.new(SFREQ)
eq.lg = 0.2
eq.mg = 0.4
eq.hg = 1.1

in_cycle = 0
File.open('debug.txt', 'w') do |debug|
  (SFREQ*1).times do |sample|
    t = sample.to_f / SFREQ.to_f # time in seconds
    freq = (FREQ.to_f + (pEnv.run(t) * 200.0))
    v = osc.run(freq, waveform: :sine)
    # debug.puts "#{sample},#{t}, #{pEnv.run(t)}, #{freq},#{period},#{in_cycle}"
    # v = filter.run(v, 0.05 + (fEnv.run(t) * 0.1), 3)
    v *= 0.8 * vEnv.run(t)
    v = simple_waveshaper(v, 4)
    v = delay.run(v, 0.4, 0.5) do |signal|
      eq.run(signal)
    end
    v = verb.run(v, 0.01).first
    print [v].pack('e')
  end
end
