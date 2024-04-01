Module:    dfmc-testing
Author:    Steve Rowley
Synopsis:  Tests for the typist's inference.
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

///
/// Test substrate for the static type inferencer.
///
/// The entry points are run-typist-tests, run-typist-test, and
/// show-lambda-type-estimates.
///
/// This duplicates some of the general test substrate, since the typist has
/// its own testing needs.  However, each typist test gets put in the general
/// test suite as well, so running all the tests will get these, too.
///

// *** Consider putting daemons on print() methods, so the printing of
//     DFM code comes annotated, computation-by-computation, with types.
define function show-lambda-type-estimates
  (lambda :: <&method>,
  #key stream                :: <stream>     = *standard-output*,
       lib                   :: false-or(<library-description>),
       cache                 :: <type-cache> = if (lib)
                                                 library-type-cache(lib)
                                               else
                                                 make(<type-cache>)
                                               end,
       show-code?            :: <boolean>    = #t,
       show-temps?           :: <boolean>    = #t,
       show-targets?         :: <boolean>    = #t,
       show-comp-reasons?    :: <boolean>    = #f,
       show-temp-reasons?    :: <boolean>    = #f,
       show-reasons-recurse? :: <boolean>    = #f)
  => (cache :: <type-cache>)
  // yatter about <computation>s and associated <temporary>s to stream, e.g.,
  // show-lambda-type-estimates(try(#{ if (x) x + 1 else 2.0 * x end }));
  with-testing-context (lib)
    when (show-code?)
      dynamic-bind (*print-method-bodies?* = #t)
        format(stream, "\nThe code is:\n%=", lambda)
      end
    end;
    type-estimate-in-cache(lambda, cache);       // Fill the cache
    format(stream, "\nThe types are:");
    for-computations (comp in lambda)
      format(stream, "\n***%= %= :: %=",
             object-class(comp), comp, type-estimate-in-cache(comp, cache));
      when (show-comp-reasons?)
        type-estimate-explain(comp, cache,
                              stream: stream, recurse?: show-reasons-recurse?,
                              indent: 1)
      end;
      when (show-temps? & ~instance?(comp, <bind>))
        // *** This should be using temporary-accessors, or whatever.
        //     See the graph-class-definer macro in flow-graph.
        let temp = temporary(comp);
        when (temp)
          format(stream, "\n  %= %= :: %=",
                 object-class(temp), temp, type-estimate-in-cache(temp, cache));
          when (show-temp-reasons?)
            type-estimate-explain(temp, cache,
                                  stream: stream, recurse?: show-reasons-recurse?,
                                  indent: 1)
          end
        end
      end;
      when (show-targets?)
        select (comp by instance?)      // Look at targets of assignments.
          <assignment> => format(stream, "\n   Assignment target: %= %= :: %=",
                                 object-class(assigned-binding(comp)), assigned-binding(comp),
                                 type-estimate-in-cache(assigned-binding(comp), cache));
          otherwise    => ;
        end
      end
    end
  end;
  cache
end;

// This isn't used by default, but is useful to have around when debugging.
ignore(show-lambda-type-estimates);

///
/// Substrate for defining type inference tests.
///

define variable *static-type-check?-verbose?* :: <boolean> = #f;

// *** Well, really you should be inspecting the <table>.
define function static-type-check?(lambda        :: <&method>,
                                   expected-type :: <type-estimate-values>)
  => (stc :: <boolean>)
  // Useful thing to put in the body of a test: infer the return values
  // of lambda, and ask if they match expected-type.
  let cache = make(<type-cache>);
  local method final-computation-type(c :: <&method>)
          // What is the type of the final computation?  (I.e., the return.)
          type-estimate-in-cache(c, cache);                         // fill cache w/types
          type-estimate-in-cache(final-computation(body(c)), cache) // just the last guy
        end;
  let found-type = final-computation-type(lambda);
  if (type-estimate-subtype?(found-type, expected-type))
    #t
  else
    when (*static-type-check?-verbose?*)
      // Sometimes you want a diagnostic for the failure cases.
      dynamic-bind (*print-method-bodies?* = #t)
        format-out("\nFor %=:\nExpected type:   %=\n  Inferred type: %=\n\n",
                   lambda, expected-type, found-type)
      end;
      show-lambda-type-estimates(lambda, cache: cache);
    end;
    #f
  end
end;

define function compile-to-method (string :: <string>) => (m :: <&method>)
  // Compile a template & cut through the underbrush to the init form
  dynamic-bind (*progress-stream*           = #f,  // with-compiler-muzzled
                *demand-load-library-only?* = #f)
    let lib = compile-template(string,
                               compiler: compile-library-until-optimized);
    let cr* = library-description-compilation-records(lib);
    // One for lib+mod defn & one for the source template.
    assert(size(cr*) == 2, "Expected exactly 2 <compilation-record>s: %=", cr*);
    let top-level-forms = compilation-record-top-level-forms(cr*[1]);
    assert(~empty?(top-level-forms),
           "Expected at least one top level form: %= from %=",
           top-level-forms, string);
    let method-definition :: <method-definition> = last(top-level-forms);
    form-model(method-definition)
  end
end;

define macro typist-inference-test-definer
  // Define manual compiler test & remember the name in typist inference registry
  { define typist-inference-test ?test-name:name
      ?subtests
    end }
  => {
       define test ?test-name ()
         with-testing-context (#f)
           ?subtests
         end
       end }
subtests:
  // ;-separated test specs expand into a conjunction of test results
  { }               => { }
  { ?subtest; ... } => { ?subtest ... }
subtest:
  // Wrap with try ... end and hand off to static-type-check? to match
  // against the values specification.
  { } => { }
  { ?:expression TYPE: ?val:* }
    => { assert-true(static-type-check?(compile-to-method(?expression),
                                        make(<type-estimate-values>, ?val))); }
end;

define function class-te(cl :: <symbol>) => (cte :: <type-estimate-class>)
  // Make a class type estimate -- useful thing to put on RHS of a test.
  make(<type-estimate-class>, class: dylan-value(cl))
end;

define function false-te() => (fte :: <type-estimate-limited-instance>)
  make(<type-estimate-limited-instance>, singleton: &false)
end;

define function raw-te(rt :: <symbol>) => (rte :: <type-estimate-raw>)
  make(<type-estimate-raw>, raw: dylan-value(rt))
end;

define function bottom-te () => (bte :: <type-estimate-bottom>)
  make(<type-estimate-bottom>)
end;

///
/// Here follow the actual tests
///

define typist-inference-test typist-constants
  // Do you recognize a constant when you see one?
  "define method typist-test () 0 end;"
    TYPE: fixed: vector(class-te(#"<integer>")),              rest: #f;
  "define method typist-test () 3.14d0 end;"
    TYPE: fixed: vector(class-te(#"<double-float>")),         rest: #f;
  "define method typist-test () #f end;"
    TYPE: fixed: vector(false-te()),                          rest: #f;
  "define method typist-test () \"foo\" end;"
    TYPE: fixed: vector(class-te(#"<byte-string>")),          rest: #f;
  "define method typist-test () 'c' end;"
    TYPE: fixed: vector(class-te(#"<character>")),            rest: #f;
  "define method typist-test () foo: end;"
    TYPE: fixed: vector(class-te(#"<symbol>")),               rest: #f;
  "define method typist-test () #[] end;"
    TYPE: fixed: vector(class-te(#"<simple-object-vector>")), rest: #f;
  "define method typist-test () #[1] end;"
    TYPE: fixed: vector(class-te(#"<simple-object-vector>")), rest: #f;
  "define method typist-test () #() end;"
    TYPE: fixed: vector(class-te(#"<empty-list>")),           rest: #f;
  "define method typist-test () #(1) end;"
    TYPE: fixed: vector(class-te(#"<pair>")),                 rest: #f
end;

// *** ??: Warning: Reference to undefined binding values // undefined.
define typist-inference-test typist-values
  // Can we figure out multiple values properly?
  "define method typist-test () values() end;"
    TYPE: fixed: #[],
          rest: #f;
  "define method typist-test () values(1) end;"
    TYPE: fixed: vector(class-te(#"<integer>")),
          rest: #f;
  "define method typist-test ()  values(1, 'c') end;"
    TYPE: fixed: vector(class-te(#"<integer>"),
                        class-te(#"<character>")),
          rest: #f;
  "define method typist-test () values(1, 'c', \"foo\") end;"
    TYPE: fixed: vector(class-te(#"<integer>"),
                        class-te(#"<character>"),
                        class-te(#"<byte-string>")),
          rest: #f
  // *** Example with rest-values?
end;

define typist-inference-test typist-merge
  // Is the merge node the union of its sources?
  "define variable x = 1; define method typist-test () if (x) 1 else 2     end end;"
    TYPE: fixed: vector(class-te(#"<integer>")),
          rest: #f;
  "define variable x = 1; define method typist-test () if (x) 1 else \"foo\" end end;"
    TYPE: fixed: vector(make(<type-estimate-union>,
                             unionees: list(class-te(#"<integer>"),
                                            class-te(#"<byte-string>")))),
          rest: #f;
  "define variable x = 1; define method typist-test () if (x) 1 else \"foo\" end end;"
    TYPE: fixed: vector(make(<type-estimate-union>,
                             unionees: list(class-te(#"<byte-string>"),
                                            class-te(#"<integer>")))),
          rest: #f
end;

define typist-inference-test typist-check
  // Do you know about <check-type> instructions?
  "define variable f = #f; define method typist-test () let x :: <integer> = f(); x end end;"
    TYPE: fixed: vector(class-te(#"<integer>")), rest: #f
end;

define typist-inference-test typist-assign
  // Does the target of an assignment get a type?
  "define variable global1 = #f; define method typist-test () global1 := 0; global1 end;"
    // *** Should pick up #f initial value, too?
    TYPE: fixed: vector(class-te(#"<integer>")),
          rest: #f;
  " define variable global2 = #f; define method typist-type () global2 := 0; global2 := \"foo\"; global2 end;"
    // *** Should pick up #f initial value, too?
    TYPE: fixed: vector(make(<type-estimate-union>,
                             unionees: list(class-te(#"<byte-string>"),
                                            class-te(#"<integer>")))),
          rest: #f
  // *** More assignments to lexicals and so on.
end;

define typist-inference-test typist-lambda
  // Do you know a function when you see one?  What can you know about it?
  "define method typist-type () method (x :: <integer>) x end end;"
    TYPE: fixed: vector(make(<type-estimate-limited-function>,
                             class:     dylan-value(#"<method>"),
                             requireds: vector(class-te(#"<integer>")),
                             rest?:     #f,
                             vals:      make(<type-variable>,
                                             contents: make(<type-estimate-values>,
                                                            fixed: vector(class-te(#"<integer>")),
                                                            rest:  #f)))),
          rest:  #f
end;

define typist-inference-test typist-unwind-protect
  // Can we type an unwind-protect?  Even with degenerate body & cleanups.
  "define variable foo = #f; define method typist-test () block () 1 cleanup foo() end end;"
     TYPE: fixed: vector(class-te(#"<integer>")), rest: #f;
  "define variable foo = #f; define method typist-test () block () 1 cleanup end end;"
     TYPE: fixed: vector(class-te(#"<integer>")), rest: #f;
  "define variable foo = #f; define method typist-test () block () cleanup foo() end end;"
     TYPE: fixed: vector(false-te()), rest: #f
end;

define typist-inference-test typist-bind-exit
  // Can you figure out bind-exit?  Easy case is where exit is used only locally.
  // Non-local case is, well, non-local.
  "define method typist-test () block (xit) xit(2); 'c' end end;"
     TYPE: fixed: vector(make(<type-estimate-union>,
                              unionees: list(class-te(#"<integer>"),
                                             class-te(#"<character>")))),
           rest: #f;
  "define method typist-test () block (xit) xit(1); xit('c'); \"foo\" end end;"
     TYPE: fixed: vector(make(<type-estimate-union>,
                              unionees: list(class-te(#"<integer>"),
                                             class-te(#"<character>"),
                                             class-te(#"<byte-string>")))),
           rest:  #f
end;

define typist-inference-test typist-primops
  // Can you figure out what the primops in <primitive-call>s do?
  "define method typist-test () primitive-word-size(); end;"
    TYPE: fixed: vector(raw-te(#"<raw-integer>")),
          rest:  #f;
  "define method typist-test () primitive-allocate(integer-as-raw(1)); end;"
    TYPE: fixed: vector(raw-te(#"<raw-pointer>")),
          rest:  #f;
  "define method typist-test () primitive-machine-word-add(integer-as-raw(1), integer-as-raw(2)); end;"
    TYPE: fixed: vector(raw-te(#"<raw-machine-word>")),
          rest:  #f;
  "define method typist-test () primitive-machine-word-equals?(integer-as-raw(1), integer-as-raw(1)); end;"
    TYPE: fixed: vector(raw-te(#"<raw-boolean>")),
          rest:  #f;
  "define method typist-test () primitive-object-class(integer-as-raw(1)); end;"
    TYPE: fixed: vector(class-te(#"<class>")),
          rest:  #f;
end;

define typist-inference-test typist-raw-constants
  // Do you recognize a raw constant when you see one?
  "define method typist-test () integer-as-raw(0) end;"
       TYPE: fixed: vector(raw-te(#"<raw-integer>")),
             rest: #f;
  "define method typist-test () primitive-byte-character-as-raw('c') end;"
       TYPE: fixed: vector(raw-te(#"<raw-byte-character>")),
             rest: #f;
  "define method typist-test () primitive-not(foo:) end;"
       TYPE: fixed: vector(raw-te(#"<raw-boolean>")),
             rest: #f;
  "define method typist-test () primitive-single-float-as-raw(1.0) end;"
       TYPE: fixed: vector(raw-te(#"<raw-single-float>")),
             rest: #f
end;

define typist-inference-test typist-bottom
  "define method typist-test () error(\"Error\") end;"
       TYPE: fixed: vector(bottom-te()),
             rest: #f;
end;

define suite dfmc-typist-inference-suite ()
  test typist-constants;
  test typist-values;
  test typist-merge;
  test typist-check;
  test typist-assign;
  // test typist-lambda;
  test typist-unwind-protect;
  test typist-bind-exit;
  test typist-primops;
  test typist-raw-constants;
  test typist-bottom;
end;
