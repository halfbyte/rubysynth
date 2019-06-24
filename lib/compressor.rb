class EnvelopeDetector # :nodoc:
  def initialize(srate, tc: ms)
    @sample_rate = srate
    @ms = tc
    set_coef()
  end

  def set_coef
    @coef = Math.exp( -1000.0 / ( @ms * @sample_rate) )
  end

  def tc=(tc)
    @ms = tc
    set_coef()
  end

  def run(input, state)
    input + @coef * ( state - input )
  end
end


class AttRelEnvelope # :nodoc:
  def initialize(srate, attack:, release:)
    @attack = EnvelopeDetector.new(srate, tc: attack)
    @release = EnvelopeDetector.new(srate, tc: release)
  end

  def attack=(attack)
    @attack.tc = attack
  end

  def release=(decay)
    @release.tc = decay
  end

  def run(input, state)
    if input > state
      @attack.run( input, state )
    else
      @release.run( input, state )
    end
  end

end

##
# simple compresor
# taken from http://www.musicdsp.org/en/latest/Effects/204-simple-compressor-class-c.html

class Compressor
  DC_OFFSET = 1.0E-25 # :nodoc:
  LOG_2_DB = 8.6858896380650365530225783783321 # :nodoc:
  DB_2_LOG = 0.11512925464970228420089957273422 # :nodoc:
  attr_writer :ratio, :threshold, :window # :nodoc:
  ##
  # Create compressor instance
  #
  # attack is the attack time in ms
  #
  # release is the release time in ms
  #
  # ratio is the compresor ratio
  #
  # threshold is the knee threshold
  def initialize(srate, attack: 10.0, release: 100.0, ratio: 1.0, threshold: 0.0)
    @sample_rate = srate
    @envelope = AttRelEnvelope.new(srate, attack: attack, release: release)
    @env_db = DC_OFFSET
    @ratio = ratio
    @threshold = threshold
  end

  ##
  # set attack
  def attack=(attack)
    @envelope.attack = attack
  end

  ##
  # set release
  def release=(release)
    @envelope.release = release
  end


  ##
  # run compressor
  def run(input)
    rect = input.abs
    rect += DC_OFFSET
    key_db = lin2db(rect)

    over_db = key_db - @threshold
    over_db = 0.0 if over_db < 0.0

    # attack/release
    over_db += DC_OFFSET
    @env_db = @envelope.run(over_db, @env_db)
    over_db = @env_db - DC_OFFSET

    gr = over_db * @ratio - 1.0
    gr = db2lin(gr)
    input * gr
  end

  private

  def lin2db(lin)
    return Math.log( lin ) * LOG_2_DB
  end

  def db2lin(db)
    return Math.exp( db * DB_2_LOG )
  end

end
