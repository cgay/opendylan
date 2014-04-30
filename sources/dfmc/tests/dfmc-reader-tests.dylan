Module: dfmc-reader-test-suite
License: See License.txt in this distribution for details.


define class <fake-compilation-record> (<object>)
  constant slot compilation-record-source-record,
      required-init-keyword: source:;
end class <fake-compilation-record>;

define test test-read-multi-line-string ()
  let source = "\"\"\"abc\"\"\" x";
//  let ld = make(<project-library-description>,
//                location: #f,
//                project: #f);
  let sr  = make(<interactive-source-record>,
                 project: #f,
                 module: #"test",
                 source: as(<byte-vector>, source));
  let cr = make(<fake-compilation-record>, source-record: sr);
  with-top-level-library-description (ld)
    with-library-context (ld)
      let (fragment, lexer) = read-top-level-fragment(cr, #f);
      assert-equal(fragment.fragment-source-position, 9);
    end;
  end;
end test test-read-multi-line-string;

define suite dfmc-reader-test-suite ()
  test test-read-multi-line-string;
end;

