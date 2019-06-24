##
# Simple Attack / Release envelope
class Envelope
  ##
  # attack time in seconds
  attr_accessor :attack

  ##
  # release time in seconds
  attr_accessor :release
  ##
  # create new attack/release envelope
  def initialize(attack,release)
    @attack = attack
    @release = release
  end
  ##
  # run the attack/release envelope
  # You can override attack and decay
  def run(t, a=@attack, r=@release)
    @a = a
    @r = r
    if t > @a + @r
      return 0
    elsif t > @a #release
      return 1 - ((1 / @r) * (t - @a))
    else # attack
      return 1 / @a * t
    end
  end
end
