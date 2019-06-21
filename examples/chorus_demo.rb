require 'ruby_synth'
SRATE = 44100

mono = Monosynth.new(SRATE, {osc_waveform: :sawtooth})
chorus = Chorus.new(SRATE, {delay_time: 12})



mono.start(0, 36)
mono.stop(1, 36)

mono.start(2, 36)
mono.stop(3, 36)

out = (SRATE * 4).times.map do |i|
  if (i >= SRATE * 2)
    chorus.run(mono.run(i)) * 0.8
  else
    mono.run(i) * 0.8
  end
end

print out.pack('e*')
