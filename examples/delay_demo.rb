require 'ruby_synth'
SRATE = 44100

snare = SnareDrum.new(SRATE)
delay = Delay.new(SRATE, time: 0.3)
snare.start(0)

out = (SRATE * 2).times.map do |i|
  delay.run(snare.run(i))
end

print out.pack('e*')

