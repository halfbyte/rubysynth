##t
# Channel subclass specifically for SendChannels
class SendChannel < MixerChannel
  ##
  # creates new send channel. See MixerChannel#new for parameters
  def initialize(srate, insert_effects: [], sends: [], preset: {})
    super(srate, nil, insert_effects: insert_effects, sends: sends, preset: preset)
  end

  ##
  # run the send channel
  def run(offset, input)
    out = @eq.run(input)
    @insert_effects.each do |effect|
      out = effect.run(out)
    end
    @output = out * @preset[:volume]
  end
end
