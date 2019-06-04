require_relative 'lib/state_variable_filter'

SAMPLING_FREQUENCY=44100
FREQUENCY=440


in_cycle = 0
samples = SAMPLING_FREQUENCY.times.map do
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output =
  output *= 0.5
end
print samples.pack('e*')
