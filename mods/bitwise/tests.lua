string.is_match = function( text, glob )
	-- use underscore variable to preserve captures
	_ = { string.match( text, glob ) }
	return #_ > 0
end

require( "socket.core" )
require( "init" )

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

------------------------

bitwise.check( )	-- run a consistency check first

local blist = { 0, 1, 4, 8, 16, 255, 512, 1424, 58, 104 }

print( string.rep( "-", 140 ) )
print( string.format( "%6s %6s -> %16s %16s %16s %16s %16s %16s %16s", "dec", "hex", "bin", "LSHIFT(4)", "RSHIFT(4)", "AND(#1100)", "OR(#1010)", "XOR(#1001)", "NOT()" ) )
print( string.rep( "-", 140 ) )
for i, n in ipairs( blist ) do
	print( bits_format( "%6d %06X -> %16b %16b %16b %16b %16b %16b %16b", n, n, n,
		LSHIFT( n, 4 ),
		RSHIFT( n, 4 ),
		AND( n, binary( "1100" ) ),
		OR( n, binary( "1010" ) ),
		XOR( n, binary( "1010" ) ),
		NOT( n )
	) )
end

print( string.rep( "-", 140 ) )
print( string.format( "%6s %6s -> %16s %16s %16s %16s %16s %16s %16s", "dec", "hex", "bin", "lshift(4)", "rshift(4)", "and(#1100)", "or(#1010)", "xor(#1001)", "not()" ) )
print( string.rep( "-", 140 ) )
for i, n in ipairs( blist ) do
	local b = bits_unpack( n, 16 )

	print( string.format( "%6d %06X -> %16s %16s %16s %16s %16s %16s %16s ", n, n, bits_to_string( b ),
		bits_to_string( bits_lshift( b, 4 ) ),
		bits_to_string( bits_rshift( b, 4 ) ),
		bits_to_string( bits_and( b, bits_from_string( "0000000000001100" ) ) ),
		bits_to_string( bits_or( b, bits_from_string( "0000000000001010" ) ) ),
		bits_to_string( bits_xor( b, bits_from_string( "0000000000001001" ) ) ),
		bits_to_string( bits_not( b ) )
	) )
end
print( string.rep( "-", 140 ) )

local num = 5 -------------------------
print( bitwise.format( "The number %d left-shifted by 8 bits is %016b.", num, LSHIFT( num, 8 ) ) )


local t1, t2, b

-------------------------
-- STRESS TEST
-- bitwise::unpack
-------------------------

t1 = socket.gettime( )
for i = 1, 150000 do
	b = bits_unpack( 65535, 2 )
end
t2 = socket.gettime( )
print( string.format( "bitwise::unpack() %0.3fs", t2 - t1 ) )

-------------------------
-- STRESS TEST
-- bitwise::from_string
-------------------------

t1 = socket.gettime( )
for i = 1, 150000 do
	b = bits_from_string( "10111100" )
end
t2 = socket.gettime( )
print( string.format( "bitwise::from_string() %0.3fs", t2 - t1 ) )

-------------------------
-- STRESS TEST
-- bitwise::OR
-------------------------

t1 = socket.gettime( )
for i = 1, 150000 do
	b = OR( 1024, 255 )
end
t2 = socket.gettime( )
print( string.format( "bitwise::OR() %0.3fs", t2 - t1 ) )

-------------------------
-- STRESS TEST
-- bitwise::AND
-------------------------

t1 = socket.gettime( )
for i = 1, 150000 do
	b = AND( 1024, 65535 )
end
t2 = socket.gettime( )
print( string.format( "bitwise::AND() %0.3fs", t2 - t1 ) )

-------------------------
-- STRESS TEST
-- bitwise::XOR
-------------------------

t1 = socket.gettime( )
for i = 1, 150000 do
--	b = XOR( 1024, 65535 )
end
t2 = socket.gettime( )
print( string.format( "bitwise::XOR() %0.3fs", t2 - t1 ) )

-------------------------
-- STRESS TEST
-- bitwise::NOT
-------------------------

t1 = socket.gettime( )
for i = 1, 150000 do
	b = NOT( 255 )
end
t2 = socket.gettime( )
print( string.format( "bitwise::NOT() %0.3fs", t2 - t1 ) )
