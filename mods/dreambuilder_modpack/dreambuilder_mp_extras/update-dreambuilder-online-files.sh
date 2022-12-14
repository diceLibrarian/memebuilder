#!/bin/bash

echo -e "\nBuilding Dreambuilder ..."
echo -e "=================================================================\n"

/home/vanessa/Minetest-related/Scripts/customize-dreambuilder.sh

timestamp=`date +%Y%m%d-%H%M`

echo -e "\nUpdate git repos..."
echo -e "=================================================================\n"

cd /home/vanessa/Minetest-related/mods/my_mods/dreambuilder_modpack
git add .
git commit -a
git push
git tag $timestamp
git push --tags
cd ~

echo -e "\nDone.  Build timestamp: $timestamp \n"

