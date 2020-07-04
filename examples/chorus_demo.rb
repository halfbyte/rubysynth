require 'synth_blocks'
SRATE = 44100

#
# Example of the Chorus effect
#

mono = SynthBlocks::Synth::Monosynth.new(SRATE, {osc_waveform: :sawtooth})
chorus = SynthBlocks::Fx::Chorus.new(SRATE, delay_time: 12)

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

SynthBlocks::Core::WaveWriter.write_if_name_given(out)
