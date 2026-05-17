# arch-dotfiles

Dotfiles laid out like `$HOME` under `home/`.

```text
home/
  .zshrc
  .gitconfig
  .config/
    nvim/
    kitty/
    lazygit/
    niri/
```

Install symlinks:

```sh
make install
```

Preview:

```sh
make check
```

`arch-setup.sh` is tracked in this repo but is not installed into `$HOME`.
