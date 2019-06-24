##
# Simple soft limiter
# Taken from https://github.com/pichenettes/stmlib/blob/448babb082dfe7b0a1ffbf0b349eefde64691b49/dsp/dsp.h#L97
class Limiter

  ##
  # run limiter
  def run(x)
    x * (27.0 + x * x) / (27.0 + 9.0 * x * x)
  end
end
