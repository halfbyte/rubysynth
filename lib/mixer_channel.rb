require_relative 'eq'
require_relative 'compressor'
require_relative 'envelope'
class MixerChannel < Sound
  LIVE_PARAMS = [:volume, :eq_low_gain, :eq_high_gain, :eq_mid_gain]
  LOGGER = Logger.new('logs/mixer-channel.log')
  attr_accessor :preset

  def live_params
    LIVE_PARAMS
  end

  def initialize(srate, source, insert_effects: [], sends: [], preset: {})
    @source = source
    @insert_effects = insert_effects
    @sends = sends
    @preset = {
      volume: 1.0,
      eq_low_freq: 880,
      eq_high_freq: 5000,
      eq_low_gain: 1.0,
      eq_mid_gain: 1.0,
      eq_high_gain: 1.0,
      comp_threshold: -50.0,
      comp_ratio: 0.4,
      comp_attack: 80.0,
      comp_release: 200.0,
      duck: 0.0,
      duck_attack: 0.01,
      duck_release: 0.5
    }.merge(preset)

    super(srate)
    @ducks = []
    @duck_env = Envelope.new(@preset[:duck_attack], @preset[:duck_release])
    @eq = Eq.new(srate, lowfreq: @preset[:eq_low_freq], highfreq: @preset[:eq_high_freq])
    @compressor = Compressor.new(srate, attack: @preset[:comp_attack], release: @preset[:comp_release], ratio: @preset[:comp_ratio], threshold: @preset[:comp_threshold])
    update_live_params(0)
  end

  def duck(t)
    @ducks << t
    @ducks.sort
  end

  def current_duck(t)
    past = @ducks.select {|duck| duck < t}
    return past.last unless past.empty?
    nil
  end

  def send(index)
    @output * (@sends[index] || 1.0)
  end

  def update_live_params(t)
    @eq.lg = get(:eq_low_gain, t)
    @eq.mg = get(:eq_low_gain, t)
    @eq.hg = get(:eq_low_gain, t)
  end

  def run(offset)
    t = time(offset)
    update_live_params(t)
    out = @eq.run(@source.run(offset))
    @insert_effects.each do |effect|
      out = effect.run(out)
    end
    if @preset[:duck] != 0.0
      duck = current_duck(t)
      if duck
        local_duck = t - duck
        out = out * (1.0 - @preset[:duck] * @duck_env.run(local_duck))
      end
    end
    out = @compressor.run(out)
    @output = out * @preset[:volume]
  end
end
