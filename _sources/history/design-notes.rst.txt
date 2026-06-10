******************
Dylan Design Notes
******************

Copyright © 1993-1994, Apple Computer

Introduction
============

When we released the first edition of the Dylan manual in April, 1992 we invited
feedback.  The Dylan Design Notes, describing changes to the Dylan language design, are a
result of that feedback.

The goal of the Dylan language design process has been to clarify ambiguities, remove
inconsistencies, and increase the efficiency of the language. The overall goal of Dylan
is to better meet the needs of mainstream application programmers.

Each Note describes a single change or new feature of the language. The Dylan Manual and
the Design Notes, taken together, define the Dylan programming language.

We invite your continued feedback.


Design Note Format
------------------

Each Design Note fits into one of the following categories:

* **clarification** -- This Design Note resolves an ambiguity or underspecification in the Dylan manual.
* **change** -- This Design Note specifies an incompatible change.
* **addition** -- This Design Note specifies a compatible extension.

The first section of each Design Note contains the following parts:

* the title of this Note
* the category that this Note fits into
* the version and date of this Design Note
* a one-paragraph summary of the clarification, change, or addition specified by this Note.

The second section of each Design Note contains the language specification itself. This
may be expressed as a change to the text of the manual, or as an independent section. It
often includes examples.

Some Design Notes have an additional section which may include implementation notes,
further examples, or some of our reasons for making the change.

Throughout the Design Notes, the term **parameter** is used to mean formal
parameter. That is, a parameter is a local variable bound upon entry to a function. The
Design Notes use the term argument to describe what is sometimes called an actual
parameter. That is, an argument is an object that is passed as the value of a parameter.

The names of parameters are often descriptive of the type of value acceptable as a value
of the parameter. They will often match the names of classes, indicating a general
instance of the class. For example, number indicates a general instance of the class
<number>, and string indicates a general instance of the class ``<string>``.

The following notation is used to describe syntax forms:

``{...}`` Curly braces indicate a group of items.

``{...}*`` Curly braces followed by an asterisk indicate that the contents can appear
zero or more times.

``{...}+`` Curly braces followed by a plus sign indicate that the contents can appear one
or more times.

``[...]``  Square brackets indicate that the contents are optional.

``...|...`` Items separated by a vertical bar are mutually exclusive. One or the other ma
appear.

We issue the Design Notes in plain text format as well as in PostScript. In the
PostScript format, we use a small number of typographic conventions to enhance
readability:

* Body text appears in Roman.
* First uses of terms appear in **Bold**.
* Text which appears as it would be entered in the computer appears in ``Courier``.
* Formal parameters appear in *Italic*.
* Interactions between a user and a Dylan listener are shown in a mixture of ``Courier``
  and *Courier Oblique*. ``Courier`` shows the text entered by the user, and *Courier
  Oblique* shows the text printed by the listener. The question mark used in these
  sections is the listener's prompt.

The error messages in the Design Notes have been edited for brevity. The details of
interactions with Dylan (prompt text, error message texts, etc.) may differ among
implementations.

Dylan Correspondence
--------------------

Questions and comments about Dylan may be sent to info-dylan@cambridge.apple.com and will
appear on the info-dylan mailing list. Private correspondence may be sent to
dylan-comments@cambridge.apple.com.

To subscribe to the ``info-dylan`` list, send a message to:
info-dylan-request@cambridge.apple.com. The body of the message should read:

  subscribe info-dylan

The ``info-dylan`` mailing list is also available in a digest format.  The digest is put
together and mailed out every morning at 4AM and covers all the mail received by the list
in the last 24 hours.  To subscribe to the digest, send a message to:

  info-dylan-digest-request@cambridge.apple.com

The body of the message should read:

  ``subscribe info-dylan-digest``

If you prefer to read ``info-dylan`` as a Usenet newsgroup, it is available under the
name ``comp.lang.dylan``.

To access the current Dylan FAQ, archived Dylan Design Notes, and other archived Dylan
information, connect by anonymouse ftp to ``cambridge.apple.com``.  Dylan information is
located in the ``/pub/dylan`` directory.

* A text-only version of the Dylan FAQ is in ``dylan-faq.txt``.  A binhex MS Werd version
  of the Dylan FAQ is in ``dylan-faq.msword.hqx``.

* The Dylan Design Notes are archived in the ``design-notes`` directory.  Within the
  ``design notes`` directory, text-only files are in the ``text`` subdirectory, and
  postscript files are in the ``postscript`` subdirectory.

Table of Contents
=================

