require_relative 'envelope'
require_relative 'sound'
require_relative 'oscillator'

class KickDrum < Sound
  def initialize(sfreq, preset = {})
    super(sfreq, mode: :monophonic)
    @preset = {
      pitch_attack: 0.001,
      pitch_decay: 0.05,
      amp_attack: 0.001,
      amp_decay: 0.1,
      Q: 3,
      noise_vol: 0.5,
      drum_vol: 0.5,
      base_frequency: 50,
      pitch_mod: 200

    }.merge(preset)
    @oscillator = Oscillator.new(@sampling_frequency)
    @pitch_env = Envelope.new(@preset[:pitch_attack], @preset[:pitch_decay])
    @amp_env = Envelope.new(@preset[:amp_attack], @preset[:amp_decay])
  end


  def run(offset)
    t = time(offset)
    events = active_events(t)
    if events.empty?
      0.0
    else
      event = events.last
      local_started = t - event[:started]
      osc_out = @oscillator.run(@preset[:base_frequency].to_f + @pitch_env.run(local_started) * @preset[:pitch_mod].to_f, waveform: :sine)
      osc_out = osc_out * 1.0 * @amp_env.run(local_started)
    end
  end
end
