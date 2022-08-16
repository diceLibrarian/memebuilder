Bitwise Operations Mod v1.2
By Leslie E. Krause

Bitwise Operations is a pure-Lua implementation of various bit-manipulation functions, 
including conversion to and from strings and numbers via binary notation as well as an 
additional binary option to string.format().

For numeric bit operations, the following functions are available globally:

   AND(), OR(), XOR(), NOT(), LSHIFT() and RSHIFT()

All other library functions can be accessed via the 'bitwise' namespace. For improved 
performance, you may want to localize the functions to bits_<func>.

   local bits_format = bitwise.format
   local bits_unpack = bitwise.unpack
   local bits_pack = bitwise.pack
   local bits_to_string = bitwise.to_string
   local bits_from_string = bitwise.from_string
   local bits_pack_string = bitwise.pack_string
   local bits_not = bitwise.NOT
   local bits_and = bitwise.AND
   local bits_or = bitwise.OR
   local bits_xor = bitwise.XOR
   local bits_lshift = bitwise.LSHIFT
   local bits_rshift = bitwise.RSHIFT
   local bits_new = bitwise.new

All of these functions can prove useful when debugging, or any application where you 
need to examine and manipulate individual bits of either numbers or strings.

 * bitwise.format( str, ... )
   Extends the string.format( ) function with an additional %b format specifier for 
   outputting numbers in binary notation. The str is a string that consists of one or 
   more format specifiers, each associated with an argument for substitution.

      %[flag][field-width][:group-width]b

   The %b format specifier accepts a flag of either 0 to pad the field with leading 
   zeroes or - to left-justify the field. With no flag, the field will be padded with 
   leading spaces instead. If no field width is specified then the only the minimum 
   digits necessary to represent the number in binary notation will be shown, with no 
   leading spaces or zeros. If the field is not wide enough to accommodate the entire 
   number in binary notation, then it will be extended (no digits will be truncated). 
   Sets of bits may also be evenly spaced provided an optional group width.

   Example:
   print( bitwise.format( "%032:4b", 65000 ) )
   --> 0000 0000 0000 0000 1111 1101 1110 1000

 * bitwise.new( size, value )
   Creates a new bit field (boolean array) for easily working with individual bits on
   the fly using Lua's builtin boolean operators.

    * size is the length of the bit field (required)
    * value is the boolean value to assign to each bit (defaults to false)

   Example:
   bitwise.new( 4, true )
   ==> { true, true, true, true }

 * bitwise.unpack( val, size )
   Unpacks a number into a bit field.

    * num is the unsigned integer to unpack (required)
    * size is the length of the bit field to create, limited to 56-bits (required)

   Example:
   bitwise.unpack( 16, 150 )
   ==> { true, false, false, true, false, true, true, false }

 * bitwise.pack( bits )
   Packs a bit field into a number.

    * bits is the bit field to unpack, limited to 56 elements (required)

   Example:
   print( bitwise.pack( { true, false, false, false, false, false, false, false } )
   --> 128

 * bitwise.pack_string( bits )
   Packs a bit field of arbitrary length into a string. Each set of 8 elements will
   produce an additional ASCII character.

    * bits is the bit field to unpack (required)

   Example:
   print( bitwise.pack_string( { false, true, true, true, false, true, true, true } ) )
   --> w

 * bitwise.to_string( bits, div )
   Transforms a bit field of arbitrary length into a binary-notation string.

    * bits is the bit field to transform into a string (required)
    * div is the group width for evenly spacing bits (optional)

   Example:
   print( bitwise.to_string( { true, false, true, true, false, true, true, true }, 4 ) )
   --> 1011 0111

 * bitwise.from_string( str )
   Parses a binary-notation string and transforms it into a bit field.

    * str is the string to transform into a bit field (required)

   Example:
   bitwise.from_string( "1001" )
   ==> { true, false, false, true }

 * bitwise.binary( str )
   Parses a binary-notation string and converts it into a number.

    * str is the string to convert into a number (required)

   Example:
   bitwise.binary( "00010010101110010001" )
   ==> 76689

 * AND( num1, num2 )
   Performs a logical bitwise AND operation on two numbers.

    * num1 is an unsigned integer
    * num2 is an unsigned integer

 * OR( num1, num2 )
   Performs a logical bitwise OR operation on two numbers. The number with the most
   significant bit set will determine the resulting bit pattern's length.

    * num1 is an unsigned integer
    * num2 is an unsigned integer

 * XOR( num1, num2 )
   Performs a logical bitwise XOR operation on two numbers. The number with the most
   significant bit set will determine the resulting bit pattern's length.

    * num1 is an unsigned integer
    * num2 is an unsigned integer

 * NOT( num )
   Performs a logical bitwise NOT operation on a number.

    * num is an unsigned integer

   For finer grained control of the resulting bit-pattern length, you can provide a mask 
   with the XOR() functions rather than using the NOT() function:

   Examples:
   NOT( 0x0F )
   ==> 0x00
   XOR( 0x0F, 0xFF )
   ==> 0xF0

 * NOT16( num )
   Performs a logical bitwise NOT operation on a 16-bit number.

    * num is an unsigned integer

   The result is undefined for numbers larger than 16-bits, so be sure to mask the input
   using the AND() function if in doubt.

 * NOT32( num )
   Performs a logical bitwise NOT operation on a 32-bit number.

    * num is an unsigned integer

   The result is undefined for numbers larger than 32-bits, so be sure to mask the input
   using the AND() function if in doubt.


Repository
----------------------

Browse source code...
  https://bitbucket.org/sorcerykid/bitwise

Download archive...
  https://bitbucket.org/sorcerykid/bitwise/get/master.zip
  https://bitbucket.org/sorcerykid/bitwise/get/master.tar.gz

Installation
----------------------

  1) Unzip the archive into the mods directory of your game
  2) Rename the bitwise-master directory to "bitwise"
  3) Add "bitwise" as a dependency to any mods using the API

License of source code
----------------------------------------------------------

The MIT License (MIT)

Copyright (c) 2020, Leslie Krause (leslie@searstower.org)

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

For more details:
https://opensource.org/licenses/MIT
