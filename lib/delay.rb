# Simple delay with mix and feedback parameters
# Currently doesn't really have a variable delay time, I'll tackle that when I need it
# It uses a simple ring buffer implementation and delay time is only exact down to the
# sample.
class Delay
  attr_reader :mix, :feedback

  # time is given in seconds
  # mix (0 = no delay, 1 = only delay), feedback (0 = zero feedback, 1 = full feedback (not advised))
  # if given a block it will call the block from the run method to process the feedback signal
  def initialize(sample_rate, time: 0.2, mix: 0.5, feedback: 0.4, &block)
    @buffer = Array.new((sample_rate.to_f * time).floor)
    @block = block
    @pointer = 0
    @mix = mix
    @feedback = feedback
  end

  # input value,
  def run(input)
    old_pointer = @pointer
    @pointer = (@pointer + 1) % @buffer.length
    delayed = (@buffer[@pointer] || 0.0)
    if @block
      delayed = @block.call(delayed)
    end
    @buffer[old_pointer] = input + (feedback * delayed)
    input * (1.0 - mix) + delayed * mix
  end
end
