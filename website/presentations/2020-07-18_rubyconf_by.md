class: center, middle, title

# Ruby patterns for contempory dance music
## A presentation for RubyConfOnlineBY 2020

## Jan 'half/byte' Krutisch
## @halfbyte
---
class: center, middle, title

# Ruby patterns for contempory dance music
## A presentation for RubyConfOnlineBY 2020

## Jan 'half/byte' Krutisch
## @halfbyte

---
class: center, middle, depfu, contain
background-image: url(/images/depfu-left-blue.png)
---
class: contain
background-image: url(/images/depfu_engine_update.png)
---
class: center, middle, subtitle
# A warning
---
### Don't try to understand the code examples!

Note: This not meant as an insult. I'm just aware that it's a lot of code on very different subjects and it will be next to impossible to understand it during the presentation. Instead, go to [rubysynth.fun](https://rubysynth.fun) for more info.

I'm providing the code fragments here to give you a sense of how much (or rather: how little) code is necessary and how the code looks in general. More of a teaser or taste bite than actually explaining how a library works.

The reason I have (in contrast to what every one tells you to do) a looong text on one slide is that I want to warn people who click through these slides later on.

(here I used to have a joke that does not work at all for online conferences. sorry.)
---
class: center, middle, subtitle
# Music
---
class: fullscreen-video, center
<video controls>
  <source src="images/sonic_pi.av1.mp4" type="video/mp4">
  <source src="images/sonic_pi.mp4" type="video/mp4">
</video>
???
**00:01**
---
class: center, middle
# SonicPi

## by Sam Aaron
## [sonic-pi.net](https://sonic-pi.net/)
## [patreon.com/samaaron](https://patreon.com/samaaron)
---
class: center, middle
# Let's dig deeper
???
**00:03**
---
class: center, middle
# Pure Ruby
---
class: center
```ruby
SAMPLING_FREQUENCY=44100
FREQUENCY=440

in_cycle = 0
out = SAMPLING_FREQUENCY.times.map do
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output * 0.5
end
WaveWriter.write_if_name_given(out)
```

<audio src="/samples/square.wav" data-player="scope-full"></audio>
???
This allows me to play this sound from the browser
---
class: center, middle
# But how does it work?

---
class: center, middle

# Like, how does it really work.

---
class: center, middle

![the flow of audio](/images/audio_flow.svg)

???
- Electrical signal from Computer to Loudspeakers
- Soundwaves from Loudspeaker to Ear (Membrane moved by electromagnet pushes air molecules)
- Ear with incredibly complex mechanism turns soundwaves into "sort of" electrical signal (nerve impulses)
- Brain turns it into music
- Going to focus on one specific part
---
class: center, middle
# But how
![a laptop icon](/images/laptop.svg)

---
class: center, middle

# Digital Data > Electrical current
## Digital to Analog Converter (DAC)
![photo of a DAC chip](/images/dac.jpg)
---
class: center, middle
# Digital to Analog challenges
![fit](/images/digital_analog.png)

<math>
  <mrow>
    <msub><mi>F</mi> <mi>max</mi></msub> = <mfrac><msub><mi>F</mi><mi>sample</mi></mi></msub>2</mfrac>
  </mrow>
</math>

???
- Two problems:
  - Sampling frequency
    - Nyquist shannon, 2 * Fmax
    - ~ 40 kHz is enough, 20 kHz humans plus headroom
  - Sampling resolution
    - Enough is enough
---
class: center, middle, subtitle
# A Ruby Synth

---
```ruby
SAMPLING_FREQUENCY=44100
FREQUENCY=440

in_cycle = 0
samples = SAMPLING_FREQUENCY.times.map do
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output *= 0.5
end
WaveWriter.write_if_name_given(out)
```

---
class: center, middle
# A squarewave at 440 Hz

<audio src="/samples/square.wav" data-player="scope-full"></audio>

---
class: center, middle
# Why 440 Hz?
???
**00:06**

---

class: center, middle
# 440 Hz = Concert Pitch
# A above middle C

---
class: center, middle
# Should it be 432 Hz?
---
class: center, middle
# Western notation
---
class: center, middle
![an image explaining western notation](/images/notes.png)
---
class: center, middle

<math>
  <mrow>
    <msup><mn>2</mn><mfrac><mrow><mi>n</mi><mo>-</mo><mn>69</mn></mrow><mn>12</mn></mfrac></msup><mo>*</mo><mn>440</mn><mu>Hz</mu>
  </mrow>
</math>

n = MIDI note (0-127)

0 = very low C

60 = middle C

69 = concert pitch A

---
class: center, middle
# A squarewave at 440 Hz

<audio src="/samples/square.wav" data-player="fft-full"></audio>
---
class: center, middle
# Yes I know it sounds horrible
---
class: center, middle, subtitle
# Sculpting a sound
???
**00:08**
---
class: center, middle
# Subtractive Synthesis

---
class: center, middle
1. Start with high harmonic content
2. Filter down
---
class: center, middle
![A photo of micheangelo's David](/images/david_von_michelangelo.jpg)
???
A bit like the famous saying of how micheangelo created his famous sculptures: Start with a full block of marble
and then carefully remove everything that doesn't look like David.
---
class: center, middle

# So what's a filter?

---
class: center, middle
# State Variable Filter
![](/images/StateVarBlock.gif)

---

# State Variable Filter
```ruby
def run(input, frequency, q, type: :lowpass)
  # derived parameters
  q1 = 1.0 / q.to_f
  f1 = 2 * Math::PI * frequency / @sampling_frequency

  # calculate filters
  lowpass = @delay_2 + f1 * @delay_1
  highpass = input - lowpass - q1 * @delay_1
  bandpass = f1 * highpass + @delay_1
  notch = highpass + lowpass

  # store delays
  @delay_1 = bandpass
  @delay_2 = lowpass
  # [...]
end
```
---
class: center, middle
# Let's make some noise
```ruby
out = SAMPLING_FREQUENCY.times.map do
  output = rand() * 2 - 1
  output *= 0.3
end
```
<audio src="/samples/noise.wav" data-player="fft-full"></audio>

???
For the next examples, we're going to use white noise as the sound source, because it demonstrates the
filters much better

---

class: center, middle
# Lowpass
![A lowpass frequency response diagram with resonance](/images/lowpass.png)
---
class: center, middle
# Lowpass (2000 Hz)
<audio src="/samples/lowpass_filtered.wav" data-player="fft-full"></audio>
---
class: center, middle
# Highpass
![A lowpass frequency response diagram with resonance](/images/highpass.png)
---
class: center, middle
# Highpass (2000 Hz)
<audio src="/samples/highpass_filtered.wav" data-player="fft-full"></audio>
---
class: center, middle
# Something's still wrong
---
class: center, middle
# Piano
<audio src="/samples/piano_long.wav" data-player="fft-full"></audio>
---
class: center, middle
# Variance over time
---
class: center, middle
# Envelopes to the rescue
---
class: center, middle
# Not this
![Icon of an envelope](/images/envelope-font-awesome.svg)
---
class: center, middle
# This!
<video controls>
  <source src="images/adsr.av1.mp4" type="video/mp4">
  <source src="images/adsr.mp4" type="video/mp4">
</video>
---
class: very-small-code
```ruby
def run(t, released)
  attack_decay = attack + decay
  if !released
    if t < 0.0001 # initialize start value (slightly hacky, but works)
      @start_value = @value
      return @start_value
    end
    if t <= attack # attack
      return @value = linear(@start_value, 1, attack, t)
    end
    if t > attack && t < attack_decay # decay
      return @value = linear(1.0, sustain, decay, t - attack)
    end
    if t >= attack + decay # sustain
      return @value = sustain
    end
  else # release
    if released <= attack # when released in attack phase
      attack_level = linear(@start_value, 1, attack, released)
      return [linear(attack_level, 0, release, t - released), 0].max
    end
    if released > attack && released <= attack_decay # when released in decay phase
      decay_level = linear(1.0, sustain, decay, released - attack)
      return @value = [linear(decay_level, 0, release, t - released), 0].max
    end
    if released > attack_decay  # normal release
      return @value = [linear(sustain, 0, release, t - released), 0].max
    end
  end
  0.0
end

private

def linear(start, target, length, time)
  return start if time == 0
  return target if length == 0
  (target - start) / length * time + start
end

```
---
class: center, middle
# Shape everything!
---
class: center, middle
# Volume / Amplitude
``` ruby
# [...]
env = Adsr.new(0.001, 0.2, 0.5, 0.2)
t = i.to_f / SAMPLING_FREQUENCY.to_f
stopped = t >= 0.5 ? 0.5 : nil
output *= 0.3 * env.run(t, stopped)
```
---

class: center, middle
# Volume / Amplitude
<audio src="/samples/amp_env.wav" data-player="scope-full"></audio>
---
class: center, middle
# Filter Frequency
``` ruby
# [...]
filter_env = Adsr.new(0.01, 0.1, 0.1, 0.1)
t = i.to_f / SAMPLING_FREQUENCY.to_f
stopped = t >= 0.5 ? 0.5 : nil
output = filter.run(output, 500.0 + (8000.0 * filter_env.run(t, stopped)), 1)
```
---
class: center, middle
# Filter Frequency
<audio src="/samples/filter_env.wav" data-player="fft-full"></audio>
---
class: center, middle
# Pitch
``` ruby
# [...]
pitch_env = Adsr.new(0.01, 0.2, 0.0, 0.0)
t = i.to_f / SAMPLING_FREQUENCY.to_f
stopped = t >= 0.5 ? 0.5 : nil
period = SAMPLING_FREQUENCY / (FREQUENCY.to_f * ((0.5 * pitch_env.run(t, stopped)) + 1))
```
---
class: center, middle
# Pitch
<audio src="/samples/pitch_env.wav" data-player="fft-full"></audio>

---
class: center, middle, subtitle
# Drums
???
**00:13**
---
class: center, middle, frame-image
# Snare drum
![drawing of a snare drum](/images/snaredrum.png)

<audio src="/samples/real_snare.wav" data-player="scope-full"></audio>
???
---
class: center, middle, frame-image
# Snare drum
1. Head
2. Body
3. Snare

---
class: center, middle, small-code

# Head and Body

```ruby
SAMPLING_FREQUENCY=44100
FREQUENCY=110

filter = SynthBlocks::Core::StateVariableFilter.new(SAMPLING_FREQUENCY)
amp_env = SynthBlocks::Mod::Adsr.new(0.001, 0.1, 0.5, 0.2)
filter_env = SynthBlocks::Mod::Adsr.new(0.01, 0.025, 0.1, 0.1)
pitch_env = SynthBlocks::Mod::Adsr.new(0.01, 0.03, 0.0, 0.0)
in_cycle = 0
out = SAMPLING_FREQUENCY.times.map do |s|
  t  = s.to_f / SAMPLING_FREQUENCY.to_f
  stopped = t >= 0.15 ? 0.15 : nil
  period = SAMPLING_FREQUENCY / (FREQUENCY.to_f * ((2 * pitch_env.run(t, stopped)) + 1))
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output = filter.run(output, 200.0 + (2000.0 * filter_env.run(t, stopped)), 1)
  output *= 0.3 * amp_env.run(t, stopped)
end
```
---
class: center, middle

# Head and Body
<audio src="/samples/pitch_env_drum.wav" data-player="scope-full"></audio>

---
class: center, middle
# Snare

```ruby
SAMPLING_FREQUENCY=44100

amp_env = SynthBlocks::Mod::Adsr.new(0.001, 0.1, 0.5, 0.2)
out = SAMPLING_FREQUENCY.times.map do |s|
  t  = s.to_f / SAMPLING_FREQUENCY.to_f
  stopped = t >= 0.15 ? 0.15 : nil
  output = 0.3 * (rand() * 2) - 1
  output *= 0.3 * amp_env.run(t, stopped)
end
```
---
class: center, middle
# Snare

<audio src="/samples/snare_only.wav" data-player="scope-full"></audio>

---
class: center, middle

# All together
<audio src="/samples/manual_snare.wav" data-player="scope-full"></audio>

---
class: center, middle
# Drum beats go like...
<audio src="/samples/drums.wav" data-player="scope-full"></audio>
---

class: center, middle, subtitle
# Sound → Music
---
class: center, middle
# Sequencing sounds
???
**00:18**
---
class: center, middle
# Beats, bars and s\*\*t
---
class: center, middle
# Measure of 4 / 4
---
class: center, middle
# 1, 2, 3, 4
## (4 beats in a bar)
## (beat == 1/4 note)
(yes, music counts from 1 - yes, that confuses me)
---
class: center, middle
# A bar
![](/images/beats_and_bars.png)
---
class: center, middle
# Step sequencer
![](/images/roland_808.jpg)
---
class: center, middle
# Tempo
## BPM (Beats per minute)
## (= Quarter notes per minute)
---
class: center, middle
# Sequencer maths
``` ruby
BPM = 120
beat_length_in_seconds = 60 / BPM # = 0.5s
bar_length = beat_length_in_seconds * 4 # = 2s
sixteenth_note_length = beat_length_in_seconds / 4 # = 0.125s

```
---
class: center, middle
# Notes > Patterns > Songs
![A screenshot of ableton live](/images/notes_patterns_songs.png)
---
class: center, middle
# Notes > Patterns > Songs
![An image showing patterns and songs](/images/pattern_song.png)
---
class: center, middle
# Let's build a DSL for that
---
class: center, middle
# Drums
``` ruby
def_pattern(:drums_full, 16) do
  drum_pattern kick_drum,   '*---*---*---*---'
  drum_pattern snare_drum,  '----*-------*---'
  drum_pattern hihat,       '--*---*---*---*-'
end
```
---
class: center, middle
# Notes
``` ruby
def_pattern(:bassline, 16) do
  note_pattern polysynth, [
    ['C2,D#3,G3', 4], P, P, P,
    P, P, P, P,
    ['C#2,E3,G#3', 6], P, P, P,
    P, P, P, P
  ]
end

```
---
class: center, middle
# A song

``` ruby
length = song(bpm: 115) do
  pattern(:drums_full, at: 0, repeat: 1)
  pattern(:drums_full, at: 2, repeat: 2)
  pattern(:bassline, at: 0, repeat: 4)
  pattern(:chord, at: 0, repeat: 4)
end
```
---
class: center, middle
# A song
<audio src="/samples/simple_song.wav" data-player="scope-full"></audio>
---
class: center, middle, subtitle
# Mixing
???
**00:23**
---
class: center, middle
# Mixer / Mixing Desk / Console
![Blurry image of a large mixing desk](/images/mixing_desk.jpg)
---
class: center, middle
![A diagram explaining the mixer structure](/images/mixer.png)
???
- Each instrument has it's own channel
- Each channel can modify the sound in various ways
- Send channels are used to put sound modifications (called effects) on more than one channel at once.
---
class: center, middle
# Just one example
---
class: center, middle
# Delay (Echo)
![visualisation of a delay effect](/images/delay.png)
---
class: center, middle
# Delay (Echo)
---
class: center, middle
# Ring Buffer with feedback
---

``` ruby
def initialize(sample_rate, time)
  @buffer = Array.new((sample_rate.to_f * time).floor)
  @pointer = 0
end

def run(input, mix, feedback = 0.4)
  old_pointer = @pointer
  @pointer = (@pointer + 1) % @buffer.length
  delayed = (@buffer[@pointer] || 0.0)
  if block_given?
    delayed = yield delayed
  end
  @buffer[old_pointer] = input + (feedback * delayed)
  input * (1.0 - mix) + delayed * mix
end
```
---
class: center, middle
# Delay (Echo)

<audio src="/samples/delay.wav" data-player="scope-full"></audio>
---
class: center, middle, subtitle

# Let's put it all together
---
class: fullscreen-video, center
<video controls>
  <source src="images/full_song.av1.mp4" type="video/mp4">
  <source src="images/full_song.mp4" type="video/mp4">
</video>

???
**00:28**
---
class: subtitle, middle, center
# ❤️ Thank you ❤️
## [rubysynth.fun](http://rubysynth.fun)

## 🎹 ✏️
## @halfbyte - [halfbyte.org](https://halfbyte.org)
## depfu.com


---
# Image Sources

(All taken from Wikimedia Commons)

- [DAC chip](https://commons.wikimedia.org/wiki/File:CirrusLogicCS4282-AB.jpg)
- <a href="https://commons.wikimedia.org/wiki/File:Snare_drum_(line_art)_(PSF_S-860001_(cropped)).png">Snare drum</a>
- [Mixing Desk](https://commons.wikimedia.org/wiki/File:Image_of_a_mixing_desk_2014-02-16_00-50.jpg)
- [David of Michelangelo](https://commons.wikimedia.org/wiki/File:David_von_Michelangelo.jpg?uselang=en)
- <a href="https://commons.wikimedia.org/wiki/File:Roland_TR-808_(large).jpg">Roland 808</a>
