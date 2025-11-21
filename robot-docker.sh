#!/bin/bash
robot --outputdir results \
      --loglevel DEBUG \
      --variable BROWSER:chrome \
      --variable HEADLESS:True \
      tests/
