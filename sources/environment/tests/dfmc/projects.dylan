Module:    dfmc-environment-test-suite
Synopsis:  DFMC Environment Tests
Author:    Andy Armstrong
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

/// Useful constants

define constant $test-application = "environment-test-application";
define constant $test-library     = "environment-test-library";

define constant $test-application-id
  = make(<library-id>, name: $test-application);

define constant $test-application-module-id
  = make(<module-id>, name: $test-application, library: $test-application-id);

define constant $test-library-id
  = make(<library-id>, name: $test-library);

define constant $test-library-module-id
  = make(<module-id>, name: $test-library, library: $test-library-id);

define constant $test-class-id
  = make(<definition-id>,
         name: "<test-object>",
         module: $test-library-module-id);

define constant $test-internal-class-id
  = make(<definition-id>,
         name: "<internal-test-object>",
         module: $test-library-module-id);


/// Test suite initialization

define variable *test-application* :: false-or(<project-object>) = #f;
define variable *test-library* :: false-or(<project-object>) = #f;

define function root-directory
    () => (directory :: false-or(<string>))
  environment-variable("OPEN_DYLAN_USER_SOURCES")
    | error("Environment variable OPEN_DYLAN_USER_SOURCES is not set")
end function root-directory;

define function test-project-location
    (name :: <string>) => (location :: <locator>)
  let directory = root-directory();
  let location-name
    = format-to-string
        ("%s/%s/%s.hdp",
         directory,
         select (name by \=)
           "environment-test-application" => "environment/tests/test-application";
           "environment-test-library"     => "environment/tests/test-library";
           "cmu-test-suite"               => "testing/cmu-test-suite";
         end,
         name);
  // format-out("project-location: %=\n", location-name);
  as(<file-locator>, location-name);
end function test-project-location;

define function test-project-build (project :: <project-object>, #key link?)
  let progress
    = make(<progress-stream>, inner-stream: *standard-output*);
  build-project(project,
                link?: link?,
                save-databases?: #t,
                error-handler: project-condition-handler,
                progress-callback:
                  method (position :: <integer>, range :: <integer>,
                          #key heading-label, item-label)
                    let label
                      = if (empty?(item-label))
                            heading-label
                          else
                            item-label
                          end if;
                    show-progress(progress, position, range, label: label);
                  end);
  new-line(progress);
end function;

define function open-test-projects () => ()
  let library = open-project(test-project-location($test-library));
  open-project-compiler-database
    (library, error-handler: project-condition-handler);
  let application = open-project(test-project-location($test-application));
  open-project-compiler-database
    (application, error-handler: project-condition-handler);

  test-project-build(application);

  unless (open-project-compiler-database
            (library, error-handler: project-condition-handler))
    parse-project-source(library);
  end unless;
  *test-library* := library;
  unless (open-project-compiler-database
            (application, error-handler: project-condition-handler))
    parse-project-source(application);
  end unless;
  *test-application* := application;
end function open-test-projects;

define function close-test-projects () => ()
  close-project(*test-library*);
  close-project(*test-application*);
end function close-test-projects;

define function project-condition-handler
    (type :: <symbol>, message :: <string>) => ()
  format-out("\nProject warning: type %s: %s\n", type, message)
end function project-condition-handler;


/// Project tests

define test open-projects-test ()
  check-instance?("Application project open",
                  <project-object>, *test-application*);
  check-equal("Application project target type",
              project-target-type(*test-application*),
              #"executable");
  check-equal("Application project interface type",
              project-interface-type(*test-application*),
              #"gui");
  check-equal("Application project name",
              project-name(*test-application*),
              $test-application);
  check-equal("Application project name",
              environment-object-primitive-name
                (*test-application*, *test-application*),
              $test-application);
  check-false("Application project not read-only",
              project-read-only?(*test-application*));
  check-true("Application project can be built",
             project-can-be-built?(*test-application*));
  check-true("Application project can be debugged",
             project-can-be-debugged?(*test-application*));
  check-true("Application project compiled",
             project-compiled?(*test-application*));

  check-instance?("Library project open",
                  <project-object>, *test-library*);
  check-equal("Library project target type",
              project-target-type(*test-library*),
              #"dll");
  check-equal("Library interface target type",
              project-interface-type(*test-library*),
              #"console");
  check-equal("Library project name",
              project-name(*test-library*),
              $test-library);
  check-equal("Library project name",
              environment-object-primitive-name
                (*test-library*, *test-library*),
              $test-library);
  check-false("Library project not read-only",
              project-read-only?(*test-library*));
  check-true("Library project can be built",
             project-can-be-built?(*test-library*));
  check-true("Library project can be debugged",
             project-can-be-debugged?(*test-library*));
  check-true("Library project compiled",
             project-compiled?(*test-library*));
end test open-projects-test;

define test project-libraries-test ()
  let application-lib = project-library(*test-application*);
  check-instance?("Application project library",
                  <library-object>, application-lib);
  check-equal("Application project library project",
              project-filename(*test-application*),
              project-filename(library-project(*test-application*, application-lib)));

  let application-used-libraries
    = project-used-libraries(*test-application*, *test-application*);
  let application-used-library-names
    = map(curry(environment-object-basic-name, *test-application*),
          application-used-libraries);
  // See libraries referenced in test-application/library.dylan
  for (name in #["common-dylan", "duim", "environment-test-library"])
    check-true(format-to-string("Application library uses %s", name),
               member?(name, application-used-library-names, test: \=));
  end for;
end test project-libraries-test;


/// projects suite

define suite projects-suite ()
  test open-projects-test;
  test project-libraries-test;
end suite projects-suite;
