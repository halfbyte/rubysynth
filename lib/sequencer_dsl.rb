##
# A module that implements a sequencer DSL
# === Usage
#
#  include SequencerDSL
#  def_pattern(:pattern_name, 16) do
#    drum_pattern kickdrum, '*---*---*---*---'
#  end
#
#  my_song = song(bpm: 125) do
#    pattern(:pattern_name, at: 0, repeat: 4)
#  end
#
#  output = my_song.render(44100) do |sample|
#    kickdrum.run(sample)
#  end
#  print output.pack('e*')
#
module SequencerDSL

  P = nil # :nodoc:

  ##
  # The Pattern class is instantiated by the def_pattern helper
  class Pattern
    NOTES=%w(C C# D D# E F F# G G# A A# B) # :nodoc:

    attr_reader :sounds, :steps # :nodoc:
    def initialize(steps) # :nodoc:
      @steps = steps
      @sounds = []
    end

    def run(block) # :nodoc:
      instance_eval(&block)
    end

    ##
    # Define a drum pattern
    # - sound is the sound generator object
    # - pattern is a pattern in the form of a string
    # === Defining patterns
    #
    #   drum_pattern bass_drum, '*---*---*---!---'
    #
    # - <tt>*</tt> represents a normal drum hit (velocity: 0.5)
    # - <tt>!</tt> represents an accented drum hit (velocity 1.0)
    # - <tt>-</tt> represents a pause (no hit)

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

    def str2note(str) # :nodoc:
      match = str.upcase.strip.match(/([ABCDEFGH]#?)(-?\d)/)
      return nil unless match
      octave = match[2].to_i + 2
      note = NOTES.index(match[1])
      if note >= 0 && octave > 0 && octave < 10
        return 12 * octave + note
      end
    end

    ##
    # Define a note pattern
    # [sound]   sound generator base class
    # [pattern] a note pattern
    #
    # === Defining a note pattern
    #
    #  note_pattern monosynth, [
    #    ['C4, D#4, G4', 2], P, P, P,
    #    P, P, P, P,
    #    P, P, P, P,
    #    P, P, P, P
    #  ]
    #
    # - <tt>P</tt> is a pause
    # - a note step in the pattern is an array containing the note and the
    #   length of the note in steps
    # - a note is a note name as a string, which consists of the note and the
    #   octave. To play chords, concatenate notes with commas
    def note_pattern(sound, pattern)
      events = []
      @steps.times do |i|
        if pattern[i]
          notes, len = pattern[i]
          notes.split(',').each do |note|
            note_num = str2note(note)
            events << [i, [:start, note_num, 1.0]]
            events << [i + len, [:stop, note_num]]
          end
        end
      end
      @sounds.push([sound, events])
    end
  end

  ##
  # Define a note pattern
  def def_pattern(name, steps, &block)
    @patterns ||= {}
    p = Pattern.new(steps)
    p.run(block)
    @patterns[name] = p
  end

  ##
  # A
  class Song
    attr_reader :events, :per_bar, :per_beat # :nodoc:
    def initialize(bpm, patterns) # :nodoc:
      @tempo = bpm
      @events = []
      @per_beat = 60.0 / @tempo.to_f
      @per_bar = @per_beat * 4.0
      @per_step = @per_beat / 4.0
      @patterns = patterns
      @latest_time = 0
    end

    def run(block) # :nodoc:
      instance_eval(&block)
    end

    ##
    # inserts a pattern into the song
    # [name] pattern needs to be defined by <tt>def_pattern</tt>
    # [at] Position in bars to insert the pattern to
    # [repeat] number of times the pattern should repeat
    # [length] if you want to only use part of the pattern
    #

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

    ##
    # Returns the length of the song in seconds plus 2 seconds to allow for
    # reverb tails etc.
    def length
      (@latest_time + 2.0).ceil
    end

    ##
    # Sends all scheduled events to the instruments
    def play
      @events.each do |event|
        instrument, data = event
        instrument.send(*data)
      end
    end
  end

  ##
  # Define a song in the given tempo (in BPM)
  # using the Song#pattern method

  def song(bpm: 120, &block)
    song = Song.new(bpm, @patterns)
    song.run(block)
    song.play
    # File.open("DEBUG.txt", 'wb') do |f|
    #   f.print song.events.inspect
    # end
    song
  end
  ##
  # render the song
  # the actual rendering needs to be done
  # manually in the block passed
  # start & length in bars
  # block gets an offset in samples it should render
  def render(sfreq, start=0, len=nil)
    start_time = start * @per_bar
    end_time = len ? start_time + len * @per_bar : length
    start_sample = (sfreq * start_time).floor
    end_sample = (sfreq * end_time).ceil
    sample = start_sample
    sample_len = end_sample - start_sample
    output = Array.new(sample_len)
    loop do
      output[sample - start_sample] = yield sample
      break if sample > end_sample
      sample += 1
    end
    output
  end
end
