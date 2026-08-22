-- freezeshow: a capture-only staging pack for PR media. NOT part of the repo.
--
-- Stages one player-team FREEZE TIME cast deterministically, so the same
-- seeded run can be filmed on master and on the branch and compared frame
-- for frame. The two calls below are exactly what
-- packs/core/families/living-03-mage.lua's freeze_time() performs when a
-- team-0 mage casts its slot-3 special:
--     og.set_enemy_freeze(og.enemy_freeze() + 20 + 11 * self.level)
--     og.set_palette(1); og.emit_event(C.EVENT_SET_PALETTE, 1)
-- 152 == 20 + 11 * 12, one cast by the level-12 mage that
-- tests/parity/scenario_table.h's enemy_freeze_mage_scen99 uses.
--
-- Why staged instead of an AI cast: openglad_demo matches its team-0 crew to
-- the level's enemy levels, and no stock campaign level fields an enemy above
-- level 12, while FREEZE TIME costs 500 magic points (a mage carries
-- 10 + 3 * 16 * level, i.e. 490 at level 10). Staging makes the freeze land on
-- the same tick in both builds, which is what an A/B needs.
--
-- The two ordinary notifications are stand-ins for whatever real messages a
-- level pushes while a freeze is running: on master the per-10-tick
-- "TIME LEFT" notification evicts them from the 5-line feed within ~50 ticks.

local C = og.C
local LEVEL = 1

local function on_load(level)
  og.emit_notification("THE GATE GRINDS OPEN", 40)
  og.emit_notification("REINFORCEMENTS SIGHTED", 90)
  og.set_enemy_freeze(152)
  og.set_palette(1)
  og.emit_event(C.EVENT_SET_PALETTE, 1)
end

og.register_level_hooks(LEVEL, { on_load = on_load })
