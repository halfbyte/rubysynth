#!/bin/bash
jekyll build
rsync -avz --delete _site/ web@jan.krutisch.de:/srv/web/ruby-synth.fun/
