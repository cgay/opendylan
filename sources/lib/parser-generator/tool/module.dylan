Module:    dylan-user
Author:    Keith Dennison
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define module tool-parser-generator
  use common-dylan;
  use simple-debugging, import: { debug-out };
  use date;
  use file-source-records;
  use file-system;
  use format;
  use streams;
  use locators;
  use tools-interface;
  use parser-generator;
end module;

