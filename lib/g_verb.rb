# Direct port from GVerb
# Source: https://github.com/swh/lv2/blob/master/gverb/gverbdsp.c
# (and other files from that repo)
#
# Here's the original (c) notice from https://github.com/swh/lv2/blob/master/gverb/gverbdsp.c
#
#     Copyright (C) 1999 Juhana Sadeharju
#                    kouhia at nic.funet.fi
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

require 'prime'

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

  def initialize(srate, max_room_size: 120.0, room_size: 50.0, rev_time: 2.0, damping: 0.3, spread: 15.0, input_bandwidth: 1.5, early_level: 0.8, tail_level: 0.5, mix: 0.2)
    @rate = srate
    @damping = damping
    @max_room_size = max_room_size
    @room_size = room_size
    @rev_time = rev_time
    @early_level = early_level
    @tail_level = tail_level
    @mix = mix
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


  # runs a value through the reverb, returns the reverberated signal
  # mixed with the original. Mix Parameter: (0=no reverb, 1=only reverb)
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
    # rsum = sum

    @f = fdn_matrix(@d)

    FDNORDER.times do |i|
      @fdndels[i].write(@u[i] + @f[i])
    end

    lsum = @ldifs[1].run(lsum)
    lsum = @ldifs[2].run(lsum)
    lsum = @ldifs[3].run(lsum)

    # rsum = @rdifs[1].run(rsum)
    # rsum = @rdifs[2].run(rsum)
    # rsum = @rdifs[3].run(rsum)

    lsum = x * (1.0 - @mix) + lsum * @mix
    # rsum = x * (1.0 - mix) + rsum * mix
    return lsum
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
