
class StateVariableFilter

  def initialize(sfreq)
    @sfreq = sfreq
    @d1 = 0
    @d2 = 0
  end

  def run(x, f, q, type: :lowpass)
    q1 = 1.0 / q.to_f
    f1 = 2 * Math::PI * f / @sfreq
    l = @d2 + f1 * @d1
    h = x - l - q1 * @d1
    b = f1 * h + @d1
    n = h + l

    # store delays
    @d1 = b
    @d2 = l

    results = {lowpass: l, highpass: h, bandpass: b, notch: n}
    results[type]
  end
end
