require 'ruby_synth'

SRATE = 44100
kick = KickDrum.new(SRATE)

kick.start(0.0)

print SRATE.times.map {|i| 0.3 * kick.run(i) }.pack('e*')

