require 'synth_blocks'
SRATE = 44100

snare = SynthBlocks::Drum::SnareDrum.new(SRATE)
reverb = SynthBlocks::Fx::GVerb.new(SRATE)
snare.start(0)

out = (SRATE * 2).times.map do |i|
  reverb.run(snare.run(i))
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)


