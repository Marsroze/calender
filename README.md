# Calender

> **Note**
> this cli-app is implemented in zig `v0.10.1` with zig-clap `v0.6.0`.

**Calender** is a simple and easy-to-use cli application implemented in [zig](https://ziglang.org/).

## Building the project

> **Note:** run the following commands from the root directory.

```bash
> zig build -Drelease-safe
```

the executable will be present under `./zig-out/bin` from the root directory.

## How to use

`usage: calender <flags>`

> **Note**
> both the arguments are optional and month and year are both positive integer with month and year in `mm` and `yyyy` format respectively.

```bash
# calender for only a month 
> calender -m <mm> -y <yyyy> 
# OR
> calender --month <mm> --year <yyyy>

# calender for a whole year
> calender -y <yyyy>
# OR
> calender --year <yyyy>
```
