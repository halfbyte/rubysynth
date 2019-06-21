require 'ruby_synth'
SFREQ = 44100


synth = Monosynth.new(SFREQ)

synth.start(0, note: 48)
synth.stop(1.5, note: 48)
synth.start(1, note: 48 + 3)
synth.start(2.5, note: 48 - 2)
synth.stop(2.7, note: 48 + 3)
synth.stop(3, note: 48 - 2)

out = (4 * SFREQ).times.map { |i|
  synth.run(i)
}
print out.pack('e*')
