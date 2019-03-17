#!/bin/bash
ruby $1 | sox -t raw -b 32 -r 44100 -c 1 -e floating-point --endian little - test.wav
