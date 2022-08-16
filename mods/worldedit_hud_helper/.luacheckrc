quiet = 1
codes = true

exclude_files = {
	".luarocks/*",
	"worldeditadditions/utils/bit.lua"
}


ignore = {
	"631", "61[124]",
	"542",
	"412",
	"321/bit",
	"21[123]"
}

-- Read-write globals (i.e. they can be defined)
globals = {
	"worldedit",
	"worldeditadditions",
	"worldeditadditions_commands",
	"worldeditadditions_core",
	"worldedit_hud_helper"
}
-- Read-only globals
read_globals = {
	"minetest",
	"vector",
	"assert",
	"bit",
	"it",
	"describe",
	"bonemeal",
	"dofile"
}
std = "max"
