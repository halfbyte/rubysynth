require 'state_variable_filter'
require 'oscillator'
require 'adsr'
SAMPLING_FREQUENCY=44100
FREQUENCY=55

filter = StateVariableFilter.new(SAMPLING_FREQUENCY)
lfo = Oscillator.new(SAMPLING_FREQUENCY)
lfo_freq = 4
env = Adsr.new(0.001, 0.2, 0.5, 0.2)

in_cycle = 0
samples = SAMPLING_FREQUENCY.times.map do |s|
  t  = s.to_f / SAMPLING_FREQUENCY.to_f
  stopped = t >= 0.8 ? 0.8 : nil
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output = filter.run(output, 500.0 + ((lfo.run(lfo_freq, waveform: :sawtooth) + 1) * 2000.0), 2)
  output *= 0.3 * env.run(t, stopped)
end
print samples.pack('e*')
