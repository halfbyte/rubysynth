##
# Implementation of a linear ADSR envelope generator with a tracking
# value so that envelope restarts don't click
class Adsr
  ##
  # attack time in seconds
  attr_accessor :attack

  ##
  # decay time in seconds
  attr_accessor :decay
  ##
  # sustain level (0.0-1.0)
  attr_accessor :sustain

  ##
  # release time in seconds
  attr_accessor :release

  ##
  # Creates new ADSR envelope
  #
  # attack, decay and release are times in seconds (as float)
  #
  # sustain should be between 0 and 1
  def initialize(attack, decay, sustain, release)
    @value = 0
    @start_value = 0
    @attack = attack
    @decay = decay
    @sustain = sustain
    @release = release
  end

  ##
  # run the envelope.
  #
  # if released is given (should be <= t), the envelope will enter the release stage
  # returns the current value between 0 and 1
  def run(t, released)
    attack_decay = attack + decay
    if !released
      if t < 0.0001 # initialize start value (slightly hacky, but works)
        @start_value = @value
        return @start_value
      end
      if t <= attack # attack
        return @value = linear(@start_value, 1, attack, t)
      end
      if t > attack && t < attack_decay # decay
        return @value = linear(1.0, sustain, decay, t - attack)
      end
      if t >= attack_decay # sustain
        return @value = sustain
      end
    else # release
      if t <= attack # when released in attack phase
        attack_level = linear(@start_value, 1, attack, released)
        return linear(attack_level, 0, release, t - released)
      end
      if t > attack && t < attack_decay # when released in decay phase
        decay_level = linear(1.0, sustain, decay, released - attack)
        return @value = linear(decay_level, 0, release, t - released)
      end
      if t >= attack_decay && t < released + release # normal release
        return @value = linear(sustain, 0, release, t - released)
      end
      if t >= released + released # after release
        return @value = 0.0
      end
    end
  end

  private

  def linear(start, target, length, time)
    (target - start) / length * time + start
  end
end
