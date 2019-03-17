require 'prime'
require 'pp'

class FixedDelay
  def initialize(size)
    @size = size
    @buf = Array.new(size)
    @idx = 0
    @buf = @buf.map { |e| 0.0 }
  end

  def read(n)
    i = (@idx - n + @size) % @size;
    @buf[i]
  end

  def write(x)
    @buf[@idx] = x
    @idx = (@idx + 1) % @size
  end
end

class Damper
  def initialize(damping)
    @damping = damping
    @delay = 0.0
  end

  def run(x)
    y = x * (1.0-@damping) + @delay * @damping;
    @delay = y
    y
  end
end

class Diffuser
  def initialize(size, coeff)
    @size = size.floor
    @coeff = coeff
    @idx = 0
    @buf = Array.new(@size)
    @buf = @buf.map { |e| 0.0 }
  end

  def run(x)
    w = x - @buf[@idx] * @coeff;
    y = @buf[@idx] + w * @coeff;
    @buf[@idx] = w
    @idx = (@idx + 1) % @size;
    y
  end
end

class GVerb
  FDNORDER = 4

  def initialize(srate, max_room_size:, room_size:, rev_time:, damping:, spread:, input_bandwidth:, early_level:, tail_level:)
    @rate = srate
    @damping = damping
    @max_room_size = max_room_size
    @room_size = room_size
    @rev_time = rev_time
    @early_level = early_level
    @tail_level = tail_level
    @max_delay = @rate * @max_room_size / 340.0
    @largest_delay = @rate * @room_size / 340.0
    @input_bandwidth = input_bandwidth;
    @input_damper = Damper.new(1.0 - @input_bandwidth)


    @fdndels = FDNORDER.times.map do |i|
      FixedDelay.new(@max_delay + 1000)
    end
    @fdngains = Array.new(FDNORDER)
    @fdnlens = Array.new(FDNORDER)

    @fdndamps = FDNORDER.times.map do |i|
      Damper.new(@damping)
    end

    ga = 60.0;
    gt = @rev_time;
    ga = 10.0 ** (-ga / 20.0)
    n = @rate * gt
    @alpha = ga ** (1.0 / n)
    gb = 0.0;
    FDNORDER.times do |i|
      gb = 1.000000*@largest_delay if (i == 0)
      gb = 0.816490*@largest_delay if (i == 1)
      gb = 0.707100*@largest_delay if (i == 2)
      gb = 0.632450*@largest_delay if (i == 3)

      @fdnlens[i] = nearest_prime(gb, 0.5);
      @fdnlens[i] = gb.round;
      @fdngains[i] = -(@alpha ** @fdnlens[i])
    end

    @d = Array.new(FDNORDER)
    @u = Array.new(FDNORDER)
    @f = Array.new(FDNORDER)

    # DIFFUSER SECTION

    diffscale = @fdnlens[3].to_f/(210+159+562+410);
    spread1 = spread.to_f
    spread2 = 3.0*spread

    b = 210
    r = 0.125541
    a = spread1*r
    c = 210+159+a
    cc = c-b
    r = 0.854046
    a = spread2*r
    d = 210+159+562+a
    dd = d-c
    e = 1341-d

    @ldifs = [
      Diffuser.new((diffscale*b),0.75),
      Diffuser.new((diffscale*cc),0.75),
      Diffuser.new((diffscale*dd),0.625),
      Diffuser.new((diffscale*e),0.625)
    ]

    b = 210
    r = -0.568366
    a = spread1*r
    c = 210+159+a
    cc = c-b
    r = -0.126815;
    a = spread2*r
    d = 210+159+562+a
    dd = d-c
    e = 1341-d

    @rdifs = [
      Diffuser.new((diffscale*b),0.75),
      Diffuser.new((diffscale*cc),0.75),
      Diffuser.new((diffscale*dd),0.625),
      Diffuser.new((diffscale*e),0.625)
    ]


    # Tapped delay section */

    @tapdelay = FixedDelay.new(44000)
    @taps = Array.new(FDNORDER)
    @tapgains = Array.new(FDNORDER)

    @taps[0] = 5+0.410*@largest_delay
    @taps[1] = 5+0.300*@largest_delay
    @taps[2] = 5+0.155*@largest_delay
    @taps[3] = 5+0.000*@largest_delay

    FDNORDER.times do |i|
      @tapgains[i] = @alpha ** @taps[i]
    end
  end

  def run(x)
    if x.nan? || x.abs > 100000.0
      x = 0.0
    end

    z = @input_damper.run(x)
    z = @ldifs[0].run(z)
    FDNORDER.times do |i|
      @u[i] = @tapgains[i] * @tapdelay.read(@taps[i])
    end

    @tapdelay.write(z)

    FDNORDER.times do |i|
      @d[i] = @fdndamps[i].run(@fdngains[i] * @fdndels[i].read(@fdnlens[i]))
    end

    sum = 0.0
    sign = 1.0
    FDNORDER.times do |i|
      sum += sign * (@tail_level * @d[i] + @early_level * @u[i])
      sign = -sign
    end

    sum += x* @early_level

    lsum = sum
    rsum = sum

    @f = fdn_matrix(@d)

    FDNORDER.times do |i|
      @fdndels[i].write(@u[i] + @f[i])
    end

    lsum = @ldifs[1].run(lsum)
    lsum = @ldifs[2].run(lsum)
    lsum = @ldifs[3].run(lsum)

    rsum = @rdifs[1].run(rsum)
    rsum = @rdifs[2].run(rsum)
    rsum = @rdifs[3].run(rsum)

    return [lsum, rsum]
  end


  private

  def nearest_prime(n_f, rerror)
    n = n_f.to_i
    return n if Prime.prime?(n)
    # assume n is large enough and n*rerror enough smaller than n */
    bound = n*rerror;
    1.upto(bound) do |k|
      return n+k if Prime.prime?(n+k)
      return n-k if Prime.prime?(n-k)
    end
    return -1
  end

  def fdn_matrix(a)
    b = Array.new(FDNORDER)
    dl0 = a[0]
    dl1 = a[1]
    dl2 = a[2]
    dl3 = a[3]

    b[0] = 0.5*(dl0 + dl1 - dl2 - dl3);
    b[1] = 0.5*(dl0 - dl1 - dl2 + dl3);
    b[2] = 0.5*(-dl0 + dl1 - dl2 + dl3);
    b[3] = 0.5*(dl0 + dl1 + dl2 + dl3);
    b
  end
end
