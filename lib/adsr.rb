# Implementation of a linear ADSR envelope generator with a tracking
# value so that envelope restarts don't click
class Adsr
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
    (target - start) / length * time + start
  end

  def run(t, released)
    if !released
      if t < 0.0001 # initialize start value (slightly hacky, but works)
        @start_value = @value
        return @start_value
      end
      if t <= a # attack
        return @value = linear(@start_value, 1, a, t)
      end
      if t > a && t < (a + d) # decay
        return @value = linear(1.0, s, d, t - a)
      end
      if t >= a + d # sustain
        return @value = s
      end
    else # release
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
