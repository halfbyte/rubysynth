##
# Simple 3 band Equalizer with variable shelving frequencies
#
# Source: http://www.musicdsp.org/en/latest/Filters/236-3-band-equaliser.html
class Eq
  VSA = 1.0 / 4294967295.0 # very small amount (Denormal fix) :nodoc:

  attr_accessor :low_gain, :mid_gain, :high_gain # :nodoc: Low Gain, Mid Gain, High Gain

  ##
  # Create new Equalizer instance
  #
  # lowfreq and highfreq are the shelving frequencies in Hz
  def initialize(sample_rate=44100, lowfreq: 880, highfreq: 5000)

    # Poles Lowpass
    @f1p0 = 0.0
    @f1p1 = 0.0
    @f1p2 = 0.0
    @f1p3 = 0.0

    # Poles Highpass
    @f2p0 = 0.0
    @f2p1 = 0.0
    @f2p2 = 0.0
    @f2p3 = 0.0

    # Sample history buffer

    @sdm1 = 0.0 # Sample data minus 1
    @sdm2 = 0.0 #                   2
    @sdm3 = 0.0 #                   3

    # Gain Controls
    # Set Low/Mid/High gains to unity

    @low_gain  = 1.0       # low  gain
    @mid_gain  = 1.0       # mid  gain
    @high_gain = 1.0       # high gain

    # Calculate filter cutoff frequencies

    @lf = 2 * Math.sin(Math::PI * (lowfreq.to_f / sample_rate.to_f))
    @hf = 2 * Math.sin(Math::PI * (highfreq.to_f / sample_rate.to_f))
  end

  ##
  # run equalizer
  def run(sample)
    # Filter #1 (lowpass)

    @f1p0  += (@lf * (sample - @f1p0)) + VSA;
    @f1p1  += (@lf * (@f1p0 - @f1p1));
    @f1p2  += (@lf * (@f1p1 - @f1p2));
    @f1p3  += (@lf * (@f1p2 - @f1p3));

    l = @f1p3;

    # Filter #2 (highpass)

    @f2p0  += (@hf * (sample   - @f2p0)) + VSA;
    @f2p1  += (@hf * (@f2p0 - @f2p1));
    @f2p2  += (@hf * (@f2p1 - @f2p2));
    @f2p3  += (@hf * (@f2p2 - @f2p3));

    h = @sdm3 - @f2p3;

    # Calculate midrange (signal - (low + high))

    m = @sdm3 - (h + l);

    # Scale, Combine and store

    l *= @low_gain
    m *= @mid_gain
    h *= @high_gain

    # Shuffle history buffer

    @sdm3   = @sdm2;
    @sdm2   = @sdm1;
    @sdm1   = sample;

    # Return result

    l + m + h
  end
end
