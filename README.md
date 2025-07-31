reMarkable Kaitai Specs
=======================

The [reMarkable](https://remarkable.com/)
is a pretty cool e-ink tablet.
The tablet stores a notebook's pen strokes in binary files on the device
(`.rm` files, also called *lines* format).
For backup and/or conversion jobs, it can be helpful to parse this binary
format.

[Kaitai Struct](http://kaitai.io/)
is a declarative parser specification language for binary data formats,
and an accompanying parser generator.
Kaitai Struct specifications can be compiled to code for a parser in one
of various languages. It also has serialization capabilites, although
they are quite limited at this point.

This repository contains a Kaitai Struct specification for some versions
of the reMarkable lines (`.rm`) format.

Notes
-----

This specification was made very quickly for fun, and it could probably
be improved. 

The specifications have only been tested superficially.
Version 6 of the specification has only been tested on documents 
prepared in the [xochitl](https://developer.remarkable.com/documentation/xochitl) app version 3.8.2.

The reMarkable lines format evolves as the reMarkable receives updates,
and this repository is not going to be kept up to date. Forks
are welcome.

Contents
--------

* `rm_v3.ksy` - spec for reMarkable lines format, version 3
* `rm_v5.ksy` - spec for reMarkable lines format, version 5
  * `hello_v5.rm` - example v5 lines binary file
* `rm_v6.ksy` - spec for reMarkable lines format, version 6
  * `leb128.ksy` - spec for Little Endian Base 128 which is used in lines format, version 6
  * `hello_v6.rm` - example v6 lines binary file
* `rm_v6.hexpat` - [ImHex](https://github.com/WerWolv/ImHex) pattern for lines format, version 6
  * included to make further development of the kaitai spec easier

Credits
-------

* Thanks to ax3l for documenting a
  [thorough exploration of the binary format](https://plasma.ninja/blog/devices/remarkable/binary/format/2017/12/26/reMarkable-lines-file-format.html),
  and for the
  [C++](https://github.com/ax3l/lines-are-beautiful)
  and
  [Rust](https://github.com/ax3l/lines-are-rusty)
  reference implementations of the parser.
* Thanks to reHackable's
  [awesome-reMarkable](https://github.com/reHackable/awesome-reMarkable)
  project, which brings together many great and open projects for enhancing
  the reMarkable notebook experience, and helped me find ax3l's work.
* Thanks to a [stackoverflow answer](https://stackoverflow.com/a/39827436)
  for informing me about Kaitai Struct, saving me from writing a parser in
  Python (I use Python too much, and should really branch out more).
* Kaitai Struct was super easy to pick up due to the great documentation and
  online IDE. Thanks,  for helping me feel like a hacker!
* Thanks to [reMarkable AS](https://remarkable.com/) for your awesome tablet.
  It is a technology that has an unquestionably positive impact on my life
  (and in case anyone hasn't noticed, that's saying something for a technology
  these days).
* Thanks to [rM Hacks discord server](https://discord.com/invite/bgVXW2bchN) for 
  pointing out there's an env variable **SCENE_FILE_V6_DEBUG** which made 
  the process of analyzing binary format much easier.

This repository is not affiliated with reMarkable AS.
