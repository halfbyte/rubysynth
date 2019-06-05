require 'logger'

# Implementation of a linear ADSR envelope generator with a tracking
# value so that envelope restarts don't click
class Adsr
  LOGGER = Logger.new("logs/adsr.log")
  attr_accessor :a, :d, :s, :r

  def initialize(a, d, s, r)
    @value = 0
    @start_value = 0
    @a = a
    @d = d
    @s = s
    @r = r
  end

  def linear(start, target, length, time)
    range = target - start
    range / length * time + start
  end

  def run(t, released)
    # LOGGER.info("#{t} -> #{released}")
    if !released
      # attack
      # initialize start value
      if t < 0.0001
        @start_value = @value
        return @start_value
      end
      if t <= a
        return @value = linear(@start_value, 1, a, t)
      end
      # decay
      if t > a && t < (a + d)
        return @value = linear(1.0, s, d, t - a)
      end
      # sustain
      if t >= a + d
        return @value = s
      end
    else # (early) release
      if t <= a # when released in attack phase
        attack_level = linear(@start_value, 1, a, releases)
        return linear(attack_level, 0, t - released)
      end
      if t > a && t < (a + d) # when released in decay phase
        decay_level = linear(1.0, s, d, released - a)
        return @value = linear(decay_level, 0, r, t - released)
      end
      if t >= a + d && t < released + r # normal release
        return @value = linear(s, 0, r, t - released)
      end
      if t >= released + r # after release
        return @value = 0.0
      end
    end
  end
end
