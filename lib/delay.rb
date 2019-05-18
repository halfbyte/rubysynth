# Simple delay with mix and feedback parameters
# Currently doesn't really have a variable delay time, I'll tackle that when I need it
# It uses a simple ring buffer implementation and delay time is only exact down to the
# sample.
class Delay
  # time is given in seconds
  def initialize(sample_rate, time)
    @buffer = Array.new((sample_rate.to_f * time).floor)
    @pointer = 0
  end

  # input value, mix (0 = no delay, 1 = only delay), feedback (0 = zero feedback, 1 = full feedback (not advised))
  # you can supply an additional block to filter the delay signal, for example with Eq. parameter is the delay signal value,
  # block needs to return the filtered signal value
  def run(input, mix, feedback = 0.4)
    old_pointer = @pointer
    @pointer = (@pointer + 1) % @buffer.length
    delayed = (@buffer[@pointer] || 0.0)
    if block_given?
      delayed = yield delayed
    end
    @buffer[old_pointer] = input + (feedback * delayed)
    input * (1.0 - mix) + delayed * mix
  end
end
