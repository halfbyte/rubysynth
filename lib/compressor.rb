require 'logger'

class EnvelopeDetector
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


class AttRelEnvelope
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

class Compressor
  DC_OFFSET = 1.0E-25
  LOG_2_DB = 8.6858896380650365530225783783321
  DB_2_LOG = 0.11512925464970228420089957273422
  attr_writer :ratio, :threshold, :window
  def initialize(srate, attack: 10.0, release: 100.0, ratio: 1.0, threshold: 0.0)
    @sample_rate = srate
    @envelope = AttRelEnvelope.new(srate, attack: attack, release: release)
    @env_db = DC_OFFSET
    @ratio = ratio
    @threshold = threshold
  end

  def attack=(attack)
    @envelope.attack = attack
  end

  def release=(release)
    @envelope.release = release
  end

  def lin2db(lin)
    return Math.log( lin ) * LOG_2_DB
  end

  def db2lin(db)
    return Math.exp( db * DB_2_LOG )
  end

  def run(input)
    rect = input.abs
    rect += DC_OFFSET
    key_db = lin2db(rect)
    #LOGGER.info("KEY: #{key_db} - #{@threshold}")


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

end
