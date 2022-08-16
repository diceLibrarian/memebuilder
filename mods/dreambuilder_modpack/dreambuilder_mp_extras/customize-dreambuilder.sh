#!/bin/bash

# This script manages all of the various individual changes
# for dreambuilder, e.g. updating mods, copying file components,
# making changes to the code, etc.

upstream_mods_path="/home/vanessa/Minetest-related/mods"

if [ ! -d "$upstream_mods_path" ] ; then
	if [ ! -z $1 ] ; then
		upstream_mods_path=$1
	else
		echo "Script does not appear to be running on Vanessa's PC, so you must supply a mods path."
		exit 1
	fi
fi

workdir="/run/shm/dreambuilder_modpack"
modpack_path=$upstream_mods_path"/my_mods/dreambuilder_modpack"

rm -rf $modpack_path/* $workdir*
mkdir $workdir
touch $workdir/modpack.txt

echo -e "\nBring all mods up-to-date from "$upstream_mods_path

cd $upstream_mods_path

# No trailing slashes on these items' paths!
LINK_MODS_LIST="my_mods/biome_lib \
my_mods/coloredwood \
my_mods/currency \
my_mods/gloopblocks \
my_mods/ilights \
my_mods/moretrees \
my_mods/misc_overrides \
my_mods/nixie_tubes \
my_mods/led_marquee \
my_mods/pipeworks \
my_mods/signs_lib \
my_mods/basic_signs \
my_mods/street_signs \
my_mods/unifieddyes \
my_mods/simple_streetlights \
my_mods/basic_materials \
my_mods/dreambuilder_hotbar \
Calinous_mods/bedrock \
Calinous_mods/maptools \
Calinous_mods/moreores \
Sokomines_mods/cottages \
Sokomines_mods/locks \
Sokomines_mods/travelnet \
Sokomines_mods/windmill \
RBAs_mods/datastorage \
RBAs_mods/framedglass \
RBAs_mods/unified_inventory \
Mossmanikins_mods/memorandum \
cheapies_mods/plasticbox \
cheapies_mods/prefab_redo \
cheapies_mods/invsaw \
cheapies_mods/unifiedmesecons \
cheapies_mods/digistuff \
cheapies_mods/rgblightstone \
cheapies_mods/solidcolor \
cheapies_mods/arrowboards \
cheapies_mods/digidisplay \
cheapies_mods/display_blocks_redo \
Jeijas_mods/digilines \
Jeijas_mods/jumping \
TenPlus1s_mods/farming \
TenPlus1s_mods/bees \
TenPlus1s_mods/bakedclay \
TenPlus1s_mods/cblocks \
TenPlus1s_mods/bonemeal \
TenPlus1s_mods/ambience \
tumeninodes-mods/facade \
Zeg9s_mods/steel \
DonBatmans_mods/mymillwork \
HybridDogs_mods/titanium \
HybridDogs_mods/function_delayer \
quartz \
stained_glass \
gardening \
caverealms_lite \
deezls_mods/extra_stairsplus \
blox \
new_campfire \
item_drop"

COPY_MODS_LIST="my_mods/dreambuilder_mp_extras \
nekogloops_mods/glooptest \
Calinous_mods/moreblocks \
CWzs_mods/replacer \
CWzs_mods/player_textures \
bobblocks \
unifiedbricks"

LINK_MODPACKS_LIST="$(ls -d my_mods/homedecor_modpack/*/) \
$(ls -d my_mods/plantlife_modpack/*/) \
$(ls -d Zeg9s_mods/ufos/*/) \
$(ls -d Jeijas_mods/mesecons/*/) \
$(ls -d cheapies_mods/roads/*/) \
$(ls -d cool_trees/*/)"

COPY_MODPACKS_LIST="$(ls -d RBAs_mods/technic/*/) \
$(ls -d Philipbenrs_mods/castle-modpack/*/) \
$(ls -d worldedit/*/)"


for i in $LINK_MODS_LIST; do
	ln -s $upstream_mods_path"/"$i $workdir
done

for i in $(echo $LINK_MODPACKS_LIST |sed "s:/ : :g; s:/$::"); do
	ln -s $upstream_mods_path"/"$i $workdir
done

for i in $COPY_MODS_LIST; do
	rsync -a $upstream_mods_path"/"$i $workdir --exclude .git*
done

for i in $(echo $COPY_MODPACKS_LIST |sed "s:/ : :g; s:/$::"); do
	rsync -a $upstream_mods_path"/"$i $workdir --exclude .git*
done

# above, all the stuff of the form $(ls -d foo/*/) are modpacks
# those special commands copy out just the folders from within.

echo -e "\nConfigure Dreambuilder and its mods..."

# Disable some components

rm -f  $workdir/dreambuilder_mp_extras/models/character.b3d

rm -rf $workdir/orbs_of_time

rm -f  $workdir/bobblocks/trap.lua
touch  $workdir/bobblocks/trap.lua

rm -f  $workdir/replacer/inspect.lua
touch  $workdir/replacer/inspect.lua

rm -rf $workdir/wrench

sed -i "s/bucket//" \
    $workdir/unifiedbricks/depends.txt

sed -i "s/mesecons =/foo =/" \
    $workdir/bobblocks/blocks.lua

sed -i "s/LOAD_OTHERGEN_MODULE = true/LOAD_OTHERGEN_MODULE = false/" \
    $workdir/glooptest/module.cfg

sed -i 's/"stairsplus_in_creative_inventory", true)/"stairsplus_in_creative_inventory", false)/' \
    $workdir/moreblocks/config.lua

echo "moreblocks.stairsplus_in_creative_inventory (Display Stairs+ nodes in creative inventory) bool false" \
    > $workdir/moreblocks/settingtypes.txt

rm -rf $workdir/worldedit_brush

# Add in all of the regular player skins for the player_textures mod

rm -f $workdir/player_textures/textures/*

LIST="player_Calinou.png
player_cheapie.png
player_crazyginger72.png
player_Evergreen.png
player_Jordach.png
player_kaeza.png
player_oOChainLynxOo.png
player_PilzAdam_back.png
player_PilzAdam.png
player_playzooki.png
player_sdzen.png
player_ShadowNinja.png
player_shadowzone.png
player_Sokomine.png
player_VanessaE.png
player_Zeg9.png"

while read -r FILE; do
cp $upstream_mods_path"/../player_skins/"$FILE \
    $workdir/player_textures/textures
done <<< "$LIST"

ln -s $upstream_mods_path"/my_mods/dreambuilder_mp_extras/readme.md" $workdir

rsync -aL \
	--exclude=".git*" \
	$workdir"/" \
	$workdir"_no_git"

rsync -aL \
	$workdir"_no_git/" \
	$modpack_path

rm -rf $workdir*

echo -e "\nCustomization completed.  Here's what will be included in the modpack:\n"

ls -a $modpack_path
