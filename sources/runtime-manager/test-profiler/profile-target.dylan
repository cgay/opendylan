module:    test-profiler
synopsis:  Class for the profiled app, methods to process & print profile data
author:    Keith Dennison
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

// A <profile-target> is the class which represents the application to be
// profiled.
//
// It includes a table which is used to calculate and store the counts for
// each thread. The table has one entry for each thread which contains a
// <profiler-counter-groups> object for that thread. This object contains
// the counter groups for each of the counts for that thread.
//
// The class has a second table which is used for cacheing the translation
// from instruction pointers to names.
//
define class <profile-target> (<debug-target>)

  // Table for holding the <profiler-counter-groups> objects for each thread.
  // Indexed by <remote-thread> objects.
  slot counter-groups-table :: <table>,
       init-function: method () make (<table>) end;

  // Cache for translating instruction pointers to names. Indexed by <integer>s
  slot ip-name-cache :: <table>, init-function:  method () make (<table>) end;
//  slot cache-lookup :: <integer> = 0;
//  slot cache-miss :: <integer> = 0;

end class;


// Translate an instruction pointer into a name in the target application.
// This method uses a cache for the translation.
//
define method ip-to-name (application :: <profile-target>,
                          ip :: <remote-value>)
                      => (name :: <string>)

    let name = element(application.ip-name-cache, as-integer(ip), default: #f);
    unless (name)
      let ap = debug-target-access-path (application);
      let (nearest, previous, next) = nearest-symbols (ap, ip);
      if (nearest)
        name := remote-symbol-name (nearest);
      elseif (previous)
        name := remote-symbol-name (nearest);
      else
        name := "????";
      end if;
      application.ip-name-cache[as-integer(ip)] := name;
    end unless;
    name
end method;


// Updates the counts for a thread given its profile. A thread's profile
// consists of a sequence of snapshots, each snapshot having a weight based
// on the cpu-time the thread had since the previous snapshot and a sequence
// of instruction pointers associated with the frames on the stack when the
// snapshot was taken.
//
define method update (application, thread-profile) => ()
  let thread = remote-thread (thread-profile);
  let profile-snapshots = profile-snapshot-sequence (thread-profile);

  // Find the profiler-counter-groups for the relevant thread
  let counter-groups = element (application.counter-groups-table, thread,
                                default: #f);

  // If there isn't one for this thread, make one.
  unless (counter-groups)

    // A method which returns a  method for translating instruction pointers
    // to names. This is used when creating the counter groups.
    local method as-name-f (application :: <profile-target>)
      method (ip :: <remote-value>) => (name :: <string>)
        ip-to-name (application, ip)
      end method
    end method;

    // Create a new counter group for each type of count
    let seen-group = make (<counter-group>, as-name: as-name-f (application));
    let top-group = make (<counter-group>, as-name: as-name-f (application));

    // And put them in a new <profiler-counter-groups> object.
    counter-groups := make (<profiler-counter-groups>,
                            seen-on-stack: seen-group,
                            top-of-stack: top-group);
    application.counter-groups-table[thread] := counter-groups;
  end unless;

  // Update the counter groups with each snapshot
  for (snapshot in profile-snapshots)
    update (counter-groups, snapshot)
  end for;
end method;


// Take the data generated by the profiler manager and process it to get the
// counts we are interested in.
//
define method process-profile-data (application)
  let data = profile-data(application);
  for (thread-profile in data)
    update (application, thread-profile);
  end for;
end method;


// Prints the counts calculated for the target application. This should only
// be called after process-profile-data. This function gets the count data
// from the same table process-profile-data uses to generate it. It finds the
// count data for each thread that was profiled, sorts and prints the seen on
// stack and top of stack counts.
//
define method print-profile-results(application :: <profile-target>,
                                    name :: <string>,
                                    interval :: <integer>) => ()

  format-out ("\nResults for %s with profile interval of %dms",
              name, interval);

  for (counter-groups keyed-by thread in application.counter-groups-table)

    let seen-on-stack-group = counter-groups.seen-on-stack;
    let top-of-stack-group = counter-groups.top-of-stack;

    let cs1 = sort-counters (as-counter-sequence (seen-on-stack-group));
    let cs2 = sort-counters (as-counter-sequence (top-of-stack-group));

    format-out ("\n\nData for thread %s:\n\n", thread-name(thread));
    format-out ("Seen on Stack Counts\n");
    format-out ("====================\n\n");
    print-counters (cs1);

    format-out ("\n\nTop of Stack Counts\n");
    format-out ("===================\n\n");
    print-counters (cs2);

  end for;
  format-out ("\n\n");
end method;