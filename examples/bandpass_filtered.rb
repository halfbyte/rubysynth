require 'state_variable_filter'

SAMPLING_FREQUENCY=44100
FREQUENCY=440

filter = StateVariableFilter.new(SAMPLING_FREQUENCY)

in_cycle = 0
samples = SAMPLING_FREQUENCY.times.map do
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output = filter.run(output, 1200.0, 2, type: :bandpass)
  output *= 0.3
end
print samples.pack('e*')
