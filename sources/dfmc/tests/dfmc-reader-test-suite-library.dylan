Module: dylan-user
License: See License.txt in this distribution for details.


define library dfmc-reader-test-suite
  use common-dylan;
  use dfmc-common;
  use dfmc-namespace;
  use dfmc-reader;
//  use dfmc-typist;
//  use projects;
//  use source-records;
  use testworks;

  export dfmc-reader-test-suite;
end library dfmc-reader-test-suite;

define module dfmc-reader-test-suite
  use common-dylan;
  use dfmc-common,
    import: {
      compilation-record-source-record,
      compilation-record-module
    };
  use dfmc-namespace,
    import: {
      <project-library-description>,
      <interactive-source-record>,
      with-top-level-library-description,
      with-library-context
    };
  use dfmc-reader;
//  use dfmc-typist;
//  use projects;
//  use source-records;
  use testworks;

  export dfmc-reader-test-suite;
end module dfmc-reader-test-suite;
