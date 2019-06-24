##
# Emulation of a mixer channel on a mixing desk
# has a built in EQ, compressor and ducker, can run an arbitrary
# number of insert effects and send channels
class MixerChannel < Sound
  ##
  # These params can be automated
  LIVE_PARAMS = [:volume, :eq_low_gain, :eq_high_gain, :eq_mid_gain]
  attr_accessor :preset # :nodoc:

  def live_params # :nodoc:
    LIVE_PARAMS
  end

  ##
  # - source - Source sound generator
  # - insert_effects - Array of effects instances
  # - sends - Array of send values
  # === Parameters
  # - volume - channel volume
  # - eq_low_freq, eq_high_freq - shelving frequencies for equalizer
  # - eq_low_gain, eq_mid_gain, eq_high_gain - Equalizer gains per band
  # - comp_threshold, comp_ratio, comp_attack, comp_release - Compressor params
  # - duck - Duck amount (0-1)
  # - duck attack, duck_release - Ducker envelope params in s
  def initialize(srate, source, insert_effects: [], sends: [], preset: {})
    @source = source
    @insert_effects = insert_effects
    @sends = sends
    @preset = {
      volume: 0.2,
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

  ##
  # Schedule ducking at time t (in seconds)
  def duck(t)
    @ducks << t
    @ducks.sort
  end

  ##
  # returns send portion of output signal for send index
  def send(index)
    @output * (@sends[index] || 0.0)
  end

  ##
  # runs channel
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

  private

  def update_live_params(t)
    @eq.low_gain = get(:eq_low_gain, t)
    @eq.mid_gain = get(:eq_low_gain, t)
    @eq.high_gain = get(:eq_low_gain, t)
  end

  def current_duck(t)
    past = @ducks.select {|duck| duck < t}
    return past.last unless past.empty?
    nil
  end
end
