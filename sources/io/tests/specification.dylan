Module:       io-test-suite
Synopsis:     IO library test suite
Author:       Andy Armstrong, et al...
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define interface-specification-suite streams-specification-suite ()

  // Constants

  constant <buffer-index> :: <type>;
  constant <byte> :: <type>;

  // Classes

  open instantiable class <sequence-stream> (<positionable-stream>);
  open instantiable class <string-stream> (<sequence-stream>);
  open instantiable class <byte-string-stream> (<string-stream>);

  abstract class <stream-position> (<object>);

  // Stream convenience functions
  open generic function read-line (<stream>, #"key", #"on-end-of-stream")
    => (<object>, <boolean>);
  open generic function read-line-into!
    (<stream>, <string>, #"key", #"start", #"on-end-of-stream", #"grow?")
    => (<object>, <boolean>);
  open generic function read-text (<stream>, <integer>, #"key", #"on-end-of-stream")
    => (<object>);
  open generic function read-text-into! (<stream>, <integer>, <string>,
                                         #"key", #"start", #"on-end-of-stream")
    => (<object>);
  function skip-through (<stream>, <object>, #"key", #"test")
    => (<boolean>);
  open generic function write-line (<stream>, <string>, #"key", #"start", #"end")
    => ();
  open generic function write-text (<stream>, <string>, #"key", #"start", #"end")
    => ();
  function read-through
    (<stream>, <object>, #"key", #"on-end-of-stream", #"test")
    => (<object>, <boolean>);
  function read-to
    (<stream>, <object>, #"key", #"on-end-of-stream", #"test")
    => (<object>, <boolean>);
  function read-to-end (<stream>)
    => (<sequence>);
  open generic function new-line (<stream>)
    => ();

  // Miscellaneous stream functions
  function stream-lock (<stream>)
    => (<object>);
  function stream-lock-setter (<object>, <stream>)
    => (<object>);

  // Wrapper streams
  open abstract instantiable class <wrapper-stream> (<stream>);
  open generic function inner-stream (<wrapper-stream>)
    => (<stream>);
  open generic function inner-stream-setter (<stream>, <wrapper-stream>)
    => (<stream>);
  open generic function outer-stream (<stream>) => (<stream>);
  open generic function outer-stream-setter
       (<stream>, <stream>)
    => (<stream>);

  // Stream buffers
  sealed instantiable class <buffer> (<vector>);
  function buffer-next (<buffer>)
    => (<buffer-index>);
  function buffer-next-setter (<buffer-index>, <buffer>)
    => (<buffer-index>);
  function buffer-end (<buffer>)
    => (<buffer-index>);
  function buffer-end-setter (<buffer-index>, <buffer>)
    => (<buffer-index>);
  open generic function buffer-subsequence
    (<buffer>, subclass(<mutable-sequence>), <buffer-index>, <buffer-index>)
    => (<mutable-sequence>);
  open generic function copy-into-buffer!
    (<buffer>, <buffer-index>, <sequence>, #"key", #"start", #"end") => ();
  open generic function copy-from-buffer!
        (<buffer>, <buffer-index>, <mutable-sequence>,
         #"key", #"start", #"end")
     => ();

  // Buffered streams
  open abstract class <buffered-stream> (<stream>);
  function get-input-buffer (<buffered-stream>, #"key", #"wait?", #"bytes")
    => (false-or(<buffer>));
  open generic function do-get-input-buffer
    (<buffered-stream>, #"key", #"wait?", #"bytes")
    => (false-or(<buffer>));
  function get-output-buffer (<buffered-stream>, #"key", #"bytes")
    => (false-or(<buffer>));
  open generic function do-get-output-buffer (<buffered-stream>, #"key", #"bytes")
    => (false-or(<buffer>));
  function input-available-at-source? (<buffered-stream>)
    => (<boolean>);
  open generic function do-input-available-at-source? (<buffered-stream>)
    => (<boolean>);
  function next-input-buffer (<buffered-stream>, #"key", #"wait?", #"bytes")
    => (false-or(<buffer>));
  open generic function do-next-input-buffer
    (<buffered-stream>, #"key", #"wait?", #"bytes")
    => (false-or(<buffer>));
  function next-output-buffer (<buffered-stream>, #"key", #"bytes")
    => ();
  open generic function do-next-output-buffer (<buffered-stream>, #"key", #"bytes")
    => (<buffer>);
  function release-input-buffer (<buffered-stream>)
    => ();
  open generic function do-release-input-buffer (<buffered-stream>)
    => ();
  function release-output-buffer (<buffered-stream>)
    => ();
  open generic function do-release-output-buffer (<buffered-stream>)
    => ();

  // Indenting streams
  sealed instantiable class <indenting-stream> (<wrapper-stream>);
  function indent (<indenting-stream>, <integer>)
    => ();
end streams-specification-suite;


define interface-specification-suite pprint-specification-suite ()
  variable *print-miser-width*   :: false-or(<integer>);
  variable *default-line-length* :: <integer>;

  sealed instantiable class <pretty-stream> (<stream>);

  function pprint-logical-block (<stream>) => ();
  function pprint-newline (one-of(#"linear", #"fill", #"miser", #"mandatory"), <stream>) => ();
  function pprint-indent (one-of(#"block", #"current"), <integer>, <stream>) => ();
  function pprint-tab (one-of(#"line", #"line-relative", #"section", #"section-relative"), <integer>, <integer>, <stream>) => ();
end;


define interface-specification-suite print-specification-suite ()
  variable *print-length*  :: false-or(<integer>);
  variable *print-level*   :: false-or(<integer>);
  variable *print-circle?* :: <boolean>;
  variable *print-pretty?* :: <boolean>;
  variable *print-escape?* :: <boolean>;

  function print (<object>, <stream>) => ();
  open generic function print-object (<object>, <stream>) => ();
  function print-to-string (<object>) => (<string>);
end;

define suite io-test-suite ()
  suite streams-specification-suite;
  suite streams-test-suite;
  // streams-internals;
  suite pprint-specification-suite;
  suite pprint-test-suite;
  suite print-specification-suite;
  suite print-test-suite;
  // print-internals;
  // format;
  // format-internals;
  // standard-io;
  // format-out;
  suite format-test-suite;

  // Benchmark writing to a string stream, and a competing non-stream-based
  // implementation.
  benchmark benchmark-output-to-string;
  benchmark benchmark-string-builder;
end suite;
