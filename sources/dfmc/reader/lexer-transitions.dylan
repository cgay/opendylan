Module:   dfmc-reader
Synopsis: The state transitions of the Dylan lexer.
Author:   CMU, adapted by Keith Playford
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

// Derived from CMU code.
//
// Copyright (c) 1994  Carnegie Mellon University
// All rights reserved.

define constant $ascii-8-bit-extensions
  = as(<string>, vector(as(<character>, 128), '-', as(<character>, 255)));

// Build the state graph and save the initial state.
// Note that transition strings support ranges, like "A-Z".
// Note that string literals allow tabs in order to detect them and give
// a better warning message later.
//
define constant $initial-state :: <state>
  = compile-state-machine
      (state(#"start", #f,
             #(" \t\f\r" . #"whitespace"),
             #('\n' . #"newline"),
             #('/' . #"slash"),
             #('#' . #"sharp"),
             #('(' . #"lparen"),
             #(')' . #"rparen"),
             #(',' . #"comma"),
             #('.' . #"dot"),
             #(';' . #"semicolon"),
             #('[' . #"lbracket"),
             #(']' . #"rbracket"),
             #('{' . #"lbrace"),
             #('}' . #"rbrace"),
             #(':' . #"colon"),
             #('-' . #"minus"),
             #('=' . #"equal"),
             #('?' . #"question"),
             #('\\' . #"backslash"),
             #('+' . #"plus"),
             #('~' . #"tilde"),
             #("*^&|" . #"operator-graphic"),
             #("<>" . #"operator-graphic-pre-equal"),
             #("!%@" . #"leading-graphic"),
             // #("!%@_" . #"leading-graphic"),
             #("$" . #"leading-dollar"),
             #("_" . #"leading-underscore"),
             #("A-Za-z" . #"symbol"),
             #('\'' . #"quote"),
             #('"' . #"double-quote"),
             #("0-9" . #"decimal")),
       state(#"whitespace", #"whitespace",
             #(" \t\f\r" . #"whitespace")),
       state(#"newline", #"newline"),
       state(#"slash", make-binary-operator,
             #('/' . #"double-slash"),
             #('*' . #"slash-star")),
       state(#"double-slash", #"end-of-line-comment"),
       state(#"slash-star", #"multi-line-comment"),
       state(#"sharp", #f,
             #('(' . #"sharp-paren"),
             #('[' . #"sharp-bracket"),
             #('{' . #"sharp-brace"),
             #('#' . #"sharp-sharp"),
             #('"' . #"sharp-double-quote"),
             #(':' . #"sharp-colon"),
             #("bB" . #"sharp-b"), // binary
             #("oO" . #"sharp-o"), // octal
             #("xX" . #"sharp-x"), // hex
             #("tT" . #"true"),
             #("fF" . #"false"),
             #("nN" . #"sharp-n"), // #next
             #("rR" . #"sharp-r"), // #rest, #r"...", #r"""..."""
             #("kK" . #"sharp-k"), // #key
             #("aA" . #"sharp-a")  // #all-keys
             /* CMU
             , #("eE" . #"sharp-e"),
             #("iI" . #"sharp-i")
             */
            ),
       state(#"sharp-paren", fragment-builder(<hash-lparen-fragment>)),
       state(#"sharp-bracket", fragment-builder(<hash-lbracket-fragment>)),
       state(#"sharp-brace", fragment-builder(<hash-lbrace-fragment>)),
       state(#"sharp-sharp", fragment-builder(<hash-hash-fragment>)),

       state(#"sharp-colon", #f,
             #("a-zA-Z" . #"sharp-colon-alphabetic"),
             #("0-9!&*<>|^$%@_" . #"sharp-colon-non-alphabetic")),
       state(#"sharp-colon-alphabetic", #f,
             #(':' . #"sharp-colon-done"),
             #("a-zA-Z0-9!&*<>|^$%@_+~?/=-" . #"sharp-colon-alphabetic")),
       state(#"sharp-colon-non-alphabetic", #f,
             #("0-9!&*<>|^$%@_+~?/=-" . #"sharp-colon-non-alphabetic"),
             #("a-zA-Z" . #"sharp-colon-1alpha")),
       state(#"sharp-colon-1alpha", #f,
             #("a-zA-Z" . #"sharp-colon-alphabetic"),
             #("0-9!&*<>|^$%@_+~?/=-" . #"sharp-colon-non-alphabetic")),
       state(#"sharp-colon-done", make-hash-literal),

       state(#"true", fragment-builder(<true-fragment>)),
       state(#"false", fragment-builder(<false-fragment>)),
       state(#"sharp-n", #f, #("eE" . #"sharp-ne")),
       state(#"sharp-ne", #f, #("xX" . #"sharp-nex")),
       state(#"sharp-nex", #f, #("tT" . #"sharp-next")),
       state(#"sharp-next", fragment-builder(<hash-next-fragment>)),
       state(#"sharp-r", #f,
             #("eE" . #"sharp-re"),
             #('"' . #"raw-string-start")),
       state(#"sharp-re", #f, #("sS" . #"sharp-res")),
       state(#"sharp-res", #f, #("tT" . #"sharp-rest")),
       state(#"sharp-rest", fragment-builder(<hash-rest-fragment>)),
       state(#"sharp-k", #f, #("eE" . #"sharp-ke")),
       state(#"sharp-ke", #f, #("yY" . #"sharp-key")),
       state(#"sharp-key", fragment-builder(<hash-key-fragment>)),
       state(#"sharp-a", #f, #("lL" . #"sharp-al")),
       state(#"sharp-al", #f, #("lL" . #"sharp-all")),
       state(#"sharp-all", #f, #('-' . #"sharp-all-")),
       state(#"sharp-all-", #f, #("kK" . #"sharp-all-k")),
       state(#"sharp-all-k", #f, #("eE" . #"sharp-all-ke")),
       state(#"sharp-all-ke", #f, #("yY" . #"sharp-all-key")),
       state(#"sharp-all-key", #f, #("sS" . #"sharp-all-keys")),
       state(#"sharp-all-keys", fragment-builder(<hash-all-keys-fragment>)),

       state(#"sharp-double-quote", #f,
             #('"' . #"sharp-2-double-quotes"),
             #('\\' . #"quoted-symbol-escape"),
             #("\t !#-[]-~" . #"quoted-symbol"),
             pair($ascii-8-bit-extensions, #"quoted-symbol")),
       state(#"sharp-2-double-quotes", make-quoted-symbol,
             #('"' . #"3quoted-symbol")),
       state(#"quoted-symbol", #f,
             #('"' . #"quoted-symbol-end"),
             #('\\' . #"quoted-symbol-escape"),
             #("\t !#-[]-~" . #"quoted-symbol"),
             pair($ascii-8-bit-extensions, #"quoted-symbol")),
       state(#"quoted-symbol-escape", #f,
             #("\\abefnrt0\"" . #"quoted-symbol"),
             #('<' . #"quoted-symbol-escape-less")),
       state(#"quoted-symbol-escape-less", #f,
             #("0-9a-fA-F" . #"quoted-symbol-hex-digits")),
       state(#"quoted-symbol-hex-digits", #f,
             #("0-9a-fA-F" . #"quoted-symbol-hex-digits"),
             #('>' . #"quoted-symbol")),
       state(#"quoted-symbol-end", make-quoted-symbol),
       state(#"3quoted-symbol", #f,
             #('"' . #"3quoted-symbol-double-quote"),
             #("\r\n\t !#-[]-~" . #"3quoted-symbol"),
             #('\\' . #"3quoted-symbol-escape")),
       state(#"3quoted-symbol-escape", #f,
             #("\\abefnrt0\"" . #"3quoted-symbol"),
             #('<' . #"3quoted-symbol-escape-less")),
       state(#"3quoted-symbol-escape-less", #f,
             #("0-9a-fA-F" . #"3quoted-symbol-hex-digits")),
       state(#"3quoted-symbol-hex-digits", #f,
             #("0-9a-fA-F" . #"3quoted-symbol-hex-digits"),
             #('>' . #"3quoted-symbol")),
       state(#"3quoted-symbol-double-quote", #f,
             #('"' . #"3quoted-symbol-2-double-quotes"),
             #("\r\n\t !#-[]-~" . #"3quoted-symbol")),
       state(#"3quoted-symbol-2-double-quotes", #f,
             #('"' . #"3quoted-symbol-end"),
             #("\r\n\t !#-[]-~" . #"3quoted-symbol")),
       state(#"3quoted-symbol-end", make-multi-line-quoted-symbol),

       state(#"sharp-b", #f,
             #("01" . #"binary-integer")),
       state(#"binary-integer", parse-integer-literal,
             #("01" . #"binary-integer"),
             #('_' . #"binary-integer-underscore")),
       state(#"binary-integer-underscore", #f,
             #("01" . #"binary-integer")),

       state(#"sharp-o", #f,
             #("0-7" . #"octal-integer")),
       state(#"octal-integer", parse-integer-literal,
             #("0-7" . #"octal-integer"),
             #('_' . #"octal-integer-underscore")),
       state(#"octal-integer-underscore", #f,
             #("0-7" . #"octal-integer")),

       state(#"sharp-x", #f,
             #("0-9a-fA-F" . #"hex-integer")),
       state(#"hex-integer", parse-integer-literal,
             #("0-9a-fA-F" . #"hex-integer"),
             #('_' . #"hex-integer-underscore")),
       state(#"hex-integer-underscore", #f,
             #("0-9a-fA-F" . #"hex-integer")),

       /* CMU
       state(#"sharp-i", #f, #("fF" . #"sharp-if")),
       state(#"sharp-if", fragment-builder(<hash-if-fragment>)),
       state(#"sharp-e", #f,
             #('-' . #"sharp-e-minus"),
             #("0-9" . #"extended-integer"),
             #("bB" . #"sharp-b"),
             #("oO" . #"sharp-o"),
             #("xX" . #"sharp-x"),
             #("lL" . #"sharp-el"),
             #("nN" . #"sharp-en")),
       state(#"sharp-e-minus", #f,
             #("0-9" . #"extended-integer")),
       state(#"sharp-el", #f, #("sS" . #"sharp-els")),
       state(#"sharp-els", #f, #("eE" . #"sharp-else")),
       state(#"sharp-else", fragment-builder(<hash-else-fragment>),
             #("iI" . #"sharp-elsei")),
       state(#"sharp-elsei", #f, #("fF" . #"sharp-elseif")),
       state(#"sharp-elseif", fragment-builder(<hash-elseif-fragment>)),
       state(#"sharp-en", #f, #("dD" . #"sharp-end")),
       state(#"sharp-end", #f, #("iI" . #"sharp-endi")),
       state(#"sharp-endi", #f, #("fF" . #"sharp-endif")),
       state(#"sharp-endif", fragment-builder(<hash-endif-fragment>)),
       state(#"extended-integer", parse-integer-literal,
             #("0-9" . #"extended-integer")),
       */
       state(#"lparen", fragment-builder(<lparen-fragment>)),
       state(#"rparen", fragment-builder(<rparen-fragment>)),
       state(#"comma", fragment-builder(<comma-fragment>)),
       state(#"dot", fragment-builder(<dot-fragment>),
             #('.' . #"dot-dot"),
             #("0123456789" . #"decimal-dot-decimal")),
       state(#"dot-dot", #f, #('.' . #"ellipsis")),
       state(#"ellipsis", fragment-builder(<ellipsis-fragment>)),
       state(#"semicolon", fragment-builder(<semicolon-fragment>)),
       state(#"colon", #f,
             #('=' . #"colon-equal"),
             #(':' . #"double-colon"),
             #("a-zA-Z" . #"cname"),
             #("0-9" . #"cname-leading-numeric"),
             #("!$%@_" . #"cname-leading-graphic"),
             #("+/" . #"cname-binop"),
             #('-' . #"cname-binop"),
             #("*^&|" . #"cname-graphic-binop"),
             #('~' . #"cname-tilde"),
             #("<>" . #"cname-angle")),
       state(#"colon-equal", make-binary-operator,
             #('=' . #"cname-binop")),
       state(#"double-colon", fragment-builder(<colon-colon-fragment>),
             #('=' . #"cname-binop")),
       state(#"lbracket", fragment-builder(<lbracket-fragment>)),
       state(#"rbracket", fragment-builder(<rbracket-fragment>)),
       state(#"lbrace", fragment-builder(<lbrace-fragment>)),
       state(#"rbrace", fragment-builder(<rbrace-fragment>)),
       state(#"minus", make-minus,
             #("0-9" . #"signed-decimal"),
             #('.' . #"decimal-dot")),
       state(#"equal", make-equal,
             #('=' . #"double-equal"),
             #('>' . #"arrow"),
             #("a-zA-Z" . #"symbol"),
             #("0-9!&*<|^$%@_-+~?/" . #"leading-graphic")),
       state(#"double-equal", make-double-equal,
             #("a-zA-Z" . #"symbol"),
             #("0-9!&*<=>|^$%@_-+~?/" . #"leading-graphic")),
       state(#"arrow", fragment-builder(<equal-greater-fragment>),
             #("a-zA-Z" . #"symbol"),
             #("0-9!&*<=>|^$%@_-+~?/" . #"leading-graphic")),
       state(#"question", fragment-builder(<query-fragment>),
             #('?' . #"double-question"),
             #('=' . #"question-equal"),
             #('@' . #"question-at")),
       state(#"double-question", fragment-builder(<query-query-fragment>)),
       state(#"question-equal", fragment-builder(<query-equal-fragment>)),
       state(#"question-at", fragment-builder(<query-at-fragment>)),
       state(#"backslash", #f,
             #("-+/" . #"backslash-done"),
             #('~' . #"backslash-tilde"),
             #(':' . #"backslash-colon"),
             #('#' . #"backslash-sharp"),
             #("a-zA-Z" . #"backslash-symbol"),
             #("0-9" . #"backslash-digit"),
             // TODO: Remove these hacks for parsing machine words.
             // #("!$%@_" . #"backslash-graphic"),
             #('%' . #"backslash-percent"),
             #("!$@_" . #"backslash-graphic"),
             #("&*^|" . #"backslash-graphic-done"),
             #("=<>" . #"backslash-graphic-pre-equal"),
             // EXTENSION: The escaped punctuation extensions used in macros.
             #('.' . #"backslash-dot"),
             #('?' . #"backslash-question")),
       state(#"backslash-dot", fragment-builder(<dot-fragment>),
             #('.' . #"backslash-dot-dot")),
       state(#"backslash-dot-dot", #f,
             #('.' . #"backslash-ellipsis")),
       state(#"backslash-ellipsis", make-escaped-ellipsis),
       state(#"backslash-question", make-escaped-query,
             #("?" . #"backslash-double-question"),
             #("=" . #"backslash-question-equal")),
       state(#"backslash-sharp", #f,
             #("nN" . #"backslash-sharp-n"),
             #("rR" . #"backslash-sharp-r"),
             #("kK" . #"backslash-sharp-k"),
             #("aA" . #"backslash-sharp-a")),
       state(#"backslash-sharp-n", #f, #("eE" . #"backslash-sharp-ne")),
       state(#"backslash-sharp-ne", #f, #("xX" . #"backslash-sharp-nex")),
       state(#"backslash-sharp-nex", #f, #("tT" . #"backslash-sharp-next")),
       state(#"backslash-sharp-next", make-escaped-hash-next-fragment),
       state(#"backslash-sharp-r", #f, #("eE" . #"backslash-sharp-re")),
       state(#"backslash-sharp-re", #f, #("sS" . #"backslash-sharp-res")),
       state(#"backslash-sharp-res", #f, #("tT" . #"backslash-sharp-rest")),
       state(#"backslash-sharp-rest", make-escaped-hash-rest-fragment),
       state(#"backslash-sharp-k", #f, #("eE" . #"backslash-sharp-ke")),
       state(#"backslash-sharp-ke", #f, #("yY" . #"backslash-sharp-key")),
       state(#"backslash-sharp-key", make-escaped-hash-key-fragment),
       state(#"backslash-sharp-a", #f, #("lL" . #"backslash-sharp-al")),
       state(#"backslash-sharp-al", #f, #("lL" . #"backslash-sharp-all")),
       state(#"backslash-sharp-all", #f, #('-' . #"backslash-sharp-all-")),
       state(#"backslash-sharp-all-", #f, #("kK" . #"backslash-sharp-all-k")),
       state(#"backslash-sharp-all-k", #f, #("eE" . #"backslash-sharp-all-ke")),
       state(#"backslash-sharp-all-ke", #f, #("yY" . #"backslash-sharp-all-key")),
       state(#"backslash-sharp-all-key", #f, #("sS" . #"backslash-sharp-all-keys")),
       state(#"backslash-sharp-all-keys", make-escaped-hash-all-keys-fragment),
       state(#"backslash-double-question", make-escaped-query-query),
       state(#"backslash-question-equal", make-escaped-query-equal),
       state(#"backslash-percent", #f,
             #("-+*/" . #"backslash-done"),
             #("a-zA-Z" . #"backslash-symbol"),
             #("0-9!&<=>|^$%@_~?" . #"backslash-graphic")),
       state(#"backslash-done", make-quoted-name),
       state(#"backslash-tilde", make-quoted-name,
             #('=' . #"backslash-tilde-equal")),
       state(#"backslash-tilde-equal", make-quoted-name,
             #('=' . #"backslash-done")),
       state(#"backslash-colon", #f,
             #('=' . #"backslash-done"),
             #(':' . #"backslash-colon-colon")),
       state(#"backslash-colon-colon", make-escaped-colon-colon),
       state(#"backslash-graphic", #f,
             #("-0-9!&*<=>|^$%@_+~?/" . #"backslash-graphic"),
             #("a-zA-Z" . #"backslash-symbol")),
       state(#"backslash-graphic-done", make-quoted-name,
             #("-0-9!&*<=>|^$%@_+~?/" . #"backslash-graphic"),
             #("a-zA-Z" . #"backslash-symbol")),
       state(#"backslash-graphic-pre-equal", make-quoted-name,
             #('=' . #"backslash-graphic-done"),
             #("-0-9!&*<>|^$%@_+~?/" . #"backslash-graphic"),
             #("a-zA-Z" . #"backslash-symbol")),
       state(#"backslash-symbol", make-quoted-name,
             #("-+~?/!&*<=>|^$%@_0-9a-zA-Z" . #"backslash-symbol")),
       state(#"backslash-digit", #f,
             #("-0-9!&*<=>|^$%@_+~?/" . #"backslash-digit"),
             #("a-zA-Z" . #"backslash-digit-alpha")),
       state(#"backslash-digit-alpha", #f,
             #("-0-9!&*<=>|^$%@_+~?/" . #"backslash-digit"),
             #("a-zA-Z" . #"backslash-symbol")),
       state(#"plus", make-binary-operator,
             #("0-9" . #"signed-decimal"),
             #('.' . #"decimal-dot")),
       state(#"tilde", make-tilde,
             #('=' . #"tilde-equal")),
       state(#"tilde-equal", make-binary-operator,
             #('=' . #"tilde-equal-equal")),
       state(#"tilde-equal-equal", make-binary-operator),
       state(#"operator-graphic", make-binary-operator,
             #("a-zA-Z" . #"symbol"),
             #("0-9!&*<=>|^$%@_-+~?/" . #"leading-graphic")),
       state(#"operator-graphic-pre-equal", make-binary-operator,
             #('=' . #"operator-graphic"),
             #("a-zA-Z" . #"symbol"),
             #("0-9!&*<>|^$%@_-+~?/" . #"leading-graphic")),
       state(#"leading-graphic", #f,
             #("0-9!&*<=>|^$%@_+~?/" . #"leading-graphic"),
             #('-' . #"leading-graphic"),
             #("a-zA-Z" . #"symbol")),
       state(#"leading-dollar", #f,
             #("0-9" . #"history-or-leading-graphic"),
             #("!&*<=>|^$%@_+~?/" . #"leading-graphic"),
             #('-' . #"leading-graphic"),
             #("a-zA-Z" . #"symbol")),
       state(#"history-or-leading-graphic", make-history-name,
             #("0-9" . #"history-or-leading-graphic"),
             #("!&*<=>|^$%@_+~?/" . #"leading-graphic"),
             #('-' . #"leading-graphic"),
             #("a-zA-Z" . #"symbol")),
       state(#"leading-underscore", make-identifier,
             #("0-9!&*<=>|^$%@_+~?/" . #"leading-graphic"),
             #('-' . #"leading-graphic"),
             #("a-zA-Z" . #"symbol")),
       state(#"symbol", make-identifier,
             #("a-zA-Z0-9!&*<=>|^$%@_+~?/" . #"symbol"),
             #('-' . #"symbol"),
             #(':' . #"colon-keyword")),

       state(#"colon-keyword", make-keyword-symbol,
             #("a-zA-Z" . #"cname"),
             #("0-9" . #"cname-leading-numeric"),
             #("!$%@_" . #"cname-leading-graphic"),
             #("+/" . #"cname-binop"),
             #('-' . #"cname-binop"),
             #("*^&|" . #"cname-graphic-binop"),
             #('~' . #"cname-tilde"),
             #("<>" . #"cname-angle"),
             #('=' . #"cname-equal"),
             #(':' . #"cname-colon")),

       state(#"cname-binop", make-constrained-name,
             #(':' . #"colon-qname")),
       state(#"cname-graphic-binop", make-constrained-name,
             #(':' . #"colon-qname"),
             #("0-9!&*<>|^$%@_+~?/=" . #"cname-leading-graphic"),
             #('-' . #"cname-leading-graphic"),
             #("a-zA-Z" . #"cname")),
       state(#"cname-tilde", #f,
             #('=' . #"cname-tilde-equal")),
       state(#"cname-tilde-equal", make-constrained-name,
             #(':' . #"colon-qname"),
             #('=' . #"cname-tilde-double-equal")),
       state(#"cname-tilde-double-equal", make-constrained-name,
             #(':' . #"colon-qname")),
       state(#"cname-angle", make-constrained-name,
             #(':' . #"colon-qname"),
             #('=' . #"cname-angle-equal"),
             #("0-9!&*<>|^$%@_+~?/" . #"cname-leading-graphic"),
             #('-' . #"cname-leading-graphic"),
             #("a-zA-Z" . #"cname")),
       state(#"cname-angle-equal", make-constrained-name,
             #(':' . #"colon-qname"),
             #("0-9!&*<>|^$%@_+~?/=" . #"cname-leading-graphic"),
             #('-' . #"cname-leading-graphic"),
             #("a-zA-Z" . #"cname")),
       state(#"cname-equal", make-constrained-name,
             #(':' . #"colon-qname"),
             #('=' . #"cname-binop")),
       state(#"cname-colon", #f,
             #('=' . #"cname-binop")),
       state(#"cname-leading-numeric", #f,
             #("0-9!&*<>|^$%@_+~?/=" . #"cname-leading-numeric"),
             #('-' . #"cname-leading-numeric"),
             #("a-zA-Z" . #"cname-numeric-alpha")),
       state(#"cname-numeric-alpha", #f,
             #("0-9!&*<>|^$%@_+~?/=" . #"cname-leading-numeric"),
             #('-' . #"cname-leading-numeric"),
             #("a-zA-Z" . #"cname")),
       state(#"cname-leading-graphic", #f,
             #("0-9!&*<>|^$%@_+~?/=" . #"cname-leading-graphic"),
             #('-' . #"cname-leading-graphic"),
             #("a-zA-Z" . #"cname")),
       state(#"cname", make-constrained-name,
             #(':' . #"colon-qname"),
             #("a-zA-Z0-9!&*<>|^$%@_+~?/=" . #"cname"),
             #('-' . #"cname")),

       state(#"colon-qname", #f,
             #("a-zA-Z" . #"qname"),
             #("0-9" . #"qname-leading-numeric"),
             #("!$%@_" . #"qname-leading-graphic"),
             #("+/" . #"qname-binop"),
             #('-' . #"qname-binop"),
             #("*^&|" . #"qname-graphic-binop"),
             #('~' . #"qname-tilde"),
             #("<>" . #"qname-angle"),
             #('=' . #"qname-equal"),
             #(':' . #"qname-colon")),

       state(#"qname-binop", make-qualified-name),
       state(#"qname-graphic-binop", make-qualified-name,
             #("0-9!&*<>|^$%@_+~?/=" . #"qname-leading-graphic"),
             #('-' . #"qname-leading-graphic"),
             #("a-zA-Z" . #"qname")),
       state(#"qname-tilde", #f,
             #('=' . #"qname-tilde-equal")),
       state(#"qname-tilde-equal", make-qualified-name,
             #('=' . #"qname-tilde-double-equal")),
       state(#"qname-tilde-double-equal", make-qualified-name),
       state(#"qname-angle", make-qualified-name,
             #('=' . #"qname-angle-equal"),
             #("0-9!&*<>|^$%@_+~?/" . #"qname-leading-graphic"),
             #('-' . #"qname-leading-graphic"),
             #("a-zA-Z" . #"qname")),
       state(#"qname-angle-equal", make-qualified-name,
             #("0-9!&*<>|^$%@_+~?/=" . #"qname-leading-graphic"),
             #('-' . #"qname-leading-graphic"),
             #("a-zA-Z" . #"qname")),
       state(#"qname-equal", make-qualified-name,
             #('=' . #"qname-binop")),
       state(#"qname-colon", #f,
             #('=' . #"qname-binop")),
       state(#"qname-leading-numeric", #f,
             #("0-9!&*<>|^$%@_+~?/=" . #"qname-leading-numeric"),
             #('-' . #"qname-leading-numeric"),
             #("a-zA-Z" . #"qname-numeric-alpha")),
       state(#"qname-numeric-alpha", #f,
             #("0-9!&*<>|^$%@_+~?/=" . #"qname-leading-numeric"),
             #('-' . #"qname-leading-numeric"),
             #("a-zA-Z" . #"qname")),
       state(#"qname-leading-graphic", #f,
             #("0-9!&*<>|^$%@_+~?/=" . #"qname-leading-graphic"),
             #('-' . #"qname-leading-graphic"),
             #("a-zA-Z" . #"qname")),
       state(#"qname", make-qualified-name,
             #("a-zA-Z0-9!&*<>|^$%@_+~?/=" . #"qname"),
             #('-' . #"qname")),

       state(#"quote", #f,
             #(" -&(-[]-~" . #"quote-char"),
             pair($ascii-8-bit-extensions, #"quote-char"),
             #('\\' . #"quote-escape")),
       state(#"quote-escape", #f,
             #("\\'\"abefnrt0" . #"quote-char"),
             #('<' . #"quote-escape-less")),
       state(#"quote-escape-less", #f,
             #("0-9a-fA-F" . #"quote-hex-char-digits")),
       state(#"quote-hex-char-digits", #f,
             #("0-9a-fA-F" . #"quote-hex-char-digits"),
             #('>' . #"quote-char")),
       state(#"quote-char", #f,
             #('\'' . #"character")),
       state(#"character", make-character-literal),
       state(#"double-quote", #f,
             #('"' . #"two-double-quotes"),
             #('\\' . #"string-escape"),
             #("\t !#-[]-~" . #"simple-string"),
             pair($ascii-8-bit-extensions, #"simple-string")),
       state(#"simple-string", #f,
             #('"' . #"end-simple-string"),
             #('\\' . #"string-escape"),
             #("\t !#-[]-~" . #"simple-string"),
             pair($ascii-8-bit-extensions, #"simple-string")),
       state(#"end-simple-string", make-string-literal),
       state(#"two-double-quotes", make-string-literal,
             #('"' . #"3string")),

       state(#"3string", #f, // seen """
             #('"' . #"close-double-quote"),
             #('\\' . #"3string-escape"),
             #("\t !#-[]-~\r\n" . #"3string"),  // Ranges #-[ and ]-~ exclude backslash
             pair($ascii-8-bit-extensions, #"3string")),
       state(#"3string-escape", #f,
             #("\\'\"abefnrt0" . #"3string"),
             #('<' . #"3string-escape-less")),
       state(#"3string-escape-less", #f,
             #("0-9a-fA-F" . #"3string-hex-char-digits")),
       state(#"3string-hex-char-digits", #f,
             #("0-9a-fA-F" . #"3string-hex-char-digits"),
             #('>' . #"3string")),
       state(#"close-double-quote", #f,
             #('"' . #"close-double-quote-2"),
             #("\t !#-[]-~\r\n" . #"3string"),
             pair($ascii-8-bit-extensions, #"3string")),
       state(#"close-double-quote-2", #f,
             #('"' . #"multi-line-string"),
             #("\t !#-[]-~\r\n" . #"3string"),
             pair($ascii-8-bit-extensions, #"3string")),
       state(#"multi-line-string", make-multi-line-string-literal),

       // Raw strings
       state(#"raw-string-start", #f,          // seen #r"
             #('"' . #"sharp-r-2-double-quotes"),
             #("\t !#-~" . #"raw-1string"),
             pair($ascii-8-bit-extensions, #"raw-1string")),
       state(#"sharp-r-2-double-quotes", make-raw-string-literal,
             #('"' . #"raw-3string-start")),
       state(#"raw-1string", #f,       // seen #r" plus one non-" char
             #('"' . #"raw-1string-end"),
             #("\t !#-~" . #"raw-1string"),
             pair($ascii-8-bit-extensions, #"raw-1string")),
       state(#"raw-1string-end", make-raw-string-literal),
       state(#"raw-3string-start", #f, // seen #r"""
             #('"' . #"raw-3string-double-quote"),
             #("\t !#-~\r\n" . #"raw-3string"),
             pair($ascii-8-bit-extensions, #"raw-3string")),
       state(#"raw-3string", #f,
             #('"' . #"raw-3string-double-quote"),
             #("\t !#-~\r\n" . #"raw-3string"),
             pair($ascii-8-bit-extensions, #"raw-3string")),
       state(#"raw-3string-double-quote", #f,
             #('"' . #"raw-3string-2-double-quotes"),
             #("\t !#-~\r\n" . #"raw-3string"),
             pair($ascii-8-bit-extensions, #"raw-3string")),
       state(#"raw-3string-2-double-quotes", #f,
             #('"' . #"raw-3string-end"),
             #("\t !#-~\r\n" . #"raw-3string"),
             pair($ascii-8-bit-extensions, #"raw-3string")),
       state(#"raw-3string-end", make-multi-line-raw-string-literal),

       state(#"string-escape", #f,
             #("\\'\"abefnrt0" . #"double-quote"),
             #('<' . #"string-escape-less")),
       state(#"string-escape-less", #f,
             #("0-9a-fA-F" . #"double-quote-hex-char-digits")),
       state(#"double-quote-hex-char-digits", #f,
             #("0-9a-fA-F" . #"double-quote-hex-char-digits"),
             #('>' . #"double-quote")),
       state(#"decimal", parse-integer-literal,
             #("0-9" . #"decimal"),
             #('/' . #"decimal-slash"),
             #('.' . #"decimal-dot"),
             #("eEsSdDxX" . #"decimal-e"),
             #("_" . #"decimal-underscore")),
       state(#"decimal-underscore", #f,
             #("0-9" . #"decimal")),
       state(#"decimal-slash", #f,
             #("0-9" . #"ratio"),
             #("a-zA-Z" . #"numeric-alpha"),
             #("!&*<=>|^$%@_+~?/" . #"leading-numeric"),
             #('-' . #"leading-numeric")),
       state(#"numeric-alpha", #f,
             #("a-zA-Z" . #"symbol"),
             #("0-9!&*<=>|^$%@_+~?/" . #"leading-numeric"),
             #('-' . #"leading-numeric")),
       state(#"leading-numeric", #f,
             #("a-zA-Z" . #"numeric-alpha"),
             #("0-9!&*<=>|^$%@_+~?/" . #"leading-numeric"),
             #('-' . #"leading-numeric")),

       state(#"ratio", parse-ratio-literal,
             #("0-9" . #"ratio"),
             #("a-zA-Z" . #"numeric-alpha"),
             #("-!&*<=>|^$%@_+~?/" . #"leading-numeric")),

       state(#"signed-decimal", parse-integer-literal,
             #("0-9" . #"signed-decimal"),
             #('/' . #"signed-decimal-slash"),
             #('.' . #"decimal-dot"),
             #("eEsSdDxX" . #"fp-e"),
             #('_' . #"signed-decimal-underscore")),
       state(#"signed-decimal-underscore", #f,
             #("0-9" . #"signed-decimal")),
       state(#"signed-decimal-slash", #f,
             #("0-9" . #"signed-ratio")),
       state(#"signed-ratio", parse-ratio-literal,
             #("0-9" . #"signed-ratio")),

       state(#"decimal-dot", parse-fp-literal,
             #("0-9" . #"decimal-dot-decimal"),
             #("eEsSdDxX" . #"fp-e")),
       state(#"decimal-dot-decimal", parse-fp-literal,
             #('_' . #"decimal-dot-decimal-underscore"),
             #("0-9" . #"decimal-dot"),
             #("eEsSdDxX" . #"fp-e")),
       state(#"decimal-dot-decimal-underscore", #f,
             #("0-9" . #"decimal-dot-decimal")),
       state(#"fp-e", #f,
             #('-' . #"fp-e-sign"),
             #('+' . #"fp-e-sign"),
             #("0-9" . #"fp-exp")),
       state(#"fp-e-sign", #f,
             #("0-9" . #"fp-exp")),
       state(#"fp-exp", parse-fp-literal,
             #("0-9" . #"fp-exp"),
             #('_' . #"fp-exp-underscore")),
       state(#"fp-exp-underscore", #f,
             #("0-9" . #"fp-exp")),

       state(#"decimal-e", #f,
             #("a-zA-Z" . #"symbol"),
             #("[0-9]" . #"decimal-exp"),
             #("!&*<=>|^$%@_~?/" . #"leading-numeric"),
             #('-' . #"decimal-e-sign"),
             #('+' . #"decimal-e-sign")),
       state(#"decimal-exp", parse-fp-literal,
             #("0-9" . #"decimal-exp"),
             #("a-zA-Z" . #"numeric-alpha"),
             #("!&*<=>|^$%@_+~?/" . #"leading-numeric"),
             #("-" . #"leading-numeric")),
       state(#"decimal-e-sign", #f,
             #("0-9" . #"decimal-exp"),
             #("a-zA-Z" . #"numeric-alpha"),
             #("!&*<=>|^$%@_+~?/" . #"leading-numeric"),
             #("-" . #"leading-numeric")));
