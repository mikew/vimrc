#!/usr/bin/env bash
set -ex

main() {
  # nvim
  mv ~/.config/nvim ~/.config/nvim.bak || true
  ln -sf "$PWD/src/nvim" ~/.config/nvim

  # vim
  mv ~/.vimrc ~/.vimrc.bak || true
  mv ~/.vim ~/.vim.bak || true
  mv ~/.gvimrc ~/.gvimrc.bak || true
  ln -sf "$PWD/src/nvim" ~/.vim
  ln -sf "$PWD/src/nvim/init.vim" ~/.vimrc
  ln -sf "$PWD/src/nvim/ginit.vim" ~/.gvimrc

  mkdir -p \
    ~/.cache/vim \
    ~/.cache/vim-plug

  vim +PlugSync
}

main "$@"
