Module: dfmc-reader-test-suite
License: See License.txt in this distribution for details.


define function get-token-as-string
    (source :: <string>) => (token :: <string>, kind)
  local method do-nothing(#rest _) end;
  let contents = as(<byte-vector>, source);
  let (pos, result-kind, result-start, result-end, unexpected-eof, lnum, lstart)
    = get-token-1($initial-state, contents, do-nothing, do-nothing);
  as(<string>, copy-sequence(contents, end: result-end))
end function get-token-as-string;

define test lex-integer-test ()
  assert-equal(get-token-as-string("123,abc"), "123");
end;

define test lex-multi-line-string-test ()
  assert-equal(get-token-as-string("\"\"\"abc\"\"\"...."), "abc");
end test lex-multi-line-string-test;

define suite dfmc-reader-test-suite ()
  test lex-integer-test;
  test lex-multi-line-string-test;
end suite dfmc-reader-test-suite;
