module: unix-sockets

define inline-only C-function errno
  result val :: <C-int>;
  c-name: "io_errno";
end C-function;

define inline-only C-function h-errno
  result val :: <C-int>;
  c-name: "network_h_errno";
end C-function;

/* These values come from the headers of an x86 Linux machine.
   Other UNIX platforms are expected to be the same, but not
   guaranteed. */

define constant $EPERM           =   1;
define constant $ENOENT          =   2;
define constant $ESRCH           =   3;
define constant $EINTR           =   4;
define constant $EIO             =   5;
define constant $ENXIO           =   6;
define constant $E2BIG           =   7;
define constant $ENOEXEC         =   8;
define constant $EBADF           =   9;
define constant $ECHILD          =  10;
define constant $EAGAIN          =  11;
define constant $EWOULDBLOCK     =  11;
define constant $ENOMEM          =  12;
define constant $EACCES          =  13;
define constant $EFAULT          =  14;
define constant $ENOTBLK         =  15;
define constant $EBUSY           =  16;
define constant $EEXIST          =  17;
define constant $EXDEV           =  18;
define constant $ENODEV          =  19;
define constant $ENOTDIR         =  20;
define constant $EISDIR          =  21;
define constant $EINVAL          =  22;
define constant $ENFILE          =  23;
define constant $EMFILE          =  24;
define constant $ENOTTY          =  25;
define constant $ETXTBSY         =  26;
define constant $EFBIG           =  27;
define constant $ENOSPC          =  28;
define constant $ESPIPE          =  29;
define constant $EROFS           =  30;
define constant $EMLINK          =  31;
define constant $EPIPE           =  32;
define constant $EDOM            =  33;
define constant $ERANGE          =  34;
define constant $EDEADLK         =  35;
define constant $EDEADLOCK       =  35;
define constant $ENAMETOOLONG    =  36;
define constant $ENOLCK          =  37;
define constant $ENOSYS          =  38;
define constant $ENOTEMPTY       =  39;
define constant $ELOOP           =  40;
define constant $ENOMSG          =  42;
define constant $EIDRM           =  43;
define constant $ECHRNG          =  44;
define constant $EL2NSYNC        =  45;
define constant $EL3HLT          =  46;
define constant $EL3RST          =  47;
define constant $ELNRNG          =  48;
define constant $EUNATCH         =  49;
define constant $ENOCSI          =  50;
define constant $EL2HLT          =  51;
define constant $EBADE           =  52;
define constant $EBADR           =  53;
define constant $EXFULL          =  54;
define constant $ENOANO          =  55;
define constant $EBADRQC         =  56;
define constant $EBADSLT         =  57;
define constant $EBFONT          =  59;
define constant $ENOSTR          =  60;
define constant $ENODATA         =  61;
define constant $ETIME           =  62;
define constant $ENOSR           =  63;
define constant $ENONET          =  64;
define constant $ENOPKG          =  65;
define constant $EREMOTE         =  66;
define constant $ENOLINK         =  67;
define constant $EADV            =  68;
define constant $ESRMNT          =  69;
define constant $ECOMM           =  70;
define constant $EPROTO          =  71;
define constant $EMULTIHOP       =  72;
define constant $EDOTDOT         =  73;
define constant $EBADMSG         =  74;
define constant $EOVERFLOW       =  75;
define constant $ENOTUNIQ        =  76;
define constant $EBADFD          =  77;
define constant $EREMCHG         =  78;
define constant $ELIBACC         =  79;
define constant $ELIBBAD         =  80;
define constant $ELIBSCN         =  81;
define constant $ELIBMAX         =  82;
define constant $ELIBEXEC        =  83;
define constant $EILSEQ          =  84;
define constant $ERESTART        =  85;
define constant $ESTRPIPE        =  86;
define constant $EUSERS          =  87;
define constant $ENOTSOCK        =  88;
define constant $EDESTADDRREQ    =  89;
define constant $EMSGSIZE        =  90;
define constant $EPROTOTYPE      =  91;
define constant $ENOPROTOOPT     =  92;
define constant $EPROTONOSUPPORT =  93;
define constant $ESOCKTNOSUPPORT =  94;
define constant $EOPNOTSUPP      =  95;
define constant $ENOTSUP         =  95;
define constant $EPFNOSUPPORT    =  96;
define constant $EAFNOSUPPORT    =  97;
define constant $EADDRINUSE      =  98;
define constant $EADDRNOTAVAIL   =  99;
define constant $ENETDOWN        = 100;
define constant $ENETUNREACH     = 101;
define constant $ENETRESET       = 102;
define constant $ECONNABORTED    = 103;
define constant $ECONNRESET      = 104;
define constant $ENOBUFS         = 105;
define constant $EISCONN         = 106;
define constant $ENOTCONN        = 107;
define constant $ESHUTDOWN       = 108;
define constant $ETOOMANYREFS    = 109;
define constant $ETIMEDOUT       = 110;
define constant $ECONNREFUSED    = 111;
define constant $EHOSTDOWN       = 112;
define constant $EHOSTUNREACH    = 113;
define constant $EALREADY        = 114;
define constant $EINPROGRESS     = 115;
define constant $ESTALE          = 116;
define constant $EUCLEAN         = 117;
define constant $ENOTNAM         = 118;
define constant $ENAVAIL         = 119;
define constant $EISNAM          = 120;
define constant $EREMOTEIO       = 121;
define constant $EDQUOT          = 122;
define constant $ENOMEDIUM       = 123;
define constant $EMEDIUMTYPE     = 124;
define constant $ECANCELED       = 125;