module SequencerDSL

  class Pattern
    attr_reader :sounds, :steps
    def initialize(steps)
      @steps = steps
      @sounds = []
    end

    def run(block)
      instance_eval(&block)
    end

    def drum_pattern(sound, pattern)
      events = []
      @steps.times do |i|
        if pattern.chars[i] == '*'
          events << [i, [:start, 36, 0.5]]
        elsif pattern.chars[i] == '!'
          events << [i, [:start, 36, 1.0]]
        end
      end
      @sounds.push([sound, events])
    end
  end

  def def_pattern(name, steps, &block)
    @patterns ||= {}
    p = Pattern.new(steps)
    p.run(block)
    @patterns[name] = p
  end

  class Song
    def initialize(bpm, patterns)
      @tempo = bpm
      @events = []
      @per_beat = 60.0 / @tempo.to_f
      @per_bar = @per_beat * 4.0
      @per_step = @per_beat / 4.0
      @patterns = patterns
      @latest_time = 0
    end

    def run(block)
      instance_eval(&block)
    end

    def pattern(name, at: 0, repeat: 1, length: nil)
      p = @patterns[name]
      pattern_length = length || p.steps
      start = at.to_f * @per_bar

      p.sounds.each do |sound, events|
        repeat.times do |rep|

          events.each do |event|
            step, data = event
            next if step > pattern_length

            time = start + (rep.to_f * pattern_length.to_f * @per_step.to_f) + step.to_f * @per_step
            @latest_time =  time if time > @latest_time
            type, *rest = data
            @events << [sound, [type, time, *rest]]
          end
        end
      end
    end

    def length
      (@latest_time + 2.0).ceil
    end

    def play
      @events.each do |event|
        instrument, data = event
        instrument.send(*data)
      end
    end
  end


  def song(bpm: 200, &block)
    song = Song.new(bpm, @patterns)
    song.run(block)
    song.play
    song.length
  end
end
