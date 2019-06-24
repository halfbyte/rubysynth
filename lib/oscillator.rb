##
# simple  oscillator
# can currently do squarewave, sawtooth and sine
# this oscillator is not bandwidth limited and will thus alias like there's no tomorrow
class Oscillator
  ##
  # Create new oscillator
  def initialize(sampling_frequency)
    @sampling_frequency = sampling_frequency.to_f
    @in_cycle = 0
  end

  # [frequency] Oscillator frequency in Hz (can be altered at any time)
  # [pulse_width] pulse width, only in effect when creating a square wave
  # [waveform] can be: :square (default), :sawtooth, :sine
  def run(frequency, pulse_width: 0.5, waveform: :square)
    period = @sampling_frequency / frequency.to_f
    output = 0
    if waveform == :square
      output = @in_cycle > pulse_width ? -1.0 : 1.0
    end
    if waveform == :sawtooth
      output = (@in_cycle * 2) - 1.0
    end
    if waveform == :sine
      phase = @in_cycle * 2 * Math::PI
      output = Math.sin(phase)
    end
    @in_cycle = (@in_cycle + (1.0 / period)) % 1.0
    output
  end
end
