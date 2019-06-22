class TunedDrum < KickDrum
  def run(offset)
    t = time(offset)
    events = active_events(t)
    if events.empty?
      0.0
    else
      event = events[events.keys.last]
      note = events.keys.last
      base_freq = frequency(note)
      local_started = t - event[:started]
      osc_out = @oscillator.run(base_freq + @pitch_env.run(local_started) * @preset[:pitch_mod].to_f, waveform: :sine)
      osc_out = osc_out * 1.0 * @amp_env.run(local_started)
    end
  end
end
