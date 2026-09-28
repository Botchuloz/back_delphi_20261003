# Hermes Class Rotation Guide

This repository contains class-specific Lua rotation logic for Hermes. Each class file defines the spells it can use, binds those spells to unit groups, optionally adds helper functions, and implements the cast sequence for every specialization.

This README is written for both maintainers and AI/code agents: follow the structure below when creating or updating a class rotation file.

## API version notes

WoW: Forever (WoWF) runs on the modern retail/Midnight-era client API, not the Classic API. This matters for editing any file in this repo:

- Prefer the namespaced `C_*` API tables (e.g. `C_Spell`, `C_Minimap`, `C_Timer`) over old bare globals whenever both exist. WoWF has already been confirmed to drop at least one Classic-era global entirely: `GetNumTrackingTypes()` / `GetTrackingInfo()` are `nil` on this client; use `C_Minimap.GetNumTrackingTypes()` / `C_Minimap.GetTrackingInfo(i)` instead.
- Do not assume a Classic global still exists just because it worked in vanilla/TBC/Wrath Classic addons. Verify against the current retail/Midnight `warcraft.wiki.gg` API documentation before using it, and add a defensive `C_X and C_X.Func` check (see `SpellKnown()` and `SpellUnit_AnyTrackingActive()` in `Class_Paladin.lua`) so a missing function fails safely instead of throwing.
- When a runtime error like `attempt to call a nil value` names a function, check first whether it has moved into a `C_*` namespace before assuming it's a typo or missing bind.

## Class file responsibilities

A class file should generally contain these sections, in this order:

1. Local tables and Hermes references.
2. Spell-name definitions.
3. Optional specialization constants and helper functions.
4. One-time key/button and spell bindings.
5. The class core logic function.
6. Export of the class table into the global Hermes namespace.

Use an existing file such as `Class_Priest.lua` as the structural reference.

## 1. Define every spell first

Every spell referenced by the class must be defined in the `_spell` table before it is used elsewhere. The value must be the exact in-game spell name.

```lua
_spell.mindblast = "Mind Blast"
```

Use a consistent Lua key that is easy to recognize in conditions and casts. Do not use a spell key that has not been initialized. A missing definition can result in `nil` being passed to binding or cast functions, making the rotation silently fail.

If the spell needs aura tracking, initialize its tracking entry when defining it:

```lua
_spell.devouring_plague = "Devouring Plague"
hermes.track_aura[_spell.devouring_plague] = {} -- unique(1)
```

Keep talent-only, utility, racial, pet, and macro names in the same table when they are referenced by the class logic.

## 2. Bind every usable spell

Defining a spell is not enough. Every spell that the rotation may cast must also be bound to the appropriate unit group in `SetBinds()`.

For example:

```lua
BindSpellToUnits(_spell.mindblast, _unitids.target)
```

Choose the unit group according to the spell's target:

- `_unitids.target` — the current target.
- `_unitids.standard_hostile` — hostile units that can be iterated for effects such as damage-over-time spells.
- `_unitids.player` — the player.
- `_unitids.standard_friendly` — friendly units.

A typical binding section might look like this:

```lua
BindSpellToUnits(_spell.mindblast,        _unitids.target)
BindSpellToUnits(_spell.shadow_word_pain, _unitids.standard_hostile)
BindSpellToUnits(_spell.shadowform,       _unitids.player)
```

If the action is a macro rather than a spell, use `BindMacroToUnits()` instead. Spell definitions and bindings should be kept together enough that a maintainer can quickly verify that every castable action has both parts.

## 3. Add optional helper functions when needed

Specialized helper functions may be added for conditions that are reused or are too complex to keep inline. For example:

```lua
function SpellUnit_NoRecentCasting(spell, unit)
    return not RecentCasting(spell)
end
```

Helpers should:

- Have a descriptive name that explains the condition.
- Return a clear boolean or the value expected by the caller.
- Avoid hidden side effects.
- Reuse existing Hermes state and utility functions where possible.
- Be defined before the code that calls them.

Keep class-specific helpers in the class file unless they are genuinely shared by multiple classes.

## 4. Put all specialization sequences in `CoreLogic()`

The cast sequence logic for **all specs of the class** belongs in:

```lua
function _priest.CoreLogic()
    -- class-wide exceptions and all specialization sequences go here
end
```

Use the appropriate class name for another class, such as `_paladin.CoreLogic()`.

The code before the main sequence is generally reserved for exceptions that should take priority over every specialization rotation, such as:

