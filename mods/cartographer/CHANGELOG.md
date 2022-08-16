# v1.2
- Add support for fallback textures based on heat/humidity when displaying unknown biomes
    - **NOTE:** This changes the biome registration API calls. See an example mod such as https://gitlab.com/Df458/cartographer-mtg for the new format
- Fix bug where changing biome IDs could break existing map data

# v1.1
- Adjust sizes/margins in table and map UI
- Expose more UI metrics (sizes, spacing) to the skin API
- Improve map appearance at certain resolutions
- Fix clipping of button content in newer engine versions
- Fix crash in scanner for generated chunks
- Fix crash in UI code

# v1.0
- Initial Release
