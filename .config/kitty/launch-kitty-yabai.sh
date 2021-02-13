#!/usr/bin/env bash

PATH="/Applications/Kitty.app/Contents/MacOS:$PATH"

FOCUSED_WINDOW=$(yabai -m query --windows --window)
FOCUSED_WINDOW_DISPLAY=$(<<< "$FOCUSED_WINDOW" jq '.display')
FOCUSED_WINDOW_ID=$(<<< "$FOCUSED_WINDOW" jq '.id')

yabai -m signal --add \
    action="yabai -m signal --remove sig_kitty_display;
            YABAI_WINDOW_DISPLAY=\$(yabai -m query --windows --window
                $YABAI_WINDOW_ID | jq '.display');
            if ! [[ \$YABAI_WINDOW_DISPLAY == $FOCUSED_WINDOW_DISPLAY ]]; then
                yabai -m window \$YABAI_WINDOW_ID --warp $FOCUSED_WINDOW_ID;
                yabai -m window --focus \$YABAI_WINDOW_ID;
            fi" \
    app=kitty \
    event=window_created \
    label=sig_kitty_display

/Applications/kitty.app/Contents/MacOS/kitty --directory=$HOME --single-instance
