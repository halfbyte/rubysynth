require 'ruby_synth'
SRATE = 44100

drum = KickDrum.new(SRATE)
drum.start(0)
drum.start(0.5)
drum.start(1)
drum.start(1.5)

SHAPER_RATES = [1,2,4,8]


out = []
4.times do |r|
  shaper = Waveshaper.new(SHAPER_RATES[r])

  (SRATE * 2).times do |i|
    out << shaper.run(drum.run(i))
  end
end

print out.pack('e*')
