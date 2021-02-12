#!/usr/bin/env bash
set -ex

main() {
  # nvim
  backup-file ~/.config/nvim
  ln -sf "$PWD/src/nvim" ~/.config/nvim

  # vim
  backup-file ~/.vimrc
  backup-file ~/.vim
  backup-file ~/.gvimrc
  ln -sf "$PWD/src/nvim" ~/.vim
  ln -sf "$PWD/src/nvim/init.vim" ~/.vimrc
  ln -sf "$PWD/src/nvim/ginit.vim" ~/.gvimrc

  mkdir -p \
    ~/.cache/vim \
    ~/.cache/vim/swap \
    ~/.cache/vim/backup \
    ~/.cache/vim/undo \
    ~/.cache/vim-plug

  vim +PlugSync
}

backup-file () {
  if [ -e "$1" ]; then
    mv "$1" "$1.$backup_extension"
  fi
}

# Do this outside the actual backup function so we can ensure the time is
# consistent between calls.
backup_extension="backup.$(date '+%F %T')"

main "$@"
