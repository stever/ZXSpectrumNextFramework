# ZXSpectrumNextFramework

A simple assembly framework for the ZX Spectrum Next.

See the [original blog post](https://lemmings.info/zx-spectrum-next-framework-part-1/) for more information.

## Getting Started

Note that this fork uses Linux paths and tools. If you are using Windows, you will need to adapt the commands accordingly.

Firstly, obtain CSpect from [here](https://mdf200.itch.io/cspect) and unpack it to `./bin` so that `CSpect.exe` is located at `./bin/CSpect.exe`.

You'll also need `sjasmplus` on your PATH. Install guide is [here](https://github.com/z00m128/sjasmplus/blob/master/INSTALL.md).

On Linux the following could be used to build and install it:

```bash
mkdir ~/build
cd ~/build/
git clone --recursive -j8 https://github.com/z00m128/sjasmplus.git
cd sjasmplus/
make clean
make
sudo make install
```

Once that is done you should be able to open up the folder in Visual Studio Code then build & run the example using `Ctrl+Shift+B`.

## Using the Debugger

The source file `framework.asm` contains instructions at the end to automatically run the newly built `.nex` file in CSpect, if it builds successfully. This is for convenience, but if you want to use the debugger you could use the other commented-out line there which simply runs CSpect without loading a file. Then you can start the debugger in Visual Studio Code which will load the `.nex` file and stop at the start address.
