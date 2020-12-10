# PC:OS

*Personal Computer Operating System.*

## Requirements

- GNU Bash
- GNU Make
- VirtualBox 6.1 (for installation on virtual machine)
- USB stick (for installation on real machine)
- Git alias `git root` ([`git config --global alias.root 'rev-parse --show-toplevel'`](https://stackoverflow.com/a/957978))


## Get the ISO

Download the Artix ISO as `image.iso`:

```bash
make load
```

Burn the ISO on a USB stick.
**MAKE SURE TO INPUT THE CORRECT DISK!**

```bash
make bur
```

## Setup the VM

Configure the specs of the virtual machine in [/vm/specs](./vm/specs).

- `make build` - Create the VM.
- `make info` - Print info about the VM.
- `make start` - Start the VM.
- `make stop` - Stop the VM.
- `make clean` - Stop the VM.

## Install the Base System

1. Boot into the live image and login.
2. Make sure you have an internet connection (`ping google.com`).
3. Change to `root` with `sudo su`
4. Install the OS:
   ```bash
   curl -L os.davidheresy.de > install
   sh install
   ```
