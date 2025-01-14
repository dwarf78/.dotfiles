# My dotfiles
This directory containsthe dotfiles for my Arch based system

## Requirements

Ensure you have the following installed on your system

### Git

```
sudo pacman -S git
```
```
sudo pacman -S git-lfs
```

### Stow

```
sudo pacman -S stow
```

### One style of Nerd fonts (ie Firacode)


```
sudo pacman -S ttf-firacode-nerd
```

### Apple fonts for GNOME tweaks

```
yay -S apple-fonts
```

```
yay -S nerd-fonts-apple
```

### Starship terminal

```
sudo pacman -S starship
```
Pastel Powerline preset

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

### GNOME Extensions

- Astra Monitor
- Blur my Shell
- Caffeine 
- IP Finder
- Quick Setting Audio Panel
- User Avatar in Quick Settings

### Gnome Tweaks

- SF Pro Regular (Interface Text)
- SF Pro Regular (Document Text)
- SFMono Nerd Font Mono (Monospace Text)

