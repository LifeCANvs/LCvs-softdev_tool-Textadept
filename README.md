# Textadept

Textadept is a fast, minimalist, and remarkably extensible cross-platform text editor for
programmers. Written in a combination of C, C++, and [Lua][] and relentlessly optimized for
speed and minimalism for more than 12 years, Textadept is an ideal editor for programmers who
want endless extensibility without sacrificing speed and disk space, and without succumbing to
code bloat and a superabundance of features. The application has both a graphical user interface
(GUI) version that runs in a desktop environment, and a terminal version that runs within a
terminal emulator.

![Linux](https://orbitalquark.github.io/textadept/images/linux.png)
![macOS](https://orbitalquark.github.io/textadept/images/macosx.png)
![Windows](https://orbitalquark.github.io/textadept/images/win32.png)
![Terminal](https://orbitalquark.github.io/textadept/images/ncurses.png)

[Lua]: https://lua.org

## Features

- Fast and minimalist.
- Cross platform, and with a terminal version, too.
- Self-contained executable -- no installation necessary.
- Support for over 100 programming languages.
- Unlimited split views.
- Can be entirely keyboard driven.
- Powerful snippets and key commands.
- Code autocompletion and documentation lookup.
- Remarkably extensible, with a heavily documented Application Programming Interface (API).

![Textadept](https://orbitalquark.github.io/textadept/images/splitviews.png)

## Requirements

In its bid for minimalism, Textadept depends on very little to run. On Windows and macOS,
it has no external dependencies. On Linux, the GUI version depends only on either [Qt][] or
[GTK][] (cross-platform GUI toolkits), and the terminal version depends only on [ncurses][].
BSD depends on Qt and ncurses. Lua and any other third-party dependencies are compiled into
the application itself.

[Qt]: https://www.qt.io/
[GTK]: https://gtk.org
[ncurses]: https://invisible-island.net/ncurses/ncurses.html

### Platforms / Systems supported versions

- Windows 10 64-bit: up to [current release][]; minimum requirement since release 12.1 (and 12.0beta)
- Windows 8.1/8/7 64-bit: up to [release 11.4][] (and 12.0alpha3)
- Windows Vista: ?
- Windows XP 32-bit: up to [release 11.3][] (dropped support for 32-bit Windows with 11.4alpha)
- Windows 2000: up to release 9.6
- Windows NT4: up to release 9.6?
- Windows 98SE: n/a
- Windows 95: n/a

- macOS X 11: up to [current release][]; minimum requirement since release 12.1 (and 12.0beta)
- macOS X 10.10: up to 11.5a
- macOS X 10.7: up to [release 11.3][]
- macOS X 10.6: up to [release 10.8][]

- FreeBSD 13+: since 12.5 restored BSD support; previously up to release 11.4 (and 11.5alpha) (dropped BSD support with 11.5alpha2)
  - see FreeBSD [Freshports textadept][] info page
  - not found in NetBSD pkgsrc
  - not found in OpenBSD ports

- Haiku: found [Haiku port of current release][] (12.6) (I have not yet tested this port); not found in HaikuDepot official packages

[current release]: https://github.com/orbitalquark/textadept/releases/tag/textadept_12.6
[release 12.1]: https://github.com/orbitalquark/textadept/releases/tag/textadept_12.1
[release 11.4]: https://github.com/orbitalquark/textadept/releases/tag/textadept_11.4
[release 11.3]: https://github.com/orbitalquark/textadept/releases/tag/textadept_11.3
[release 10.8]: https://github.com/orbitalquark/textadept/releases/tag/textadept_10.8
[Freshports textadept]: https://www.freshports.org/editors/textadept/
[Haiku port of current release]: https://github.com/M0JXD/textadept-haiku


## Download

Textadept releases can be found [here][1]. Select the appropriate package for your platform. A
comprehensive list of changes between releases can be found [here][2]. You can also download
a separate set of modules that provide extra features and functionality to the core application.

[1]: https://github.com/orbitalquark/textadept/releases
[2]: https://orbitalquark.github.io/textadept/changelog.html

## Installation and Usage

Textadept comes with a comprehensive [user manual][] in its *docs/* directory. It covers all
of Textadept's main features, including installation, usage, configuration, theming, scripting,
and compilation.

Since nearly every aspect of Textadept can be scripted using Lua, the editor's API is heavily
documented. This [API documentation][] is also located in *docs/*. It serves as the ultimate
resource when it comes to scripting the application.

[user manual]: https://orbitalquark.github.io/textadept/manual.html
[API documentation]: https://orbitalquark.github.io/textadept/api.html

## Compile

Textadept can be built on Windows, macOS, Linux, and BSD using [CMake][]. CMake will automatically
detect which platforms you can compile Textadept for (e.g. Qt, GTK, and/or Curses) and build
for them. On Windows and macOS you can then use CMake to create a self-contained application
to run from anywhere. On Linux and BSD you can either use CMake to install Textadept, or place
compiled binaries into Textadept's root directory and run it from there.

General Requirements:

- [CMake][] 3.16+
- A C and C++ compiler, such as:
	- [GNU C compiler][] (*gcc*) 7.1+
	- [Microsoft Visual Studio][] 2019+
	- [Clang][] 13+
- A UI toolkit (at least one of the following):
	- [Qt][] 5 or Qt 6 development libraries for the GUI version
	- [GTK][] 3 development libraries for the GUI version (GTK 2.24 is also supported)
	- [ncurses][](w) development libraries (wide character support) for the terminal version

Basic procedure:

1. Configure CMake to build Textadept by pointing it to Textadept's source directory (where
  *CMakeLists.txt* is) and specifying a binary directory to compile to.
2. Build Textadept.
3. Either copy the built Textadept binaries to Textadept's directory or use CMake to install it.

For example:

	cmake -S . -B build_dir -D CMAKE_BUILD_TYPE=RelWithDebInfo \
		-D CMAKE_INSTALL_PREFIX=build_dir/install
	cmake --build build_dir -j # compiled binaries are in build_dir/
	cmake --install build_dir # self-contained installation is in build_dir/install/

CMake boolean variables that affect the build:

- `NIGHTLY`: Whether or not to build Textadept with bleeding-edge dependencies (i.e. the nightly
  version). Defaults to off.
- `QT`: Unless off, builds the Qt version of Textadept. The default is auto-detected.
- `GTK3`: Unless off, builds the Gtk 3 version of Textadept. The default is auto-detected.
- `GTK2`: Unless off, builds the Gtk 2 version of Textadept. The default is auto-detected.
- `CURSES`: Unless off, builds the Curses (terminal) version of Textadept. The default is
  auto-detected.

For more information on compiling Textadept, please see the [manual][].

[CMake]: https://cmake.org
[GNU C compiler]: https://gcc.gnu.org
[Microsoft Visual Studio]: https://visualstudio.microsoft.com/
[Clang]: https://clang.llvm.org/
[Qt]: https://www.qt.io
[GTK]: https://gtk.org
[ncurses]: https://invisible-island.net/ncurses/ncurses.html
[manual]: https://orbitalquark.github.io/textadept/manual.html#compiling

## Contribute

Textadept is [open source][]. Feel free to discuss features, report bugs, and submit patches. You
can also contact me personally (code att foicica.com).

[open source]: https://github.com/orbitalquark/textadept
