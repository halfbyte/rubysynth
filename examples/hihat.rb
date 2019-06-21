require 'ruby_synth'

SRATE = 44100
hat = Hihat.new(SRATE)

hat.start(0.0)

print SRATE.times.map {|i| 0.5 * hat.run(i) }.pack('e*')

