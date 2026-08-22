-- potionlab: capture-only staging pack for PR media. NOT part of the repo.
-- Drops one speed potion on top of each team-0 walker so the shared potion
-- tail in packs/core/lib/treasure_consumables.lua fires immediately.
local C = og.C
local FAM_POTION = og.family_id("treasure", "core:speed_potion")

local function on_tick(level, tick)
  if tick ~= 20 then
    return
  end
  local list = og.oblist()
  for i = 1, #list do
    local w = list[i]
    if w ~= nil and w:team_num() == 0 and w:order() == C.ORDER_LIVING then
      local p = og.add_fx_ob("treasure", FAM_POTION)
      if p ~= nil then
        p:s_set_level(3)
        p:set_floor(w:floor())
        p:setxy(w:xpos(), w:ypos())
      end
    end
  end
end

og.register_level_hooks(1, { on_tick = on_tick })
