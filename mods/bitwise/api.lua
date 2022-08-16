--------------------------------------------------------
-- Minetest :: Bitwise Helpers Mod v1.2 (bitwise)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2020, Leslie E. Krause
--
-- ./games/minetest_game/mods/bitwise/init.lua
--------------------------------------------------------

local on = true
local off = false

local max = math.max
local floor = math.floor
local byte = string.byte
local char = string.char
local insert = table.insert
local remove = table.remove

local nib_map = {
	[0] = { off, off, off, off },
	[1] = { off, off, off, on },
	[2] = { off, off, on, off },
	[3] = { off, off, on, on },
	[4] = { off, on, off, off },
	[5] = { off, on, off, on },
	[6] = { off, on, on, off },
	[7] = { off, on, on, on },
	[8] = { on, off, off, off },
	[9] = { on, off, off, on },
	[10] = { on, off, on, off },
	[11] = { on,  off, on, on },
	[12] = { on, on, off, off },
	[13] = { on, on, off, on },
	[14] = { on, on, on, off },
	[15] = { on, on, on, on }
}

local _ = nil

local function is_match( text, glob )
     _ = { string.match( text, glob ) }
     return #_ > 0
end

---------------------------------
-- Constructor Function
---------------------------------

local function bits_new( size, value )
	local bits = { }

	for idx = 1, size do
		table.insert( bits, value ~= nil and value )
	end
	return bits
end

---------------------------------
-- Type Conversion Functions
---------------------------------