- A red-light or emergency stop condition.
- Interrupting or stopping automation while channeling.
- Pet-target recovery.
- Mount or movement handling.
- Other class-wide safety behavior.

The main sequence should begin with the deliberately false branch below:

```lua
if 1 == 0 then
    -- placeholder for special logic or an intentionally empty first branch
elseif discipline_spec == hermes.spec then
    -- Discipline sequence
elseif holy_spec == hermes.spec then
    -- Holy sequence
elseif shadow_spec == hermes.spec then
    -- Shadow sequence
end
```

### Why begin with `if 1 == 0 then`?

This makes every real sequence an `elseif`. It gives the file a consistent visual structure and makes it easier for humans and AI tools to insert, disable, compare, and review branches without changing the surrounding control flow.

Do not replace the first branch with an unconditional `if` unless there is a specific reason to change the project convention.

### Sequence guidelines

Within each specialization branch:

1. Set a readable sequence prefix, such as `"shadow_"`.
2. Check mode toggles and context such as PvE/PvP, single-target/AoE, healing/DPS, movement, and cooldown settings.
3. Try higher-priority casts before lower-priority casts.
4. Use `CastSpellUnits()` with the spell, unit group, permission condition, and validation checks.
5. Turn the global action off when no spell is valid.
6. Keep debug output useful and avoid noisy output in production unless it is intentional.

Example:

```lua
elseif shadow_spec == hermes.spec then
    spam_string = "shadow_"

    if dps_on then
        if CastSpellUnits(
            _spell.mindblast,
            _unitids.target,
            RemainingCooldown(_spell.mindblast) < 0.5 and stationary,
            {
                SpellUnit_UnitAliveAndHostile,
                SpellUnit_RangeCheck,
                SpellUnit_ValidHarm
            }
        ) then
            print("Mind Blast")
        else
            _global.Off()
        end
    else
        _global.Off()
    end
end
```

## Empty-class or placeholder sequence

When a class has no implemented rotation yet, keep the full structure and include one harmless example cast so the binding and sequence conventions remain visible. The placeholder should still have:

- A spell definition, such as `_spell.mindblast = "Mind Blast"`.
- A matching binding, such as `BindSpellToUnits(_spell.mindblast, _unitids.target)`.
- A `CoreLogic()` function beginning with `if 1 == 0 then`.
- A specialization branch containing the example cast.
- The normal global export at the end of the file.

Replace the example with the real priority sequence when implementing the class.

## 5. Export the class at the end

Finish by exposing the spell table and class object through the project's global namespace. The names must match the class and the namespace used by the rest of the repository.

For the Priest implementation, the ending is conceptually:

```lua
--pack it up and store it in global space
_priest.spell = _spell
hermes.class.Priest = _priest
```

The requested Paladin-style template is:

```lua
--pack it up and store it in global space
_paladin.spell = _spell
delphi.class.Paladin = _paladin
```

Use the Paladin form only if the surrounding project actually uses `_paladin` and `delphi`. In this repository, `Class_Priest.lua` uses `hermes.class.Priest`; blindly copying the Paladin/Delphi names would export the class incorrectly.

## Implementation checklist

Before committing a class rotation, verify:

- [ ] Every referenced spell has an exact `_spell.<key> = "In-Game Spell Name"` definition.
- [ ] Every castable spell has a matching `BindSpellToUnits()` call.
- [ ] Every macro has a matching `BindMacroToUnits()` call.
- [ ] The target unit group is appropriate for each action.
- [ ] Aura tracking is initialized where required.
- [ ] Optional helper functions are defined before use and return the expected type.
- [ ] All specs are handled inside the class's `CoreLogic()` function.
- [ ] Class-wide exceptions occur before the main `if 1 == 0 then` sequence.
- [ ] The main sequence begins with `if 1 == 0 then` and uses `elseif` branches.
- [ ] Each cast has suitable alive, range, harmful/helpful, aura, movement, or cooldown checks.
- [ ] `_global.Off()` is used when no action should be issued.
- [ ] The class is exported with the correct project namespace and class name.
- [ ] Debug prints are intentional and do not create excessive chat output.

## AI editing guidance

When modifying a class file, do not infer that a spell is available merely because it appears in a comment. Search both the `_spell` definitions and the binding section. If adding a new cast, update both locations in the same change.

When adding a new specialization branch, preserve the existing branch order and `elseif` style. Keep emergency and channeling exceptions ahead of the main sequence. Prefer small, explicit conditions over opaque abstractions so the rotation remains auditable by both players and automated code-review tools.
