# Simple State Variable filter
#
# source: http://www.musicdsp.org/en/latest/Filters/23-state-variable.html
# More info: https://www.earlevel.com/main/2003/03/02/the-digital-state-variable-filter/

class StateVariableFilter

  def initialize(sfreq)
    @sampling_frequency = sfreq
    @delay_1 = 0
    @delay_2 = 0
  end

  # run the filter from input value
  # frequency is cutoff freq in Hz
  # q is resonance, from 0 to ...
  # type can be :lowpass, :highpass, :bandpass and :notch
  def run(input, frequency, q, type: :lowpass)
    # derived parameters
    q1 = 1.0 / q.to_f
    f1 = 2 * Math::PI * frequency / @sampling_frequency

    # calculate filters
    lowpass = @delay_2 + f1 * @delay_1
    highpass = input - lowpass - q1 * @delay_1
    bandpass = f1 * highpass + @delay_1
    notch = highpass + lowpass

    # store delays
    @delay_1 = bandpass
    @delay_2 = lowpass

    results = { lowpass: lowpass, highpass: highpass, bandpass: bandpass, notch: notch }
    results[type]
  end
end
