require_relative 'oscillator'
require_relative 'adsr'
require_relative 'sound'
require_relative 'state_variable_filter'
class PolyVoice
  def initialize(sfreq, preset)
    @sampling_frequency = sfreq
    @preset = preset
    @oscillator = Oscillator.new(sfreq)
    @filter = StateVariableFilter.new(sfreq)
    @amp_env = Adsr.new(@preset[:amp_env_attack], @preset[:amp_env_decay], @preset[:amp_env_sustain], @preset[:amp_env_release])
    @flt_env = Adsr.new(@preset[:flt_env_attack], @preset[:flt_env_decay], @preset[:flt_env_sustain], @preset[:flt_env_release])
  end

  def run(started, stopped, frequency, velocity)
    osc_out = @oscillator.run(frequency, waveform: @preset[:osc_waveform])
    osc_out = @filter.run(osc_out, @preset[:flt_frequency] + @flt_env.run(started, stopped) * @preset[:flt_envmod], @preset[:flt_Q])
    osc_out = osc_out * @amp_env.run(started, stopped) * velocity
  end

end

class Polysynth < Sound
  def initialize(sfreq, preset = {})
    super(sfreq, mode: :polyphonic)
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
    @active_voices = {}
  end

  def run(offset)
    t = time(offset)
    events = active_events(t)
    voice_results = []
    events.each do |event|
      local_started = t - event[:started]
      local_stopped = event[:stopped] && event[:stopped] - event[:started]
      if @active_voices[event[:note]].nil?
        @active_voices[event[:note]] = PolyVoice.new(@sampling_frequency, @preset)
      end
      if @active_voices[event[:note]]
        voice_results << @active_voices[event[:note]].run(local_started, local_stopped, frequency(event[:note]), event[:velocity])
      end
    end
    0.3 * voice_results.inject(0) {|sum, result| sum + result}
  end




end
