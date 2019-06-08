SAMPLING_FREQUENCY=44100
FREQUENCY=110

in_cycle = 0
samples = (8 * SAMPLING_FREQUENCY).times.map do
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output * 0.5
end
print samples.pack('e*')
