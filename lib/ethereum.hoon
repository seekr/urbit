::
/-  ethereum
=,  ^ethereum
::
::  ABI spec used for reference:
::  https://ethereum.gitbooks.io/frontier-guide/content/abi.html
::
|%
::
++  encode-params
  :>  encode list of parameters
  |=  das=(list data)
  ^-  tape
  (encode-data [%array-n das])
::
++  encode-data
  :>  encode typed data into ABI bytestring.
  ::
  |=  dat=data
  ^-  tape
  ?+  -.dat
    ~|  [%unsupported-type -.dat]
    !!
  ::
      %array-n
    ::  enc(X) = head(X[0]) ... head(X[k-1]) tail(X[0]) ... tail(X[k-1])
    ::  where head and tail are defined for X[i] being of a static type as
    ::  head(X[i]) = enc(X[i]) and tail(X[i]) = "" (the empty string), or as
    ::  head(X[i]) = enc(len(head(X[0])..head(X[k-1]) tail(X[0])..tail(X[i-1])))
    ::  and tail(X[i]) = enc(X[i]) otherwise.
    ::
    ::  so: if it's a static type, data goes in the head. if it's a dynamic
    ::  type, a reference goes into the head and data goes into the tail.
    ::
    ::  in the head, we first put a placeholder where references need to go.
    =+  hol=(reap 64 'x')
    =/  hes=(list tape)
      %+  turn  p.dat
      |=  d=data
      ?.  (is-dynamic-type d)  ^$(dat d)
      hol
    =/  tas=(list tape)
      %+  turn  p.dat
      |=  d=data
      ?.  (is-dynamic-type d)  ""
      ^$(dat d)
    ::  once we know the head and tail, we can fill in the references in head.
    =-  (weld nes `tape`(zing tas))
    ^-  [@ud nes=tape]
    =+  led=(lent (zing hes))
    %+  roll  hes
    |=  [t=tape i=@ud nes=tape]
    :-  +(i)
    ::  if no reference needed, just put the data.
    ?.  =(t hol)  (weld nes t)
    ::  calculate byte offset of data we need to reference.
    =/  ofs/@ud
      =-  ~&  [%full -]
          (div - 2)       ::  two hex digits per byte.
      %+  add  led        ::  count head, and
      %-  lent  %-  zing  ::  count all tail data
      (scag i tas)        ::  preceding ours.
    ~&  [%offset-at i ofs `@ux`ofs]
    =+  ref=^$(dat [%uint ofs])
    ::  shouldn't hit this unless we're sending over 2gb of data?
    ~|  [%weird-ref-lent (lent ref)]
    ?>  =((lent ref) (lent hol))
    (weld nes ref)
  ::
      %array  ::  where X has k elements (k is assumed to be of type uint256):
    ::  enc(X) = enc(k) enc([X[1], ..., X[k]])
    ::  i.e. it is encoded as if it were an array of static size k, prefixed
    ::  with the number of elements.
    %+  weld  $(dat [%uint (lent p.dat)])
    $(dat [%array-n p.dat])
  ::
      %bytes-n
    ::  enc(X) is the sequence of bytes in X padded with zero-bytes to a length
    ::  of 32.
    ::  Note that for any X, len(enc(X)) is a multiple of 32.
    (pad-to-multiple (render-hex-bytes p.dat) 64 %right)
  ::
      %bytes  ::  of length k (which is assumed to be of type uint256)
    ::  enc(X) = enc(k) pad_right(X), i.e. the number of bytes is encoded as a
    ::  uint256 followed by the actual value of X as a byte sequence, followed
    ::  by the minimum number of zero-bytes such that len(enc(X)) is a multiple
    ::  of 32.
    %+  weld  $(dat [%uint (met 3 p.dat)])
    $(dat [%bytes-n p.dat])
  ::
      %string
    ::  enc(X) = enc(enc_utf8(X)), i.e. X is utf-8 encoded and this value is
    ::  interpreted as of bytes type and encoded further. Note that the length
    ::  used in this subsequent encoding is the number of bytes of the utf-8
    ::  encoded string, not its number of characters.
    $(dat [%bytes (crip (flop p.dat))])
  ::
      %uint
    ::  enc(X) is the big-endian encoding of X, padded on the higher-order
    ::  (left) side with zero-bytes such that the length is a multiple of 32
    ::  bytes.
    (pad-to-multiple (render-hex-bytes `@ux`p.dat) 64 %left)
  ::
      %bool
    ::  as in the uint8 case, where 1 is used for true and 0 for false
    $(dat [%uint ?:(p.dat 1 0)])
  ::
      %address
    ::  as in the uint160 case
    $(dat [%uint `@ud`p.dat])
  ==
::
++  is-dynamic-type
  |=  a=data
  ?.  ?=(%array-n -.a)
    ?=(?(%string %bytes %array) -.a)
  &(!=((lent p.a) 0) (lien p.a is-dynamic-type))
::
::
++  render-hex-bytes
  :>  atom to string of hex bytes without 0x prefix and dots.
  |=  a=@ux
  =-  ?:(=(1 (mod (lent -) 2)) ['0' -] -)
  %+  skip  (slag 2 (scow %ux a))
  |=(b=@t =(b '.'))
::
++  pad-to-multiple
  |=  [wat=tape mof=@ud wer=?(%left %right)]
  =+  len=(lent wat)
  =+  tad=(reap (sub mof (mod len mof)) '0')
  %-  weld
  ?:(?=(%left wer) [tad wat] [wat tad])
--