`#1: Collection Class-For-Copy (Clarification)`_
  This design note clarifies that ``class-for-copy`` of a collection must return a
  mutable collection.

`#2: First, Second, Third, Last Default (Addition)`_
  This design note adds a ``default:`` keyword argument to the specification of the
  functions ``first``, ``second``, ``third``, and ``last``.  This change removes a
  possible source of confusion by making these functions more consistent with the
  function ``element``.

`#3: Make Class Specification (Addition)`_
  This design note gives an expanded specification for ``<class>`` which enables new
  classes to be created at runtime, with ``make``.

`#4: No Incremental Class Modifications (Change)`_
  This design note deletes the functions ``add-slot`` and ``remove-slot``, the setter for
  ``direct-superclasses``, and the macro ``define-slot`` from the Dylan language
  specification.

`#5: Regularization of the Type System (Change)`_
  This design note outlines a more expressive type system for Dylan. Not all types in
  Dylan are classes. For example, singleton types are not classes. The new type system
  allows for a variety of types, including classes and singleton types, and also provides
  a framework for introducing additional types that are not classes.

`#6: Limited Types (Addition)`_
  This design note introduces a new generic function, ``limited``, for constructing
  limited types, and specific methods for creating **limited integer types and limited
  collection types**. For example, ``(limited <integer> min: 0 max: 255)`` and ``(limited
  <array> of: <single-float>)`` are useful types.

