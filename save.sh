#!/bin/bash
ruby -Ilib $1 | sox -t raw -b 32 -r 44100 -c 1 -e floating-point --endian little - -t wav -b 16 $2
