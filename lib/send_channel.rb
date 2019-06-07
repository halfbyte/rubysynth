require_relative 'eq'

class SendChannel < MixerChannel
  def initialize(srate, insert_effects: [], sends: [], preset: {})
    super(srate, nil, insert_effects: insert_effects, sends: sends, preset: preset)
  end

  def run(offset, input)
    out = @eq.run(input)
    @insert_effects.each do |effect|
      out = effect.run(out)
    end
    @output = out * @preset[:volume]
  end
end
