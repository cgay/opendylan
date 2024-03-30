**********************
The file-system Module
**********************

.. current-library:: system
.. current-module:: file-system

The File-System module is part of the System library and provides a
generic interface to the file system of the local machine. Remotely
mounted file systems are also accessible using this module.

.. contents::

Types specific to file system operations
----------------------------------------

The File-System module contains a number of types specifically designed
for use by interfaces in the module.

- :type:`<file-type>`
- :type:`<pathname>`
- :type:`<copy/rename-disposition>`

Manipulating files
------------------

The File-System module contains a number of interfaces that let you
perform standard file management operations on files already resident on
the filesystem. You can rename, copy, or delete any file, and you can
set any available properties for the file.

- :func:`copy-file`
- :func:`delete-file`
- :func:`rename-file`
- :func:`file-property-setter`

Manipulating directories
------------------------

The File-System module contains a number of interfaces that let you
create and delete directories. These can be used in conjunction with the
file manipulation operations described in `Manipulating files`_ to
perform file management tasks at any position in the file system.

- :func:`create-directory`
- :func:`delete-directory`
- :func:`ensure-directories-exist`
- :func:`do-directory`
- :func:`working-directory-setter`

Finding out file system information
-----------------------------------

A number of functions return environment information regarding the
directory structure of the file system. Each function takes no
arguments, and returns a pathname or list of pathnames. The return
values can be use in conjunction with other functions to perform
file-based operations relative to the directories involved.

- :func:`home-directory`
- :func:`root-directories`
- :func:`temp-directory`
- :func:`working-directory`

Finding out file information
----------------------------

Several interfaces in the File-System module allow you to interrogate
files for information. You can find out whether a file exists, what its
name is, or which directory it resides in, and you can find the current
properties of the file.

- :func:`file-exists?`
- :func:`file-properties`
- :func:`file-property`
- :func:`file-type`

The FILE-SYSTEM module
----------------------

This section contains a reference entry for each item included in the
File-System module.

.. function:: copy-file

   Creates a copy of a file.

   :signature: copy-file *old-file* *new-file* #key *if-exists* => ()

   :parameter old-file: An instance of :type:`<pathname>`.
   :parameter new-file: An instance of :type:`<pathname>`.
   :parameter #key if-exists: An instance of
     :type:`<copy/rename-disposition>`. Default value: ``#"signal"``.

   :description:

     Copies *old-file* to *new-file*. If *new-file* already exists, the
     action of this function is controlled by the value of *if-exists*. The
     default is to prompt you before overwriting an existing file.

   :seealso:

     - :type:`<copy/rename-disposition>`
     - :class:`rename-file`