local function bits_pack( bits )
	-- ensure bit field can fit correctly within 56-bit integer
	if #bits > 56 then error( "Invalid length of bit field" ) end

	num = 0
	for idx = 1, #bits do
		if bits[ idx ] then
			num = num + 2 ^ ( #bits - idx )
		end
	end
	return num
end

local function bits_pack_string( bits )
	local num = 0
	local str = ""
	for idx = 1, #bits do
		local pow = 7 - ( idx - 1 ) % 8		-- rollover every 8-bits

		if bits[ idx ] then
			num = num + 2 ^ pow
		end
		if pow == 0 then
			str = str .. char( num )
			num = 0
		end
	end
	return str
end

local function bits_unpack( num, size )
	if not tonumber( num ) or num < 0 then
		error( "Number outside of allowable range" )
	elseif not size then
		size = num < 256 and 8 or num < 65536 and 16 or 32
	elseif size > 56 then
		error( "Size outside of allowable range" )
	end

	local bits = { }
	local idx = 0
	while idx < size do
		local idx2 = size - idx
		local nib = nib_map[ floor( num / 2 ^ idx ) % 2 ^ 4 ]	-- get the nibbles

		bits[ idx2 - 3 ] = nib[ 1 ]
		bits[ idx2 - 2 ] = nib[ 2 ]
		bits[ idx2 - 1 ] = nib[ 3 ]
		bits[ idx2 - 0 ] = nib[ 4 ]
		idx = idx + 4
	end

	return bits
end

local function bits_to_string( bits, div )
	local str = ""
	for idx, val in ipairs( bits ) do
		if div and idx > 1 and idx % div == 1 then
			str = str .. " " .. ( val and "1" or "0" )
		else
			str = str .. ( val and "1" or "0" )
		end
	end
	return str
end

local function bits_from_string( str )
	local bits = { }
	for idx = 1, #str do
		local val = ( { [49] = true, [48] = false } )[ byte( str, idx ) ]
		if val ~= nil then
			insert( bits, val )
		end
	end
	return bits
end

function binary( str )
	return tonumber( str, 2 )
end

---------------------------------
-- String Formatting Function
---------------------------------

local function bits_format( str, ... )
	local args = { ... }

	local function parse_token( num, attr1, attr2, attr3 )
		if not tonumber( num ) or num < 0 then error( "Invalid or missing argument, expected number." ) end

		local len = math.min( tonumber( attr2 ) or 0, 56 ) or 0	-- limit to 56-bits
		local has_pad = attr1 == "0"
		local has_rev = attr1 == "-"
		local div = tonumber( attr3 ) or 0
		local res = ""

		local idx = 0
		while num > 0 or idx < len do
			local rem = num % 2

			-- prepend digits, since working from least to most significant bit
			if div > 0 and idx % div == 0 then
				res = " " .. res				-- insert space between sets
			end
			if rem == 1 then
				res = "1" .. res				-- insert digit 1
			elseif has_pad or num > 0 then
				res = "0" .. res				-- else, insert digit 0 or insert zero padding
			else
				res = has_rev and res .. " " or " " .. res	-- else, insert space padding
			end

			num = ( num - rem ) / 2
			idx = idx + 1
		end

		return res
	end

	str = string.gsub( str, "(%%(.-)([A-Za-z]))", function ( token, attrs, option )
		if option == "b" and ( is_match( attrs, "^([0-]?)([0-9]*)$" ) or is_match( attrs, "^([0-]?)([0-9]*):([0-9]+)$" ) ) then
			return parse_token( remove( args, 1 ), _[ 1 ], _[ 2 ], _[ 3 ] )
		else
			return string.format( token, remove( args, 1 ) )
		end
	end )

	return str
end

---------------------------------
-- Numeric Bitwise Operations
---------------------------------

function AND( num1, num2 )
	local exp = 1
	local res = 0
	local idx = 1
	while num1 > 0 and num2 > 0 do
		local rem1 = num1 % 2
		local rem2 = num2 % 2
		if rem1 + rem2 > 1 then
			-- set each bit
			res = res + exp
		end
		num1 = ( num1 - rem1 ) / 2
		num2 = ( num2 - rem2 ) / 2
		exp = exp * 2
	end
	return res
end

function OR( num1, num2 )
	local exp = 1
	local res = 0
	while num1 + num2 > 0 do
		local rem1 = num1 % 2
		local rem2 = num2 % 2
		if rem1 + rem2 > 0 then
			-- set each bit
			res = res + exp
		end
		num1 = ( num1 - rem1 ) / 2
		num2 = ( num2 - rem2 ) / 2
		exp = exp * 2
	end
	return res
end

function XOR( num1, num2 )
	local exp = 1
	local res = 0
	while num1 > 0 or num2 > 0 do
		local rem1 = num1 % 2
		local rem2 = num2 % 2
		if rem1 ~= rem2 then
			-- set each bit
			res = res + exp
		end
		num1 = ( num1 - rem1 ) / 2
		num2 = ( num2 - rem2 ) / 2
		exp = exp * 2
	end
	return res
end

function NOT( num )
	local exp = 1
	local res = 0
	while num > 0 do
		local rem = num % 2
		if rem == 0 then
			-- set each bit
			res = res + exp
		end
		num = ( num - rem ) / 2
		exp = exp * 2
	end
	return res
end

function NOT16( num )
	return XOR( num, 0xFFFF )	-- 16-bit logical NOT
end

function NOT32( num )
	return XOR( num, 0xFFFFFFFF )	-- 32-bit logical NOT
end

function LSHIFT( num, off )
	return num * 2 ^ off
end

function RSHIFT( num, off )
	return floor( num / 2 ^ off )
end

---------------------------------
-- Tabular Bitwise Operations
---------------------------------

local function bits_and( b1, b2 )
	if #b1 ~= #b2 then error( "Mismatched length of bit field" ) end

	local bits = { }
	for idx = 1, #b1 do
		bits[ idx ] = b1[ idx ] and b2[ idx ]
	end
	return bits
end

local function bits_or( b1, b2 )
	if #b1 ~= #b2 then error( "Mismatched length of bit field" ) end

	local bits = { }
	for idx = 1, #b1 do
		bits[ idx ] = b1[ idx ] or b2[ idx ]
	end
	return bits
end

local function bits_xor( b1, b2 )
	if #b1 ~= #b2 then error( "Mismatched length of bit field" ) end

	local bits = { }
	for idx = 1, #b1 do
		bits[ idx ] = b1[ idx ] ~= b2[ idx ]
	end
	return bits
end

local function bits_not( b )
	local bits = { }
	for idx = 1, #b do
		bits[ idx ] = not b[ idx ]
	end
	return bits
end

local function bits_rshift( b, off )
	local bits = { }
	for idx = 1, #b do
		bits[ idx ] = idx > off and b[ idx - off ]
	end
	return bits
end

local function bits_lshift( b, off )
	local bits = { }
	for idx = 1, #b do
		bits[ idx ] = idx <= #b - off and b[ idx + off ]
	end
	return bits
end

---------------------------------
-- Runtime Consistency Checks
---------------------------------

local function bits_check( )
	assert( bits_to_string( bits_and( bits_unpack( 255 ), bits_unpack( 15 ) ) ) == "00001111" )
	assert( bits_pack( bits_or( bits_unpack( 24 ), bits_unpack( 7 ) ) ) == 31 )
	assert( bits_pack_string( bits_unpack( 124 ) ) == "|" )
	assert( bits_pack( bits_from_string( "1011 1111 1001 1111" ) ) == 49055 )
	assert( bits_to_string( bits_not( bits_from_string( "1011 1111 1001 1111" ) ), 4 ) == "0100 0000 0110 0000" )
	assert( bits_to_string( bits_rshift( bits_from_string( "1001 1111" ), 4 ), 4 ) == "0000 1001" )
	assert( bits_to_string( bits_xor( bits_from_string( "11111100" ), bits_from_string( "00010110" ) ) ) == bits_format( "%b", XOR( binary( "11111100" ), binary( "00010110" ) ) ) )
	assert( bits_pack( bits_xor( bits_from_string( "00011111100" ), bits_from_string( "10100000000" ) ) ) == XOR( binary( "11111100" ), binary( "10100000000" ) ) )
	assert( bits_pack( bits_new( 4, false ) ) == 0 )
	assert( bits_pack( bits_new( 32, true ) ) == 0xFFFFFFFF )

	print( "[bitwise] All consistency checks passed!" )
end

---------------------------------
-- Export Public Functions
---------------------------------

return {
	new = bits_new,
	pack = bits_pack,
	pack_string = bits_pack_string,
	unpack = bits_unpack,
	to_string = bits_to_string,
	from_string = bits_from_string,
	format = bits_format,
	LSHIFT = bits_lshift,
	RSHIFT = bits_rshift,
	AND = bits_and,
	OR = bits_or,
	XOR = bits_xor,
	NOT = bits_not,
	check = bits_check,
}
