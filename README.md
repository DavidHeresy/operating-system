# PC:OS

*Personal Computer Operating System.*

## Requirements

- VirtualBox 6.1 (for installation on virtual machine)

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
