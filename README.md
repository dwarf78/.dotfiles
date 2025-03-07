# My dotfiles
This directory contains the dotfiles for my Arch-based system

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

### Pandoc for markdown conversion
```
sudo pacman -S pandoc
``` 
Templates available in the .dotfile:

- eisvogel.latex  
- pandoc-scholar.latex (esthetic and preferred)  

### One style of Nerd fonts (ie Firacode)

```
sudo pacman -S ttf-firacode-nerd
```

### Apple fonts for GNOME tweaks

```
yay -S nerd-fonts-apple
```

### Starship terminal

```
sudo pacman -S starship
```
 - **Pastel Powerline** preset
### Fastfetch

```
sudo pacman -S fastfetch
```
### GoogleDriveFS 
Package to access via CLI GoogleDrive

- Need to create Google ID and API access
```
yay -S google-drive-ocamlfuse
```
- Need gfuse bin script
- Need gfuse.deskop to autostart gfuse

## Installation

First, checkout the .dotfiles repo in your $HOME directory using git

```
git clone git@github.com/dwarf78/.dotfiles
cd .dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
```

## GNOME Extensions
- AppIndicator and KStatusNotfierItem Support
- Astra Monitor
- Blur my Shell
- GPU profile selector (only for laptop with discrete GPU)
- Caffeine 
- IP Finder
- Native Window Placement
- Places Status Indicator
- Quick Setting Audio Panel
- Removable Drive Menu
- User Avatar in Quick Settings

## Gnome Tweaks

- SF Pro Regular (Interface Text)
- SF Pro Regular (Document Text)
- SFMono Nerd Font Mono (Monospace Text)

