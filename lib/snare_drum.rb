##
# Simple snare drum generator
class SnareDrum < Sound
  ##
  # === Parameters
  # [flt_frequency] Noise filter frequency
  # [flt_envmod] Noise filter frequency modulation by envelope
  # [flt_attack, flt_decay] Noise filter envelope params
  # [flt_Q] Noise filter Q/resonance
  # [noise_amp_attack, noise_amp_decay] Noise amp envelope params
  # [noise_vol, drum_vol] Noise and Drum body volumes
  # [base_frequency] Drum body base frequency (see KickDrum#initialize)
  # [pitch_mod] Drum body pitch mod (see KickDrum#initialize)
  # [pitch_attack, pitch_decay] Drum body pitch env params
  #
  def initialize(sfreq, preset = {})
    super(sfreq, mode: :polyphonic)
    @preset = {
      flt_frequency: 4000,
      flt_envmod: 6000,
      flt_attack: 0.001,
      flt_decay: 0.1,
      flt_Q: 2,
      noise_amp_attack: 0.001,
      noise_amp_decay: 0.15,
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

  # create a note on event
  # [t] time in seconds since song start
  # [note] MIDI note number
  # [velocity] velocity (currently unused)
  def start(t, note = 36, velocity = 1.0)
    super(t, note, velocity)
    @drum.start(t, note, velocity)
  end

  # create a note off event
  # [t] time in seconds since song start
  # [note] MIDI note number
  def stop(t, note = 36)
    super(t, note)
    @drum.stop(t, note)
  end

  def duration(t) # :nodoc:
    [@preset[:noise_amp_attack] + @preset[:noise_amp_decay], @drum.duration(t)].max
  end

  # run the generator
  def run(offset)
    drum_out = @drum.run(offset)
    # time in seconds
    t = time(offset)
    events = active_events(t)
    if events.empty?
      0.0
    else
      event = events[events.keys.last]
      # lfo_out = (@lfo.run(@preset[:lfo_frequency], waveform: @preset[:lfo_waveform]) + 1) / 8 + 0.5
      noise_out = rand * 2.0 - 1.0
      local_started = t - event[:started]
      noise_out = @filter.run(noise_out, @preset[:flt_frequency] + @flt_env.run(local_started) * @preset[:flt_envmod], @preset[:flt_Q])
      noise_out = 0.3 * noise_out * @amp_env.run(local_started)
      noise_out * @preset[:noise_vol] + drum_out * @preset[:drum_vol]
    end
  end
end
