#!/usr/bin/env bash
set -ex

main() {
  # nvim
  mv ~/.config/nvim ~/.config/nvim.bak || true
  ln -sf "$PWD/src/nvim" ~/.config/nvim

  # vim
  mv ~/.vimrc ~/.vimrc.bak || true
  mv ~/.vim ~/.vim.bak || true
  ln -sf "$PWD/src/nvim" ~/.vim
  ln -sf "$PWD/src/nvim/init.vim" ~/.vimrc

  mkdir -p \
    ~/.cache/vim \
    ~/.cache/vim-plug

  vim +'PlugClean | PlugInstall | PlugUpdate | PlugClean'
}

main "$@"
