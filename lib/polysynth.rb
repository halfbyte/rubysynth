class PolyVoice # :nodoc:
  def initialize(sfreq, parent, preset)
    @sampling_frequency = sfreq
    @parent = parent
    @preset = presete
    @oscillator = Oscillator.new(sfreq)
    @filter = StateVariableFilter.new(sfreq)
    @amp_env = Adsr.new(@preset[:amp_env_attack], @preset[:amp_env_decay], @preset[:amp_env_sustain], @preset[:amp_env_release])
    @flt_env = Adsr.new(@preset[:flt_env_attack], @preset[:flt_env_decay], @preset[:flt_env_sustain], @preset[:flt_env_release])
  end

  def run(started, stopped, frequency, velocity)
    osc_out = @oscillator.run(frequency, waveform: @preset[:osc_waveform])
    osc_out = @filter.run(osc_out, @parent.get(:flt_frequency, started) + @flt_env.run(started, stopped) * @parent.get(:flt_envmod, started), @preset[:flt_Q])
    osc_out = osc_out * @amp_env.run(started, stopped) * velocity
  end

end

##
# A simple polyphonic synthesizer
#
# OSC > Filter > Amp
#

class Polysynth < Sound
  # === Parameters
  # - amp_attack, _decay, _sustain, _release - Amp Envelope params
  # - flt_attack, _decay, _sustain, _release - Filter Envelope params
  # - flt_envmod - filter envelope modulation amount in Hz
  # - flt_frequency, flt_Q - filter params
  # - osc_waveform - waveform to generate (see Oscillator class)
  def initialize(sfreq, preset = {})
    @preset = {
      osc_waveform: :sawtooth,
      amp_env_attack: 0.2,
      amp_env_decay: 0.2,
      amp_env_sustain: 0.8,
      amp_env_release: 0.5,
      flt_env_attack: 0.5,
      flt_env_decay: 0.7,
      flt_env_sustain: 0.4,
      flt_env_release: 0.5,
      flt_frequency: 1000,
      flt_envmod: 2000,
      flt_Q: 3
    }.merge(preset)
    super(sfreq, mode: :polyphonic)
    @active_voices = {}
  end

  def live_params # :nodoc:
    [:flt_frequency, :flt_envmod]
  end

  def release(t) # :nodoc:
    get(:flt_env_release, t)
  end

  ##
  # run sound generator
  def run(offset)
    t = time(offset)
    events = active_events(t)
    voice_results = []
    events.each do |note, event|
      local_started = t - event[:started]
      next if local_started < 0
      local_stopped = event[:stopped] && event[:stopped] - event[:started]
      note_key = "#{note}:#{event[:started]}"
      if @active_voices[note_key].nil?
        @active_voices[note_key] = PolyVoice.new(@sampling_frequency, self, @preset)
      end
      if @active_voices[note_key]
        voice_results << @active_voices[note_key].run(local_started, local_stopped, frequency(note), event[:velocity])
      end
    end
    0.3 * voice_results.inject(0) {|sum, result| sum + result}
  end
end
