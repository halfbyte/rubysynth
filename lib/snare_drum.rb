require_relative 'kick_drum'
require_relative 'envelope'
require_relative 'sound'
require_relative 'state_variable_filter'

class SnareDrum < Sound
  def initialize(sfreq, preset = {})
    super(sfreq, mode: :monophonic)
    @preset = {
      flt_frequency: 4000,
      flt_envmod: 6000,
      flt_attack: 0.001,
      flt_decay: 0.1,
      noise_amp_attack: 0.001,
      noise_amp_decay: 0.15,
      flt_Q: 2,
      noise_vol: 0.5,
      drum_vol: 0.3,
      base_frequency: 200,
      pitch_mod: 200,
      pitch_decay: 0.07

    }.merge(preset)
    @drum = KickDrum.new(sfreq, @preset)
    @filter = StateVariableFilter.new(sfreq)
    @flt_env = Envelope.new(@preset[:flt_attack], @preset[:flt_decay])
    @amp_env = Envelope.new(@preset[:noise_amp_attack], @preset[:noise_amp_decay])

  end

  def start(t, note=36, velocity=1.0)
    super(t, note, velocity)
    @drum.start(t, note, velocity)
  end

  # create a note off event at time t with note
  def stop(t, note=36)
    super(t, note: note, )
    @drum.stop(t, note: note)
  end


  def run(offset)
    drum_out = @drum.run(offset)
    # time in seconds
    t = time(offset)
    events = active_events(t)
    if events.empty?
      0.0
    else
      event = events.last
      # lfo_out = (@lfo.run(@preset[:lfo_frequency], waveform: @preset[:lfo_waveform]) + 1) / 8 + 0.5
      noise_out = rand * 2.0 - 1.0
      local_started = t - event[:started]
      noise_out = @filter.run(noise_out, @preset[:flt_frequency] + @flt_env.run(local_started) * @preset[:flt_envmod], @preset[:flt_Q])
      noise_out = 0.3 * noise_out * @amp_env.run(local_started)
      noise_out * @preset[:noise_vol] + drum_out * @preset[:drum_vol]
    end
  end
end
