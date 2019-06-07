# The mixing stage

To be able to bring all of these instruments together, we'll need a mixer. A professional mixing desk (often also called a console, interesting, right?), usually consists of a large number of so called channel strips which is where the individual instruments come in. For each channel strip, you can make a huge range of adjustments, of which we'll be looking at a handful.

## Volume control

This one's easy. Different instruments come with different loudnesses. A bass drum is much louder than, say, a harp, just as a function of their physical attributes. The same is true for digitally created sounds. A bass sound that uses a high amount of filter resonance will be louder than other sounds, for example. But that's only the first problem. The second problem is that you usually don't want all sounds to have the same volume. A hihat often needs to be a lot quieter than other drum sounds, for example, because otherwise it would just sound wrong. To tackle that, each channel has a large control, usually called a fader, with which you can control the volume of that channel.

## Equalization

An important part of a mixing engineers work is to make sure the different instruments have enough space of their own in the frequency domain. This is a bit hard to explain with words, so let me show you an image that hopefully explains this a bit more. If too many instruments share a certain portion of the frequency spectrum, much as if you would paint with lots of different colors in one spot, the sound gets mushy, undefined and often just unpleasant, just as the picture you're painting would turn brown-grey-gooey.

To help with that, an Equalizer, often shortened to EQ helps you to shape the frequency spectrum of a sound and thus makes it possible to, for each instrument, emphasize different parts of the spectrum, leading to a cleaner, more defined sound.

## Compression

Compression in this case does not mean data compression. Instead, a compressor changes the dynamic range of a instrument, meaning the difference between quiet and loud sounds. There are many reasons why you would want to do this, but the main reason is that using moderate amounts of compression makes a track sounding more loud.

Compression works by (more or less) making louder sounds more quiet. For that, the compressor uses a curve like this. Additionally, a compressor usually has a way to change the attack and decay times, meaning the the loudness reduction does not happen instantly but is fading in after the loudness reaches a certain threshold and if the sound gets quieter again, the compressor takes a while to dial back the signal reduction. This makes it possible to use a compressor not only for actually compressing the dynamic range but also shaping so-called transients, like the attack of a kick drum. If you use a slightly longer attack on the compressor, the signal is not compressed for that time and only ducked down after it, so that the attack of the drum becomes even more pronounced.

There's a very popular effect specifically in modern dance music that can also be done with the help of a compressor, which is nowadays often abbreviated as "sidechaining" which is weird, because you can sidechain all kinds of effects but if this word is used in isolation, you're probably talking about sidechain compression.

Sidechaining means that instead of letting the actual input signal of the compressor drive the compressor algorhythm, you let it be driven by a different signal, typically a simple kick drum rhythm. Each time the kick drum plays, the compressor kicks into gear and ducks down your original signal.

In our machinery, the "sidechaining" is actuallly gonna be done slightly different by triggering a simple envelope each time the kick drum is played. It is easier to parameterize and more consistent and in a lot of productions, the sidechaining effect is actually done in a similar way now.

## Insert effects

TODO: Do we have inserts? Phaser? Flanger, Chorus?

## Send effects

Send effects send a portion of the channel strip signal to another channel that is specialized in a specific effect. Two things very often used as send effects are Reverb and Delay, both effects to create the illusion of space. Since you probably, for consistency reasons, want these to sound similar for every channel, it makes sense to simply instantiate them once and then use from every channel.

## The main mix

The main mix channel simply gives you the possibiliy to adjust the final volume again, so that the output signal is in a good range and you probably have a sum compressor on it as well, to further reduce the dynamic range.

