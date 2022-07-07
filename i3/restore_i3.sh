#!/bin/zsh

for layout in ~/.config/i3/layouts/*; do
  i3-msg "workspace $(basename "$layout" .json); append_layout $layout"
done

(thunderbird &)
(kitty /usr/local/bin/tmux &)
(firefox &)
(notion-app &)

