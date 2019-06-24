require 'envelope'
require 'sound'
require 'oscillator'

##
# A simple kick drum generator
class KickDrum < Sound

  ##
  # === Structure
  # Pitch Env > Sine wave OSC >
  #
  # === parameter:
  # - pitch_attack, pitch_decay - Pitch envelope params in s
  # - amp_attack, amp_decay - Amp envelope params in s
  # - base_frequency - base frequency in Hz
  # - pitch_mod - frequency modulation amount in Hz
  def initialize(sfreq, preset = {})
    super(sfreq, mode: :polyphonic)
    @preset = {
      pitch_attack: 0.001,
      pitch_decay: 0.05,
      amp_attack: 0.001,
      amp_decay: 0.1,
      base_frequency: 50,
      pitch_mod: 200
    }.merge(preset)
    @oscillator = Oscillator.new(@sampling_frequency)
    @pitch_env = Envelope.new(@preset[:pitch_attack], @preset[:pitch_decay])
    @amp_env = Envelope.new(@preset[:amp_attack], @preset[:amp_decay])
  end

  def duration(_) # :nodoc:
    @preset[:amp_attack] + @preset[:amp_decay]
  end
  ##
  # Run generator
  def run(offset)
    t = time(offset)
    events = active_events(t)
    if events.empty?
      0.0
    else
      event = events[events.keys.last]
      local_started = t - event[:started]
      osc_out = @oscillator.run(@preset[:base_frequency].to_f + @pitch_env.run(local_started) * @preset[:pitch_mod].to_f, waveform: :sine)
      osc_out = osc_out * 1.0 * @amp_env.run(local_started)
    end
  end
end
