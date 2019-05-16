class Sound

  attr_accessor :mode

  def initialize()
    @parameters = {}
    @events = []
    @mode = :polyphonic
  end

  # create a note on event at time t with note and velocity
  def start(t, note: 36, velocity: 127)
    @events << [t, :start, note, velocity]
    @events.sort_by! { |item| item.first }
  end

  # create a note off event at time t with note
  def stop(t, note: 36)
    @events << [t, :stop, note, 0]
    @events.sort_by! { |item| item.first }
  end

  # returns active events at time t
  def active_events(t)
    if mode == :polyphonic
      active_polyphonic_events(t)
    else
      active_monophonic_events(t)
    end
  end

  def set(parameter, time, value, type: :set)
    @parameters[parameter] ||= []
    @parameters[parameter] << [time, value, type]
    @parameters[parameter].sort_by! { |item| item.first }
  end

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

  def automate(parameter, type, time, value)
    set(parameter, time, value, type: type)
  end

  private

  def active_monophonic_events(t)
    active = []
    @events.each_with_index do |event|
      if event.first <= t
        if event[1] == :start
          active.map! {|e| e[:stopped] = event.first if e[:stopped].nil?; e }
          active << { started: event.first, note: event[2], velocity: event[3] }
        elsif event[1] == :stop
          active.map! {|e| e[:stopped] = event.first if e[:stopped].nil?; e }
        end
      end
    end
    return active
  end

  def active_polyphonic_events(t)
    active = []
    @events.each_with_index do |event|
      if event.first <= t
        if event[1] == :start
          active.map! {|e| e[:stopped] = event.first if e[:note] == event[2] && e[:stopped].nil?; e }
          active << { started: event.first, note: event[2], velocity: event[3] }
        elsif event[1] == :stop
          active.map! {|e| e[:stopped] = event.first if e[:note] == event[2] && e[:stopped].nil?; e }
        end
      end
    end
    active
  end
end
