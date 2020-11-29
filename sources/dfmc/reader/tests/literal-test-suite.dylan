Module: dfmc-reader-test-suite
License: See License.txt in this distribution for details.

define function verify-literal
    (f :: <fragment>, value, required-class)
 => ()
  assert-equal(f.fragment-value, value);
  assert-instance?(required-class, f);
end function verify-literal;

define function verify-presentation
    (f :: <fragment>, presentation :: <string>)
 => ()
  let stream = make(<string-stream>, direction: #"output");
  present-fragments(list(f), stream);
  assert-equal(stream.stream-contents, presentation);
end function verify-presentation;

define test binary-integer-literal-test ()
  verify-literal(read-fragment("#b10"), 2, <integer-fragment>);
  verify-literal(read-fragment("#b010"), 2, <integer-fragment>);
  verify-literal(read-fragment("#b1111_0000"), 240, <integer-fragment>);
  assert-false(read-fragment("#b10_"));
  assert-signals(<invalid-token>, read-fragment("#b_10"));
  assert-signals(<invalid-token>, read-fragment("#b2"));
  assert-signals(<invalid-token>, read-fragment("#b + 1"));
end test binary-integer-literal-test;

define test boolean-literal-test ()
  let t = read-fragment("#t");
  verify-literal(t, #t, <true-fragment>);
  verify-presentation(t, "#t");

  let f = read-fragment("#f");
  verify-literal(f, #f, <false-fragment>);
  verify-presentation(f, "#f");
end test boolean-literal-test;

define test character-literal-test ()
  let f = read-fragment("'n'");
  verify-literal(f, 'n', <character-fragment>);
  verify-presentation(f, "'n'");

  let f = read-fragment("'N'");
  assert-equal(f.fragment-value, 'N');
  verify-presentation(f, "'N'");

  let f = read-fragment("'\\\\'");
  assert-equal(f.fragment-value, '\\');
  verify-presentation(f, "'\\\\'");

  let f = read-fragment("'\\n'");
  assert-equal(f.fragment-value, '\n');
  verify-presentation(f, "'\\n'");

  let f = read-fragment("'\\<1>'");
  assert-equal(as(<integer>, f.fragment-value), 1);
  verify-presentation(f, "'\\<1>'");

  let f = read-fragment("'\\<01>'");
  assert-equal(as(<integer>, f.fragment-value), 1);
  verify-presentation(f, "'\\<1>'");

  let f = read-fragment("'\\<fF>'");
  assert-equal(as(<integer>, f.fragment-value), 255);
  verify-presentation(f, "'\\<FF>'");

  assert-signals(<invalid-token>, read-fragment("'21'"));
  assert-signals(<invalid-token>, read-fragment("'\\j'"));
  assert-signals(<invalid-token>, read-fragment("'\\<gg>'"));
  assert-signals(<character-code-too-large>, read-fragment("'\\<fff>'"));
end test character-literal-test;

define test decimal-integer-literal-test ()
  let f = read-fragment("123");
  verify-literal(f, 123, <integer-fragment>);
  verify-presentation(f, "123");

  let f = read-fragment("-456");
  verify-literal(f, -456, <integer-fragment>);
  verify-presentation(f, "-456");

  let f = read-fragment("+789");
  verify-literal(f, 789, <integer-fragment>);
  verify-presentation(f, "789");

  let f = read-fragment("1_000_000");
  verify-literal(f, 1000000, <integer-fragment>);
  verify-presentation(f, "1000000");

  let f = read-fragment("1_000_000");
  verify-literal(f, 1000000, <integer-fragment>);
  verify-presentation(f, "1000000");

  let f = read-fragment("1_2_3_4");
  verify-literal(f, 1234, <integer-fragment>);
  verify-presentation(f, "1234");

  assert-false(read-fragment("100_"));  // No trailing underscore.
  assert-false(read-fragment("1__00")); // No multi-underscore runs.
  assert-false(read-fragment("_100"));  // No leading underscore.
end test decimal-integer-literal-test;

define test float-literal-test ()
  verify-literal(read-fragment("3.0"),   3.0, <float-fragment>);
  verify-literal(read-fragment("-3.0"), -3.0, <float-fragment>);
  verify-literal(read-fragment("3e0"),   3.0, <float-fragment>);
  verify-literal(read-fragment("3.0e0"), 3.0, <float-fragment>);
  verify-literal(read-fragment("3.e0"),  3.0, <float-fragment>);

  verify-literal(read-fragment(".5"),   0.5, <float-fragment>);
  verify-literal(read-fragment("-.5"), -0.5, <float-fragment>);
  verify-literal(read-fragment("+.5"),  0.5, <float-fragment>);

  verify-literal(read-fragment("6."),   6.0, <float-fragment>);
  verify-literal(read-fragment("+6."),  6.0, <float-fragment>);
  verify-literal(read-fragment("-6."), -6.0, <float-fragment>);

  verify-literal(read-fragment("3.0s0"),   3.0, <float-fragment>);
  verify-literal(read-fragment("30.0s-1"), 3.0, <float-fragment>);
  verify-literal(read-fragment("3.0d0"),   3.0, <float-fragment>);
  verify-literal(read-fragment("-3.0d0"), -3.0, <float-fragment>);
  verify-literal(read-fragment("-3.0d3"), -3000.0, <float-fragment>);
  verify-literal(read-fragment("-3d3"),   -3000.0, <float-fragment>);

  // Underscores
  verify-literal(read-fragment("1_23.45"),     123.45, <float-fragment>);
  verify-literal(read-fragment("123.4_5"),     123.45, <float-fragment>);
  verify-literal(read-fragment("1_23.45e1_0"), 123.45e10, <float-fragment>);
  verify-literal(read-fragment("1_23.45e+1_0"), 123.45e10, <float-fragment>);
  verify-literal(read-fragment("1_23.45e-1_0"), 123.45e-10, <float-fragment>);
  verify-literal(read-fragment("1_23.45d1_0"), 123.45d10, <float-fragment>);

  // Underscore only allowed between decimal digits.
  assert-false(read-fragment("_123.45e10"));
  assert-false(read-fragment("123_.45e10"));
  assert-false(read-fragment("123._45e10"));
  assert-false(read-fragment("123.45_e10"));
  assert-false(read-fragment("123.45e_10"));
  assert-false(read-fragment("123.45e10_"));
  assert-false(read-fragment("+_123.45e10"));

  // Multiple underscores not allowed
  assert-false(read-fragment("1__23.45d10"));
  assert-false(read-fragment("123.45d1__0"));
  assert-false(read-fragment("123.4__5d10"));
end test float-literal-test;

define test hexadecimal-integer-literal-test ()
  verify-literal(read-fragment("#xff"), 255, <integer-fragment>);
  verify-literal(read-fragment("#xdead_beef"), 3735928559, <integer-fragment>);
  verify-literal(read-fragment("#xb_e_e_f"), 48879, <integer-fragment>);

  assert-signals(<invalid-token>, read-fragment("#x_beef"));  // No leading underscore.
  assert-false(read-fragment("#xbe__ef")); // No multi-underscore runs.
  assert-false(read-fragment("#xbeef_"));  // No trailing underscore.
  assert-signals(<invalid-token>, read-fragment("#xh"));
  assert-signals(<invalid-token>, read-fragment("#x + 1"));
end test hexadecimal-integer-literal-test;

define test list-literal-test ()
  let f = read-fragment("#()");
  verify-literal(f, #(), <proper-list-fragment>);
  verify-presentation(f, "#()");

  let f = read-fragment("#('a', 'b')");
  verify-literal(f, #('a', 'b'), <proper-list-fragment>);
  verify-presentation(f, "#('a', 'b')");

  let f = read-fragment("#(a:, #\"b\")");
  verify-presentation(f, "#(a:, #\"b\")");
end test list-literal-test;

define test octal-integer-literal-test ()
  verify-literal(read-fragment("#o70"), 56, <integer-fragment>);
  verify-literal(read-fragment("#o3_444"), 1828, <integer-fragment>);

  assert-signals(<invalid-token>, read-fragment("#o_70"));  // No leading underscore.
  assert-false(read-fragment("#o70_"));                     // No trailing underscore.
  assert-false(read-fragment("#o7__0")); // No multi-underscore runs.
  assert-signals(<invalid-token>, read-fragment("#o8"));
  assert-signals(<invalid-token>, read-fragment("#o + 1"));
end test octal-integer-literal-test;

define test pair-literal-test ()
  let f = read-fragment("#(1 . 2)");
  verify-literal(f, #(1 . 2), <improper-list-fragment>);
  verify-presentation(f, "#(1 . 2)");

  let f = read-fragment("#(a: . #\"b\")");
  verify-presentation(f, "#(a: . #\"b\")");
end test pair-literal-test;

define test ratio-literal-test ()
  assert-signals(<ratios-not-supported>, read-fragment("1/2"));
end test ratio-literal-test;

define test string-literal-test ()
  let f = read-fragment("\"abc\"");
  verify-literal(f, "abc", <string-fragment>);

  let f = read-fragment("\"a\\nc\"");
  verify-literal(f, "a\nc", <string-fragment>);

  assert-signals(<invalid-token>, read-fragment("\"\\1<b>\""));
end test string-literal-test;

define test symbol-literal-test ()
  let kw = read-fragment("test:");
  verify-literal(kw, #"test", <keyword-syntax-symbol-fragment>);
  verify-presentation(kw, "test:");

  let sym = read-fragment("#\"hello world\"");
  verify-literal(sym, #"hello world", <symbol-syntax-symbol-fragment>);
  verify-presentation(sym, "#\"hello world\"");
end test symbol-literal-test;

define test vector-literal-test ()
  let f = read-fragment("#[]");
  verify-literal(f, #(), <vector-fragment>);
  verify-presentation(f, "#[]");

  let f = read-fragment("#[-1, 2]");
  verify-literal(f, #(-1, 2), <vector-fragment>);
  verify-presentation(f, "#[-1, 2]");

  let f = read-fragment("#[\"a\", b:]");
  verify-literal(f, #("a", #"b"), <vector-fragment>);
  verify-presentation(f, "#[\"a\", b:]");
end test vector-literal-test;

define suite literal-test-suite ()
  test binary-integer-literal-test;
  test boolean-literal-test;
  test character-literal-test;
  test decimal-integer-literal-test;
  test float-literal-test;
  test hexadecimal-integer-literal-test;
  test list-literal-test;
  test octal-integer-literal-test;
  test pair-literal-test;
  test ratio-literal-test;
  test string-literal-test;
  test symbol-literal-test;
  test vector-literal-test;
end suite literal-test-suite;
