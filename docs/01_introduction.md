# Introduction

We'll start this off with a short demonstration of a software called SonicPi, which allows you to live code music:

<video src="../presentation/images/sonic_pi.ogv" controls></video>

Sonic Pi is a wonderful piece of software. It can teach both the basics of programming and the basics of music making while sounding quite professional. That's due to the great foundation Sonic Pi is based on: Supercollider is a system specifically built for live coding and has been under continuous development since 1996!

But today we're going to leave those comfortable foundations behind and going to try to recreate at least parts of it with pure ruby. The idea here is that we can use an expressive and easy to read language like ruby and show how to implement stuff that is usually written in C or C++, with lots of performance optimizations, which doesn't necessarily makes for the most readable code.

We're going to do this in three parts. At first we're going to take a look at how to generate typical synthesizer sounds, including some drum sounds. Next, we're going to figure out how to turn these into music by looking at sequencing (or, in old school terms, arranging). Last but not least we'll add some effects that will bring the sound to the pro level.

I'll show a lot of code in this talk, but don't concentrate too much on it, though, it's all available for you to study afterwards. And, unfortunately, since we have a very full todo list for the rest of this talk, I need to glance over a couple of things I would have loved to talk about in detail - But fear not, the content is all there, if only in written form. If you go to ruby-synth.fun, you'll find a lot of additional material there, including, of course, all the code examples.

## Making noise with Ruby

Ruby doesn't have a simple, integrated way of outputting sound directly to your computer's soundcard. While there may be libraries, I opted to use the power of Unix and leverage a tool called SoX, (short for "Sound eXchange"), which is essentially the swiss army knife of audio file conversion. It's been around for ages, I even used it back when I still had my AMIGA computer at the end of the 90's. Originally conceived by Lance Norskog, and then maintained by Chris Bagwell, it has thousands of contributors and is a great example for a long running open source project that does one thing and does it well. By playing around with Ruby's quirky `Array#pack` method and SoX's command line switches, I came up with the following snippet to make ruby output a binary stream of 32 bit, little endian float values:

```ruby
SAMPLING_FREQUENCY=44100
FREQUENCY=440

in_cycle = 0
samples = SAMPLING_FREQUENCY.times.map do
  period = SAMPLING_FREQUENCY / FREQUENCY.to_f
  output = in_cycle > 0.5 ? -1.0 : 1.0
  in_cycle = (in_cycle + (1.0 / period)) % 1.0
  output * 0.5
end
print samples.pack('e*')
```
we then can use the following bash script that utilizes SoX's `play` command to pipe the output of the ruby script to your soundcard:

```bash
#!/bin/bash
# play.sh
ruby -Ilib $1 | play -t raw -b 32 -r 44100 -c 1 \
  -e floating-point --endian little -
```

```bash
$ ./play.sh examples/square_wave.rb
```

If, instead of sending the data to our soundcard, we want to save it to a soundfile, to, for example, play the file from a webpage (how very self referential of me, right?), we can use the following snippet and invocation:

```bash
#!/bin/bash
# save.sh
ruby -Ilib $1 | sox -t raw -b 32 -r 44100 -c 1 \
  -e floating-point --endian little - -t wav -b 16 $2
```

```bash
$ ./save.sh examples/square_wave.rb square_wave.wav
```

If you want to try this out yourself, you need to [clone the repo](https://github.com/halfbyte/rubysynth) and install SoX. I'm pretty sure this will work on Windows with either something like Cygwin or WSL, on any unix-ish system like Linux or MacOS, this should work fine. On Linux, SoX should be available from your package manager, on Mac, you can use Homebrew to install it.

