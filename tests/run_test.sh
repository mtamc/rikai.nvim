#!/bin/bash
cd "$(dirname "$0")"
nvim --headless --noplugin -u NONE -c "lua dofile('test_dict.lua')" -c "qa!"