`#7: Union Types (Addition)`_
  This design note introduces a new facility for creating a **union type** as a union of
  two other types. Union types are useful as slot specializers, and describe the return
  types of many common functions. For example, ``(union <integer> (singleton #f))``
  describes the return type of ``size``.

`#8: Method Dispatch Ambiguity (Clarification)`_
  Sometimes it is not clear which of two methods is the most specific for a particular
  function call.  This is a particular problem for non-class types because it is possible
  for an object to be an instance of two disjoint types, such as ``(limited <integer>
  min: 0)`` and ``(limited <integer> max : 10)``. This design note requires Dylan to
  signal an error in such cases.

`#9: Punt Slot Descriptors (Change)`_
  This design note deletes Dylan's specification of slot descriptors. This change removes
  a feature which is incomplete, which does not match our current goals, and which
  impedes efficiency.

`#10: Element-Setter Signals Error (Clarification)`_
  It is an error if ``element-setter`` cannot successfully set the element of a
  sequence. This design note requires an error to be signaled in that case, preventing
  programs from silently returning an incorrect result or otherwise failing.

`#11: Last-Setter (Addition)`_
  This design note adds a specification for the generic function ``last-setter``,
  consistent with the setters for ``first``, ``second``, ``third``, and ``element``.

`#12: Size-Setter for Stretchy Sequences (Addition)`_
  This design note adds the generic function ``size-setter`` to the language
  specification, allowing the size of a stretchy sequence to be changed in a single
  operation.

`#13: Type Restrictions Survive Assignment (Change)`_
  When a parameter or local variable is specialized, its initial value is required to be
  an instance of a ccrtain type. This design note extends the type restriction to cover
  values later stored into the specialized parameter or local variable.

`#14: Union Allows Duplicates (Clarification)`_
  This design note clarifies that the result of ``union`` is only guaranteed free of
  duplicates if no element appears more than once in a single argument sequence. If the
  same element appears more than once in a single argument sequence, it may appear more
  than once in the result sequence. This allows ``union`` to be implemented more
  efficiently.

`#15: Replace-Subsequence! Different Sizes (Change)`_
  This design note extends the definition of ``replace-subsequence!`` to allow the old
  and new subsequences to have different sizes. This change greatly increases the utility
  of ``replace-subsequence!``, enabling it to be used for replace, insert and delete
  operations over any sequence.

`#16: List Issues (Change)`_
  In this design note, Dylan's specification of the `<list>` type is made more consistent
  with the rest of the language, mysterious abbreviations and redundant list-only
  operations are removed, and handling of improper lists is clarified. These changes make
  the language more accessible to our primary audience of programmers who have not used
  dynamic languages before.

`#17: Define Like Bind (Addition)`_
  This design note unifies the behavior of ``bind`` and ``define``. It extends ``define``
  to support declaring the types of module variables and defining multiple module
  variables from multiple values.

`#18: Member? Intersection Test Arg (Clarification)`_
  This design note clarifies that the ``<range>`` methods for ``member?`` and
  ``intersection`` support a ``test:`` keyword argument, which defaults to ``id?``. This
  makes the ``<range>`` methods consistent with the definitions for these generic
  functions.

`#19: Definitions are Declarative (Change)`_
  This design note distinguishes definitions from other syntax forms, making module
  variable definition essentially a declarative operation, not a procedural
  one. Definitions are restricted to appear only at the top level. A given module
  variable can only be defined once, except for multiple ``define-method`` definitions
  with different specializers. Definitions do not return values, since they cannot appear
  as argument expressions.

`#20: New Syntax for Setter Variables (Change)`_
  This design note changes the syntax for setter variables. In the revised syntax, the
  setter corresponding to the getter ``foo`` is named ``foo-setter`` rather than
  ``(setter foo)``. This removes the special case syntax for setters so that all
  variable names are symbols.

`#21: Result Type Declarations (Addition)`_
  This design note introduces a way to declare the result types of methods and generic
  functions. This addition is intended to make code more self-documenting and allow for
  better compiler optimization. Type declarations will be checked at run time unless they
  can be proven at compile time to be satisfied always.

`#22: BNF for Infix Dylan (Change)`_
  This document presents a preliminary specification of the lexical and syntactic aspects
  of Dylan.

`#23: Defining Forms Make Constants (Change)`_
  This design note makes ``define-method`` more consistent with
  ``define-generic-function``. It also provides general declarative forms for defining
  constants and variables.

`#24: Divide by Zero Signals Error (Clarification)`_
  This design note specifies that division by zero signals an error. This makes Dylan
  programs safer and more robust, possibly at the cost of speed in some cases.

`#25: Exit Extent (Change)`_
  Interactions between ``bind-exit`` and ``unwind-protect`` are complicated, especially
  when a non-local exit is taken during the execution of an ``unwind-protect`` cleanup
  form. This design note replaces ``bind-exit`` and ``unwind-protect`` with a new
  ``block`` construct, and clarifies Dylan's behavior.

`#26: New Iteration Protocol (Change)`_
  This Design Note specifies a revised iteration protocol for Dylan. The new iteration
  protocol is complex, but allows better performance than the original
  specification. Note that the iteration protocol is intended to be used primarily by
  creators of new collection classes, rather than by users of collections. In practice,
  most iterations will be hidden inside ``for`` and the other standard iteration
  functions.

`#27: Pseudo-Generic Mappers (Change)`_
  This design note changes the functions that iterate over an arbitrary number of
  collections to be functions rather than generic functions. The affected functions are:
  ``do``, ``map``, ``map-as``, ``map-into``, ``any?``, ``every?``, ``concatenate``, and
  ``concatenate-as``.

`#28: First, Second, Third are Functions (Change)`_
  The functions ``first``, ``second``, ``third``, and their associated setter functions
  are specified as generic functions on sequences. This design note changes them to
  functions.

`#29: For Loops (Change)`_
  This Design Note unifies Dylan's existing iteration constructs, ``for``, ``for-each``,
  and ``dotimes``, into one general ``for`` statement. It also changes the keywords in
  ``<range>`` to be compatible with the numeric clauses in the new ``for`` statement.

`#30: Make Range (Change)`_
  This design note defines ``(make <range> ...)`` to create a range.

`#31: Method Specificity`_
  This Design Note gives a revised specification of Dylan's handling of method
  specificity.

`#32: Module Defining Forms (Addition)`_
  This Design Note specifies a syntax and semantics for module defining forms, which
  further documents the description of modules found in the Dylan book.

`#33: Headers for Dylan Source Files (Addition)`_
  This design note specifies a standard portable format for distributing Dylan source
  code.

`#34: Select Ordering (Clarification)`_
  This design note specifies the order of evaluation for the ``select`` statement.

`#35: Remove Transcendental Functions (Change)`_
  This design note removes the functions ``sin``, ``cos``, ``tan``, ``asin``, ``acos``,
  ``atan``, ``cosh``, ``tan``, ``asinh``, ``acosh``, ``atanh``, ``exp``, ``log``, and
  ``sqrt`` from core Dylan.

`#36: Remove Trivial Logical Operators (Change)`_
  This design note removes the logical operators ``logeqv``, ``lognand``, ``lognor``,
  ``logandc1``, ``logandc2``, ``logorc1``, and ``logorc2`` from core Dylan.

`#37: Variadic Operators (Change)`_
  The presence of separate binary and variadic versions of some functions complicates the
  Dylan language.  This design note removes several variadic operators that are no longer
  needed in infix Dylan, and renames the binary versions of those operators.

#1: Collection Class-For-Copy (Clarification)
=============================================

Version 1, March 1993 Copyright © 1993-1994, Apple Computer

This design note clarifies that ``class-for-copy`` of a collection must return a mutable
collection.

Replace the definition of ``class-for-copy`` on page 100 of the Dylan manual with the following:

**class-for-copy** *collection* => *class* [G.F. Method]
  ``class-for-copy`` returns an appropriate collection class for creating mutable copies
  of the argument. For collections that are already mutable, the collection's actual
  class is generally the most appropriate, so the ``<object>`` method of
  ``class-for-copy`` can be used. The ``class-for-copy`` value of a sequence should be a
  subclass of ``<sequence>``, and the ``class-for-copy`` value of an
  explicit-key-collection should be a subclass of ``<explicit-key-collection>``. In all
  cases, the ``class-for-copy`` value must be a mutable collection.

**Notes:**

The restriction on ``class-for-copy`` for collections is needed to keep the collection
protocol relatively simple.  Implementations do not need to check for this
explicitly. Many built-in functions however, break if the restriction is not observed.


#2: First, Second, Third, Last Default (Addition)
=================================================

Version 1, March 1993 Copyright © 1993-1994, Apple Computer

This design note adds a ``default:`` keyword argument to the specification of the
functions ``first``, ``second``, ``third``, and ``last``. This change removes a possible
source of confusion by making these functions more consistent with the function
``element``.

----

Add a ``default:`` keyword argument to the functions ``first``, ``second``, ``third``,
and ``last``. Change the description of ``first``, ``second``, and ``third`` on page 110
of the Dylan manual to read as follows:

  Each of these functions returns the indicated element of the sequence. If the sequence
  is too short to contain such an element, then the behavior depends on whether the
  default argument was supplied. If the default argument was supplied, its value is
  returned; otherwise, an error is signaled.

Replace the second sentence of the description of last on page 110 of the manual with the
following:

  If the sequence is empty, then the behavior of ``last`` depends on whether it was
  called with a *default* argument. If the *default* argument was supplied, its value is
  returned; otherwise, an error is signaled.

**Notes:**

Many implementations will want to compile away the keyword argument. However, they should
already have technology to do this for the implementation of ``element``, so there isn't
much added cost here.

This design note does not address the behavior of ``last`` on unbounded sequences,
including the effect of the ``default:`` keyword when ``last`` is called on unbounded
sequences.

#3: Make Class Specification (Addition)
=======================================

Version 1, March 1993 Copyright © 1993-1994, Apple Computer

This design note gives an expanded specification for ``<class>`` which enables new
classes to be created at runtime, with ``make``.

Replace the specification of ``<class>`` on page 91 of the Dylan manual with the following:

**<class>** [Abstract Class]
  All classes (including ``<class>``) are general instances of ``<class>``. ``<class>``
  is a subclass of ``<type>``. In most programs the majority of classes are created with
  ``define-class``. However, there is nothing to prevent programmers from creating
  classes by calling ``make``, for example, if they want to create a class without
  storing it in a module variable, or if they want to create new classes at runtime.

The class ``<class>`` supports the following init-keywords:

+--------------------+------------------------------------------------------------+
| ``superclasses:``  |Specifies the direct superclasses of the *class*.           |
|                    |``superclasses:`` should be a class or a sequence of        |
|                    |classes. The default value is ``<object>``. The meaning of  |
|                    |the order of the superclasses is the same as in             |
|                    |``define-class``.                                           |
+--------------------+------------------------------------------------------------+
|``debug-name:``     |Used only for debugging and display purposes. The default is|
|                    |implementation-dependent.                                   |
+--------------------+------------------------------------------------------------+
|``slots:``          |A sequence of slot specs, where each slot-spec is a sequence|
|                    |of keyword/value pairs.                                     |
|                    |                                                            |
|                    |The following keywords and corresponding values are accepted|
|                    |by all implementations. Implementations may also define     |
|                    |additional keywords and values for use within slot specs.   |
|                    |                                                            |
|                    |- ``getter:`` A generic function of one argument. Unless the|
|                    |  allocation of the slot is virtual, the getter method for  |
|                    |  the slot will be added to this generic function. This     |
|                    |  option is required.                                       |
|                    |                                                            |
|                    |- ``setter:`` A generic function of two arguments. Unless   |
|                    |  the allocation of the slot is virtual, the setter method  |
|                    |  for the slot will be added to this generic function. There|
|                    |  is no default.                                            |
|                    |                                                            |
|                    |- ``type:`` A type. Values stored in the slot are restricted|
|                    |  to be of this type. The default value for this option is  |
|                    |  ``<object>``.                                             |
+--------------------+------------------------------------------------------------+