.. type:: <copy/rename-disposition>

   The type that represents possible actions when overwriting existing
   files.

   :equivalent: ``one-of(#"signal", #"replace")``

   :description:

     This type represents the acceptable values for the *if-exists:*
     argument to the :func:`copy-file` and :func:`rename-file`
     functions. Only two values are acceptable:

     -  If ``#"signal"`` is used, then you are warned before a file is
        overwritten during a copy or move operation.
     -  If ``#"replace"`` is used, then you are not warned before a file is
        overwritten during a copy or move operation.

   :operations:

     - :func:`copy-file`
     - :func:`rename-file`

   :seealso:

     - :func:`copy-file`
     - :func:`rename-file`

.. function:: create-directory

   Creates a new directory in the specified parent directory.

   :signature: create-directory *parent* *name* => *directory*

   :parameter parent: An instance of :type:`<pathname>`.
   :parameter name: An instance of :drm:`<string>`.
   :value directory: An instance of :type:`<pathname>`.

   :description:

     Creates *directory* in the specified *parent* directory. The return
     value of this function can be used with :drm:`concatenate` to
     create pathnames of entities in the new directory.

   :seealso:

     - :func:`delete-directory`

.. function:: delete-directory

   Deletes the specified directory.

   :signature: delete-directory *directory* #key *recursive?* => ()

   :parameter directory: An instance of :type:`<pathname>`.
   :parameter #key recursive?: An instance of :type:`<boolean>`.
                               Default value: ``#f``

   :description:

     Deletes the specified directory. By default the directory may
     only be deleted if it is empty. Pass ``recursive?: #t`` to delete
     the directory and its contents recursively.

   :seealso:

     - :func:`create-directory`
     - :func:`delete-file`

.. function:: delete-file

   Deletes the specified file system entity.

   :signature: delete-file *file* => ()

   :parameter file: An instance of :type:`<pathname>`.

   :description:

     Deletes the file system entity specified by *file*. If *file*
     refers to a link, the link is removed, but the actual file that the
     link points to is not removed.

.. function:: do-directory

   Executes the supplied function once for each entity in the specified
   directory.

   :signature: do-directory *function* *directory* => ()

   :parameter function: An instance of :drm:`<function>`.
   :parameter directory: An instance of :type:`<pathname>`.

   :description:

     Executes *function* once for each entity in *directory*.

     The signature of *function* is::

       *function* *directory* *name* *type* => ()

     where *directory* is an instance of :type:`<pathname>`, *name* is
     an instance of :drm:`<byte-string>`, and *type* is an instance of
     :type:`<file-type>`.

     Within *function*, the values of *directory* and *name* can be
     concatenated to generate a :type:`<pathname>` suitable for use by
     the other functions in the module.

     The following calls are equivalent:

     .. code-block:: dylan

       do-directory(my-function, "C:\\USERS\\JOHN\\FOO.TEXT")

       do-directory(my-function, "C:\\USERS\\JOHN\\")

     as they both operate on the contents of ``C:\\USERS\\JOHN``. The call:

     .. code-block:: dylan

       do-directory(my-function, "C:\\USERS\\JOHN")

     is not equivalent as it will operate on the contents of ``C:\\USERS``.

.. function:: ensure-directories-exist

   Ensures that all the directories in the pathname leading to a file
   exist, creating any that do not, as needed.

   :signature: ensure-directories-exist *file* => *created?*

   :parameter file: An instance of :type:`<pathname>`.
   :value created?: An instance of :drm:`<boolean>`.

   :description:

     Ensures that all the directories in the pathname leading to a file
     exist, creating any that do not, as needed. The return value
     indicates whether or not any directory was created.

     The following calls are equivalent:

     .. code-block:: dylan

       ensure-directories-exist("C:\\USERS\\JOHN\\FOO.TEXT")
       ensure-directories-exist("C:\\USERS\\JOHN\\")

     as they will both create the directories *USERS* and *JOHN* if needed.
     The call:

     .. code-block:: dylan

       ensure-directories-exist("C:\\USERS\\JOHN")

     is not equivalent as it will only create *USERS* if needed.

   :example:

     .. code-block:: dylan

       ensure-directories-exist("C:\\USERS\\JOHN\\FOO.TEXT")

   :seealso:

     - :func:`create-directory`

.. function:: file-exists?

   Returns ``#t`` if the specified file exists.

   :signature: file-exists? *file* => *exists?*

   :parameter file: An instance of :type:`<pathname>`.
   :value exists?: An instance of :drm:`<boolean>`.

   :description:

     Returns ``#t`` if *file* exists. If it refers to a link, the target
     of the link is checked.

.. function:: file-properties

   Returns all the properties of a file system entity.

   :signature: file-properties *file* => *properties*

   :parameter file: An instance of :type:`<pathname>`.
   :value properties: An instance of a concrete subclass of
     :drm:`<explicit-key-collection>`.

   :description:

     Returns all the properties of *file*. The keys to the properties
     collection are the same as those use by :gf:`file-property`, above.

   :example:

     .. code-block:: dylan

       file-properties() [#"size"]

   :seealso:

     - :gf:`file-property`
     - :func:`file-property-setter`

.. generic-function:: file-property
   :sealed:

   Returns the specified property of a file system entity.

   :signature: file-property *file* #key *key* => *property*

   :parameter file: An instance of :type:`<pathname>`.
   :parameter #key key: One of ``#"author"``, ``#"size"``,
     ``#"creation-date"``, ``#"access-date"``, ``#"modification-date"``,
     ``#"readable?"``, ``#"writeable?"``, ``#"executable?"``.
   :value property: The value of the property specified by *key*. The
     type of the value returned depends on the value of *key*: see the
     description for details.

   :description:

     Returns the property of *file* specified by *key*. The value
     returned depends on the value of *key*, as shown in Table :ref:`Return
     value types of file-property <file-property-return-value-types>`.

     .. _file-property-return-value-types:
     .. table:: Return value types of ``file-property``

       +--------------------------+-------------------------------+
       | Value of *key*           | Type of return value          |
       +==========================+===============================+
       | ``#"author"``            | ``false-or(<string>)``        |
       +--------------------------+-------------------------------+
       | ``#"size"``              | :drm:`<integer>`              |
       +--------------------------+-------------------------------+
       | ``#"creation-date"``     | :class:`<date>`               |
       +--------------------------+-------------------------------+
       | ``#"access-date"``       | :class:`<date>`               |
       +--------------------------+-------------------------------+
       | ``#"modification-date"`` | :class:`<date>`               |
       +--------------------------+-------------------------------+
       | ``#"readable?"``         | :drm:`<boolean>`              |
       +--------------------------+-------------------------------+
       | ``#"writeable?"``        | :drm:`<boolean>`              |
       +--------------------------+-------------------------------+
       | ``#"executable?"``       | :drm:`<boolean>`              |
       +--------------------------+-------------------------------+

     Not all platforms implement all of the above keys. Some platforms
     may support additional keys. The ``#"author"`` key is supported on
     all platforms but may return ``#f`` if it is not meaningful on a
     given platform. Use of an unsupported key signals an error.

     All keys listed above are implemented by Win32, though note that
     ``#"author"`` always returns ``#f``.

   :seealso:

     - :gf:`file-property-setter`
     - :func:`file-properties`

.. generic-function:: file-property-setter
   :sealed:

   Sets the specified property of a file system entity to a given value.

   :signature: file-property-setter *new-value* *file* *key* => *new-value*

   :parameter new-value: The type of this depends on the value of *key*.
     See the description for details.
   :parameter file: An instance of :type:`<pathname>`.
   :parameter key: One of ``#"author"``, ``#"size"``,
     ``#"creation-date"``, ``#"access-date"``, ``#"modification-date"``,
     ``#"readable?"``, ``#"writeable?"``, ``#"executable?"``.
   :value new-value: The type of this depends on the value of *key*. See
     the description for details.

   :description:

     Sets the property of *file* specified by *key* to *new-value*. The type
     of *new-value* depends on the property specified by key, as shown in
     Table :ref:`New value types of file-property-setter
     <file-property-setter-return-value-types>` below.

     .. _file-property-setter-return-value-types:
     .. table:: New value types of *file-property-setter*

       +--------------------------+-------------------------------+
       | Value of *key*           | Type of *new-value*           |
       +==========================+===============================+
       | ``#"author"``            | ``false-or(<string>)``        |
       +--------------------------+-------------------------------+
       | ``#"size"``              | :drm:`<integer>`              |
       +--------------------------+-------------------------------+
       | ``#"creation-date"``     | :class:`<date>`               |
       +--------------------------+-------------------------------+
       | ``#"access-date"``       | :class:`<date>`               |
       +--------------------------+-------------------------------+
       | ``#"modification-date"`` | :class:`<date>`               |
       +--------------------------+-------------------------------+
       | ``#"readable?"``         | :drm:`<boolean>`              |
       +--------------------------+-------------------------------+
       | ``#"writeable?"``        | :drm:`<boolean>`              |
       +--------------------------+-------------------------------+
       | ``#"executable?"``       | :drm:`<boolean>`              |
       +--------------------------+-------------------------------+

     Note that *file-property-setter* returns the value that was set, and so
     return values have the same types as specified values, depending on the
     value of *key*.

     Not all platforms implement all of the above keys. Some platforms may
     support additional keys. Use of an unsupported key signals an error.

     The only property that can be set on Win32 is ``#"writeable?"``.

   :seealso:

     - :gf:`file-property`
     - :func:`file-properties`

.. class:: <file-system-error>

   Error type signaled when any other functions in the File-System
   module signal an error.

   :superclasses: :drm:`<error>`, :class:`<simple-condition>`

   :description:

     Signalled when one of the file system functions triggers an error,
     such as a permissions error when trying to delete or rename a file.


.. function:: file-type

   Returns the type of the specified file system entity.

   :signature: file-type *file* => *file-type*

   :parameter file: An instance of :type:`<pathname>`.
   :value file-type: An instance of :type:`<file-type>`.

   :description:

     Returns the type of *file*, the specified file system entity. A
     file system entity can either be a file, a directory, or a link to
     another file or directory.

.. type:: <file-type>

   The type representing all possible types of a file system entity.

   :equivalent: ``one-of(#"file", #"directory", #"link")``

   :description:

     The type representing all possible types of a file system entity.
     An entity on the file system can either be a file, a directory or
     folder, or a link to another file or directory. The precise
     terminology used to refer to these different types of entity
     depends on the operating system you are working in.

   :operations:

     - :func:`do-directory`

.. function:: home-directory

   Returns the current value of the home directory.

   :signature: home-directory () => *home-directory*

   :value home-directory: An instance of :type:`<pathname>`.

   :description:

     Returns the current value of the home directory. The return value
     of this function can be used with concatenate to create pathnames
     of entities in the home directory.

.. type:: <pathname>

   The type representing a file system entity.

   :equivalent: ``type-union(<string>, <file-system-locator>)``

   :description:

     A type that identifies a file system entity. This can be either a
     :drm:`<string>` or a :class:`<file-system-locator>`.

   :operations:

     - :func:`copy-file`
     - :func:`create-directory`
     - :func:`delete-directory`
     - :func:`delete-file`
     - :func:`do-directory`
     - :func:`ensure-directories-exist`
     - :func:`file-exists?`
     - :func:`file-properties`
     - :func:`file-property`
     - :func:`file-property-setter`
     - :func:`file-type`
     - :func:`home-directory`
     - :func:`rename-file`

.. function:: rename-file

   Renames a specified file.

   :signature: rename-file *old-file* *new-file* #key *if-exists* => ()

   :parameter old-file: An instance of :type:`<pathname>`.
   :parameter new-file: An instance of :type:`<pathname>`.
   :parameter if-exists: An instance of
     :type:`<copy/rename-disposition>`. Default value: ``#"signal"``.

   :description:

     Renames *old-file* to *new-file*. If *new-file* already exists, the
     action of this function is controlled by the value of *if-exists*.
     The default is to prompt you before overwriting an existing file.

     This operation may fail if the source and destination are not on
     the same file system.

   :seealso:

     - :func:`copy-file`
     - :type:`<copy/rename-disposition>`

.. function:: root-directories

   Returns a sequence containing the pathnames of the root directories of
   the file systems on the local machine.

   :signature: root-directories () => *roots*

   :value roots: An instance of :drm:`<sequence>`.

   :description:

     Returns a sequence containing the pathnames of the root directories
     of the file systems on the local machine.

.. function:: temp-directory

   Returns the pathname of the temporary directory in use.

   :signature: temp-directory () => *temp-directory*

   :value temp-directory: An instance of :type:`<pathname>`, or false.

   :description:

     Returns the pathname of the temporary directory in use. The return
     value of this function can be used with :drm:`concatenate` to
     create pathnames of entities in the temporary directory. If no
     temporary directory is defined, ``temp-directory`` returns ``#f``.
     On Windows the temporary directory is specified by the ``TMP``
     environment variable.

.. function:: working-directory

   Returns the working directory for the current process.

   :signature: working-directory () => *working-directory*

   :value working-directory: An instance of :type:`<pathname>`.

   :description:

     Returns the :type:`<pathname>` of the current working directory in
     the current process on the local machine. You can use the return
     value of ``working-directory`` in conjunction with
     :drm:`concatenate` to specify pathnames of entities in the working
     directory.

   :seealso:

     - :func:`working-directory-setter`

.. function:: working-directory-setter

   Sets the working directory for the current process.

   :signature: working-directory-setter *directory* => *directory*

   :parameter directory: An instance of :type:`<pathname>`.
   :value directory: An instance of :type:`<pathname>`.

   :description:

     Sets the working directory for the current process.

     Note that the following calls are equivalent

     .. code-block:: dylan

       working-directory() := "C:\\USERS\\JOHN\\FOO.TEXT";
       working-directory() := "C:\\USERS\\JOHN\\";

     as they will both set the working directory to *C:\\USERS\\JOHN*. The
     call

     .. code-block:: dylan

       working-directory() := "C:\\USERS\\JOHN";

     is not equivalent as it sets the working directory to *C:\\USERS*.

   :example:

     .. code-block:: dylan

       working-directory() := "C:\\USERS\\JOHN\\";

   :seealso:

     - :func:`working-directory`
