# Introduction

Sonic Pi is a wonderful piece of software. It can teach both the basics of programming and the basics of music making while sounding quite professional. That's due to the great foundation Sonic Pi is based on: Supercollider is a system specifically built for live coding and has been under continuous development since 1996!

But today we're going to leave those comfortable foundations behind and going to try to recreate at least parts of it with pure ruby. The idea here is that we can use an expressive and easy to read language like ruby and show how to implement stuff that is usually written in C or C++, ideally with all possible optimizations done, which doesn't necessarily makes for the most readable code.

We're going to do this in three parts. At first we're going to take a look at how to generate typical synthesizer sounds, including some drum sounds. Next, we're going to figure out how to turn these into music by looking at sequencing. Last but not least we'll add some effects that will bring the sound to the pro level, something you may have noticed also happening in the SonicPi demo.

I'll show a lot of code in this talk, but don't concentrate too much on it, though, it's all available for you to study afterwards. And, unfortunately, since we have a very full todo list for the rest of this talk, I need to glance over a couple of things I would have loved to talk about in detail - But fear not, the content is all there, if only in written form. If you go to ruby-synth.fun, you'll find a lot of additional material there, including, of course, all the code examples.

