require 'ruby_synth'
SRATE = 44100

snare = SnareDrum.new(SRATE)
reverb = GVerb.new(SRATE)
snare.start(0)

out = (SRATE * 2).times.map do |i|
  reverb.run(snare.run(i))
end

print out.pack('e*')


