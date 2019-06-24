##
# Base class for all sound generators and the mixer channels
# Handles events (note on / off) and automation
# Has two modes, polyphonic and monophonic
class Sound
  # Mode, either :monophonic or :polyphonic
  attr_accessor :mode

  # run the generator at offset (samples from song start)
  def run(offset)
    raise "Base Class, should not be called"
  end

  def live_params # :nodoc:
    []
  end

  # this + start time makes it possible to delete events from list
  #
  # define this in your generator implementation if your generator has fixed
  # note lengths not dependent on the note off event
  # (for example one shot drum hits)
  def duration(t=0)
    nil
  end

  # this + end time makes it possible to delete events from list
  #
  # define this in your generator implementation if your generator is dependent
  # on note off events
  def release(t=0)
    nil
  end

  ##
  # create new sound generator instance
  #
  # <tt>super(sfreq, mode: $mode)</tt> should be called from the sound generator
  # implementation initializer.

  def initialize(sfreq, mode: :polyphonic)
    @mode = mode
    @sampling_frequency = sfreq.to_f
    @parameters = {}
    @events = []
    @active_events = {}
    initialize_live_params
    @prepared = false
    @sample_duration = 1.0 / @sampling_frequency
  end

  # create a note on event at time t with note and velocity
  # [t] time in seconds from song start
  # [note] MIDI note
  # [velocity] velocity of note from 0 to 1.0
  def start(t, note = 36, velocity = 1.0)
    @events << [t.to_f, :start, note, velocity]
  end

  # create a note off event at time t with note
  # [t] time in seconds from song start
  # [note] MIDI note
  def stop(t, note = 36)
    @events << [t.to_f, :stop, note, 0]
  end

  ##
  # returns active events at time t
  def active_events(t)
    if mode == :polyphonic
      active_polyphonic_events(t)
    else
      active_monophonic_events(t)
    end
  end


  # sets a parameter to a specific value at a given time.
  # you can interpolate linearly between two points by setting to value A
  # then setting value B at a later point in time with type: linear
  # TODO: implement quadratic interpolation
  #
  # Note: this does no sanity checking, so please make sure you set events
  # in the correct order etc.
  # [parameter] parameter name
  # [time] time in seconds from song start
  # [value] value of the parameter you want to get to
  # [type] either :set or :linear

  def set(parameter, time, value, type: :set)
    @parameters[parameter] ||= []
    @parameters[parameter] << [time, value, type]
    @parameters[parameter].sort_by! { |item| item.first }
  end

  # get the exact parameter value including interpolation
  # [parameter] parameter name
  # [time] time of from where you want the value
  def get(parameter, time)
    return nil if @parameters[parameter].nil?
    return nil if @parameters[parameter].first.first > time
    reverse_list = @parameters[parameter].reverse
    reverse_list.each_with_index do |entry, index|
      return entry[1] if entry.first <= time
      if entry.first >= time && entry[2] == :linear
        if reverse_list[index + 1].nil?
          return nil
        end
        lin_time_start = reverse_list[index + 1][0]
        lin_value_start = reverse_list[index + 1][1]
        value_diff = entry[1] - lin_value_start
        time_diff = entry[0] - lin_time_start
        return value_diff / time_diff * (time - lin_time_start)
      end
    end
  end

  private

  def initialize_live_params
    live_params.each do |p|
      set(p, 0, @preset[p], type: :set)
    end
  end

  def time(offset)
    offset.to_f / @sampling_frequency
  end

  def frequency(note)
    (2.0 ** ((note.to_f - 69.0) / 12.0)) * 440.0
  end

  def prepare
    return if @prepared
    @events.sort_by! { |item| item.first }
    @prepared = true
  end

  def filter_done_events(t)
    return if duration(t).nil? && release(t).nil? # sound subclass needs to implement this to work
    @active_events.reject! do |note, event|
      # one shots with duration
      duration(t) && event[:started] + duration(t) <= t ||
      # stopped with release time
      release(t) && event[:stopped] && event[:stopped] + release(t) <= t
    end
  end

  # returns correct events for a monophonic synth with proper not priority.

  def active_monophonic_events(t)
    active_polyphonic_events(t)
    non_stopped = @active_events.select { |note, event| event[:stopped].nil? }
    unless non_stopped.empty?
      return Hash[[non_stopped.sort_by{|note, event| event[:started] }.last]]
    end
    stopped = @active_events.sort_by{|note, event| event[:stopped]}.last
    if stopped
      Hash[[stopped]]
    else
      {}
    end
  end

  def active_polyphonic_events(t)
    t = t.to_f
    prepare
    @events.each_with_index do |event|
      # let's look at the smallest interval possible
      # pp [t.to_f, t.to_f + (@sample_duration * 2)]
      next if event.first < t
      break if event.first > t + (@sample_duration * 2)
      if event[1] == :start
        @active_events[event[2]] = {started: event[0], velocity: event[3]}
      elsif event[1] == :stop
        @active_events[event[2]][:stopped] = event[0] if @active_events[event[2]]
      end
    end
    filter_done_events(t)
    @active_events
  end
end
