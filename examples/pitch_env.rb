require 'state_variable_filter'
require 'adsr'

SAMPLING_FREQUENCY=44100
FREQUENCY=440

filter = StateVariableFilter.new(SAMPLING_FREQUENCY)
amp_env = Adsr.new(0.001, 0.2, 0.5, 0.2)
filter_env = Adsr.new(0.01, 0.1, 0.1, 0.1)
pitch_env = Adsr.new(0.01, 0.2, 0.0, 0.0)
in_cycle = 0
samples = SAMPLING_FREQUENCY.times.map do |s|
  t  = s.to_f / SAMPLING_FREQUENCY.to_f
  stopped = t >= 0.5 ? 0.5 : nil
  period = SAMPLING_FREQUENCY / (FREQUENCY.to_f * ((0.2 * pitch_env.run(t, stopped)) + 1))
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output = filter.run(output, 500.0 + (8000.0 * filter_env.run(t, stopped)), 1)
  output *= 0.3 * amp_env.run(t, stopped)
end
print samples.pack('e*')
