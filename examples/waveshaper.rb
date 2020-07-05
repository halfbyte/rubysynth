require 'synth_blocks'

#
# Example to show the effect of the waveshaper by increasingly distorting a kick drum
#

SRATE = 44100

drum = SynthBlocks::Drum::KickDrum.new(SRATE)
drum.start(0)
drum.start(0.5)
drum.start(1)
drum.start(1.5)

SHAPER_RATES = [1,2,4,8]


out = []
4.times do |r|
  shaper = SynthBlocks::Fx::Waveshaper.new(SHAPER_RATES[r])

  (SRATE * 2).times do |i|
    out << shaper.run(drum.run(i))
  end
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)