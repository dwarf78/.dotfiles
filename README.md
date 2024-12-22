# My dotfiles
This directory containsthe dotfiles for my Arch based system

## Requirements

Ensure you have the following installed on your system

### Git

```
sudo pacman -S git
```

### Stow

```
sudo pacman -S stow
```

### One style of Nerd fonts (ie Firacode)

```
sudo pacman -S ttf-firacode-nerd
```

### Installation

First, checkout the .dotfiles repo in your $HOME directory using git

```
git clone git@github.com/dwarf78/.dotfiles
cd .dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
```
