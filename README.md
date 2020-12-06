# PC:OS

*Personal Computer Operating System.*

## Requirements

- POSIX shell
- GNU Make
- VirtualBox 6.1 (for installation on virtual machine)
- USB stick (for installation on real machine)
- Git alias `git root` ([`git config --global alias.root 'rev-parse --show-toplevel'`](https://stackoverflow.com/a/957978))


## Get the ISO

Download the Artix ISO as `image.iso`:

```bash
make download
```

## Setup the VM

Configure the specs in [/vm/specs](./vm/specs)

Create the vm:

```bash
make build
```

Print info about the vm:

```bash
make info
```

Start the vm:

```bash
make start
```

Stop the vm:

```bash
make stop
```

Delete the vm:

```bash
make clean
```

## Install the Base System

1. Boot into the live image and login.
2. Make sure you have an internet connection (`ping google.com`).
3. Change to `root` with `sudo su`
4. Install the OS:
   ```bash
   curl -L os.davidheresy.de > install
   sh install
   ```
