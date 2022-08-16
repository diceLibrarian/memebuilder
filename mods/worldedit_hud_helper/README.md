# WorldEdit HUD Helper [worldedit_hud_helper]

> A helpful HUD that shows the name of the node you're pointing at and the direction you're pointing in.
> Makes using WorldEdit that little bit easier :-)

Despite the name, it doesn't actually depend on `worldedit` at all!

**Forum Link:** https://forum.minetest.net/viewtopic.php?f=9&t=20804

![](https://gitlab.com/sbrl/worldedit_hud_helper/raw/master/screenshots/screenshot_a.png)

## Usage
After installing the mod and restarting your server, you should see it appear automagically above your hotbar.

To toggle its display, use the `//hud` command - it takes no arguments.


## Changelog
 - v0.1: 14th September 2018
	 - Initial release.
 - v0.2: 16th September 2018
     - Fix undeclared global variable access.
 - v0.3: 2nd May 2020
     - Fix potential bug in raycast
     - Ignore `wielded_light:*` nodes when raycasting
 - v0.4: 31st May 2021
     - Fix deprecation warning for `getpos` → `get_pos` (#2)
 - v0.5: 31st July 2021
     - Add `//hudoffset [<offset_in_pixels>]` chat command to adjust the vertical offset of the HUD (fixes #1)
     - Persist per-player settings to disk (per-world)


## More Screenshots
![](https://gitlab.com/sbrl/worldedit_hud_helper/raw/master/screenshots/screenshot_b.png)
![](https://gitlab.com/sbrl/worldedit_hud_helper/raw/master/screenshots/screenshot_c.png)
![](https://gitlab.com/sbrl/worldedit_hud_helper/raw/master/screenshots/screenshot_d.png)


## Chat commands
worldedit_hud_helper provides 2 chat commands:

## `//hud`
Toggles whether the HUD is shown or not.


## `//hudoffset <offset_in_pixels>`
Adjusts the vertical height of the HUD. For example, to adjust it to be greater (higher up on the screen), do this:

```
//hudoffset 50
```

The default value is 0. You can reset to the default value like this:

```
//hudoffset
```


## License
This mod is licensed under the _Mozilla Public License 2.0_, a copy of which (along with a helpful summary as to what you can and can't do with it) can be found in the [`LICENSE`](https://gitlab.com/sbrl/worldedit_hud_helper/blob/master/LICENSE) file in this repository.

If you'd like to do something that the license prohibits, please get in touch as it's possible we can negotiate something.
