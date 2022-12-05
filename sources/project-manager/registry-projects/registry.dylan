Module: registry-projects-internal
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define constant $abstract-host-prefix = "abstract://dylan/";

define function find-library-locator
    (library-name, registries :: <sequence>)
 => (lid-locator :: false-or(<file-locator>),
     registry :: false-or(<registry>));
  let name = as-lowercase(as(<string>, library-name));
  let prefix = $abstract-host-prefix;
  let prefix-size = prefix.size;
  block (return)
    for (registry :: <registry> in registries)
      let locator = file-locator(registry.registry-location, name);
      if (~file-exists?(locator))
        debug-out(#"project-manager", "Failed to find %s in %s",
                  name, locator);
      else
        let location
          = with-open-file (stream = locator)
              read-line(stream)
            end;
        let filename
          = if (starts-with?(location, prefix))
              let root = registry.registry-root;
              let file = as(<posix-file-locator>,
                            copy-sequence(location, start: prefix-size));
              // Can't just merge them as that would produce a POSIX locator...
              let file-parent = locator-directory(file);
              let file-parent-path = file-parent & locator-path(file-parent);
              file-locator(make(<directory-locator>,
                                server: locator-server(root),
                                path: concatenate(locator-path(root) | #[],
                                                  file-parent-path | #[])),
                           locator-name(file))
            else
              as(<file-locator>, location)
            end;
        debug-out(#"project-manager", "Found %s in %s", name, filename);
        return(filename, registry)
      end;
    end;
    values(#f, #f)
  end
end function find-library-locator;
