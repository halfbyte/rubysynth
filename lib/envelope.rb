# Attack / Release envelope
class Envelope
  def initialize(a,r)
    @a = a
    @r = r
  end
  def run(t)
    if t > @a + @r
      return 0
    elsif t > @a #release
      return 1 - ((1 / @r) * (t - @a))
    else
      return 1 / @a * t
    end
  end
end
