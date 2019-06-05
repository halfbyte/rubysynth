require_relative 'lib/monosynth'

SFREQ = 44100


synth = Monosynth.new(SFREQ)

synth.start(0, note: 48)
synth.stop(1.5, note: 48)
synth.start(1, note: 48 + 3)
synth.stop(2.5)
synth.start(2.5, note: 48 - 2)
synth.stop(2.7)

out = synth.run(0, 4 * SFREQ)


print out.pack('e*')
