class OnePoleLP # :nodoc:
  def initialize
    @outputs = 0.0
  end
  def run(input, cutoff)
    p = (cutoff * 0.98) * (cutoff * 0.98) * (cutoff * 0.98) * (cutoff * 0.98);
    @outputs = (1.0 - p) * input + p * @outputs
  end
end

##
# A simple chorus
class Chorus
  ##
  attr_writer :phase, :rate, :delay_time, :mix # :nodoc:
  ##
  # Create new Chorus instance
  #
  # phase allows you to shift the phase of the delayed signal additionally
  #
  # rate is the LFO rate in Hz
  #
  # delay_time is the maximum delay time in ms
  #
  # mix is the ratio between original and delayed signal. 1.0 would mean only
  # delayed signal (which wouldn't make any sense)
  def initialize(sample_rate, phase: 0.0, rate: 0.5, delay_time: 7.0, mix: 0.5)
    @sample_rate = sample_rate
    @rate = rate
    @delay_time = delay_time
    @mix = mix

    @z1 = 0.0
    @sign = 0
    @lfo_phase = phase * 2.0 - 1.0
    @lfo_step_size = (4.0 * @rate / @sample_rate)
    @lfo_sign = 1.0

    # Compute required buffer size for desired delay and allocate it
    # Add extra point to aid in interpolation later
    @delay_line_length = ((@delay_time * @sample_rate * 0.001).floor * 2).to_i
    @delay_line = [0.0] * @delay_line_length
    @write_ptr = @delay_line_length - 1
    @lp = OnePoleLP.new
    @output = 0.0
  end

  ##
  # run the chorus
  def run(input)
    # Get delay time
    offset = (next_lfo() * 0.3 + 0.4) * @delay_time * @sample_rate * 0.001

    # Compute the largest read pointer based on the offset.  If ptr
    # is before the first delayline location, wrap around end point
    ptr = @write_ptr - offset.floor;
    ptr += @delay_line_length - 1 if ptr < 0


    ptr2 = ptr - 1
    ptr2 += @delay_line_length - 1 if ptr2 < 0

    frac = offset - offset.floor.to_f
    @output = @delay_line[ptr2] + @delay_line[ptr] * (1.0 - frac) - (1.0 - frac) * @z1
    @z1 = @output

    # Low pass
    @lp.run(@output, 0.95)

    # Write the input sample and any feedback to delayline
    @delay_line[@write_ptr] = input

    # Increment buffer index and wrap if necesary
    @write_ptr += 1
    @write_ptr = 0 if @write_ptr >= @delay_line_length
    return (@output * @mix) + (input * (1.0-@mix))
  end

  private

  def next_lfo()
    if @lfo_phase >= 1.0
      @lfo_sign = -1.0
    elsif @lfo_phase <= -1.0
      @lfo_sign = 1.0
    end
    @lfo_phase += @lfo_step_size * @lfo_sign
  end
end
