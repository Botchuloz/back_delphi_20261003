# Delphi


Delphi is a rotation-assist and keybind-allocation addon for World of Warcraft: Forever (WoWF). It works alongside its companion project, **Pythia**, which handles output/state reporting back to Delphi (`Core_Output_Pythia.lua` is the bridge between the two).


This document is written for both human contributors and AI assistants working on this codebase. Where a convention is stated, follow it literally rather than approximating it, consistency across class modules matters more than any single file being "clever."


## Related projects, do not confuse these


Delphi/Pythia has a sibling project pair for retail WoW: **Hermes** (rotation logic) and **Pixel** (its companion/output tool), analogous to how Delphi pairs with Pythia. Hermes and Pixel are separate codebases targeting a different game version, they may use different internal namespace names (e.g. `hermes.spec`, `hermes.class.Priest`) and may have conventions Delphi doesn't share (such as an aura-tracking table).


**Do not port a Hermes/Pixel convention into Delphi without verifying it against Delphi's actual source first.** This README documents Delphi's conventions only, based on Delphi's own `Class_Paladin.lua` and `Class_Priest.lua`, everything in the Delphi files uses `delphi.spec` / `delphi.class.<Name>`, not `hermes.*`.


## 1. Repository Map


| File | Role |
|---|---|
| `Delphi.toc` | Addon manifest, load order |
| `Core_Bootstrap.lua` | Initial addon load/setup |
| `Core_Events.lua` | Game event registration and dispatch |
| `Core_Input_Keybinds.lua` | Keybind allocation system (see Section 2) |
| `Core_Output_CLI.lua` | Console/chat-based output |
| `Core_Output_Pythia.lua` | Bridge to the Pythia companion tool |
| `Core_Output_UI.lua` | In-game UI/frame output |
| `Global_Blacklist.lua` | Global exclusion rules (units/spells/etc. to ignore) |
| `Global_Strings.lua` | Shared string constants |
| `Global_Tables.lua` | Shared lookup tables used across modules |
| `Item.lua` | Item-related helpers |
| `Spell.lua` | Spell-related helpers |
| `SpellUnit_CastLoops.lua` | Core casting loop logic shared across classes |
| `SpellUnit_Delegates_Bool.lua` | Boolean validity delegates (e.g. range, alive, hostile checks) used inside `CastSpellUnits` |
| `SpellUnit_Delegates_Rank.lua` | Delegates for spell rank selection |
| `Table.lua` | Generic table utility functions |
| `Unit_Abilities.lua` | Unit ability lookups |
| `Unit_Logic.lua` | Unit-state logic helpers |
| `Units.lua` | Unit ID/reference definitions (`_unitids`) |
| `World.lua` | World/zone/instance-state helpers |
| `Class_<Name>.lua` | Per-class rotation modules (e.g. `Class_Paladin.lua`, `Class_Priest.lua`), see Section 3 |


If you're an AI generating a new file, match the naming convention: `Core_*` for addon infrastructure, `Global_*` for shared cross-class data, `SpellUnit_*` for casting-delegate logic, `Class_*` for one file per class.


## 2. Keybind & Macro Allocation System


`Core_Input_Keybinds.lua` owns all bind allocation. Do not hardcode a specific key inside a class module, use the allocator so binds can never silently collide.


### Core tables


- `_bindable_keys` / `_bindable_mods`: raw keyboard key codes and modifier codes.
- `_combo_status` / `_combo_key_ascii` / `_combo_mod_ascii`: every generated modifier+key combination (e.g. `"LSHIFT-F9"`), and whether it's currently claimed.
- `_spellunit_to_combo_map`: maps a `spell..unit` string to its assigned combo.
- `_button`: holds the actual `SecureActionButtonTemplate` frames.


### Allocating a bind


Never assign a bind manually. Use the allocator functions:


```lua
BindSpellToUnit(spell, unit, prefix, suffix, skipcontents, DelegateMacroCreation)
BindSpellToUnits(spell, units, prefix, suffix, skipcontents, DelegateMacroCreation)
BindMacroToUnits(spell, units, prefix, suffix)
```


These call `GetNextFreeBind()` internally, which walks `_combo_status` and returns the first unclaimed combination. This guarantees no two spell/unit pairs ever end up on the same key, even as new binds are added over time.


### The bare-key blacklist


`bare_key_blacklist` removes specific *unmodified* keys from the allocator pool entirely (modified versions like `ALT-J` remain available), because they're claimed by the default WoW UI or by core movement/combat binds. Keys currently excluded, and why:


| Key | Reason |
|---|---|
| `W`, `A`, `S`, `D` | Movement |
| `1`–`4`, `0` | Action bar slots |
| `` ` ``, `[`, `]`, `/`, `-`, `;`, `=` | Reserved symbol keys |
| `M` | World Map |
| `C` | Character pane |
| `J` | Guild |
| `K` | Talents |
| `P` | Spellbook & Abilities |
| `L` | Quest Log |
| `O` | Social |
| `U` | Reputation pane |
| `H` | PvP/Honor pane (Classic-era default, carried into Forever) |
| `R` | Reply to last whisper |
| `T` | `ATTACKTARGET` on WoWF (differs from retail, where T is unbound/chat-related) |
| `F` | `ASSISTTARGET` on WoWF (differs from retail's "Interact with Target") |
| `G` | `TARGETLASTHOSTILE` on WoWF (differs from retail's ping) |
| `N`, `E`, `Q`, `B` | Reserved to avoid collisions with common default panel/action binds |
| Navigation keys (`INSERT`, `DELETE`, `HOME`, `END`, `PAGEUP`, `PAGEDOWN`, arrow keys) | Require modifiers for safety |
| `TAB`, `SPACE`, `ENTER` | Require modifiers |
| `BUTTON4`, `BUTTON5` | Mouse back/forward, require modifiers |


**Important WoWF-specific note:** T, F, and G are combat binds on WoW Forever by default (`ATTACKTARGET`, `ASSISTTARGET`, `TARGETLASTHOSTILE` respectively), datamined from the 12.1.5 PTR client. This differs from retail WoW, where these keys serve different or no default purpose. Any contributor porting assumptions from retail (Hermes-side) keybind knowledge should re-verify against Delphi's actual WoWF default bindings rather than assume parity.


## 3. Class Module Convention


Every class module (`Class_Paladin.lua`, `Class_Priest.lua`, etc.) follows a fixed internal structure. Use an existing file such as `Class_Priest.lua` as the structural reference when writing a new one.


A class file should generally contain these sections, in this order:


1. Local tables and Delphi references.
2. Spell-name definitions.
3. Optional specialization constants and helper functions.
4. One-time key/button and spell bindings.
5. The class core logic function.
6. Export of the class table into the global Delphi namespace.


### 3.1 Spell Definitions


Every spell must be declared in a local `_spell` table before it's referenced anywhere else:


```lua
_spell.mindblast = "Mind Blast"
```


The key is lowercase with no unnecessary separators; the value is the exact in-game spell name used in API calls.


Do not use a spell key that hasn't been initialized. A missing definition can result in `nil` being passed to a binding or cast call, which causes the rotation to fail silently rather than throwing a visible error, so this is easy to miss during testing.


Keep talent-only, utility, racial, pet, and macro names in the same `_spell` table when the class logic references them.


#### Aura and buff state


Delphi's Paladin and Priest implementations check buffs/auras inline against already-exposed unit state, they do not use a separate registration table:


```lua
unit.player.buff["Shadow Covenant"].remaining
```


Follow this inline pattern by default. Do not introduce a separate aura-tracking registration table (e.g. anything resembling `track_aura`) unless you've confirmed, by reading Delphi's actual supporting code, that such a table already exists and is consumed somewhere. That pattern belongs to Hermes, not Delphi, importing it here without confirmation would add dead or non-functional code.


### 3.2 Spell Binding


Every defined spell must be bound via the allocator (Section 2), never a raw key:


```lua
BindSpellToUnits(_spell.mindblast, _unitids.target)
```


Choose the unit group according to the spell's purpose:


- `_unitids.target` — the current target.
- `_unitids.standard_hostile` — hostile units, iterated for effects like damage-over-time spells.
- `_unitids.player` — the player.
- `_unitids.standard_friendly` — friendly units.


If the action is a macro rather than a spell, use `BindMacroToUnits()` instead. Binding happens once, typically in the module's `SetBinds` function, not inside the per-frame logic loop. When you add a new cast, update the `_spell` definition and its binding together in the same change, not as separate follow-ups.


### 3.3 Specialty Delegate Functions


Custom validity/targeting helpers are defined above the main logic block, only when the standard delegate library (`SpellUnit_Delegates_Bool.lua`, `SpellUnit_Delegates_Rank.lua`) doesn't already cover the case:


```lua
function SpellUnit_NoRecentCasting(spell, unit)
    return not RecentCasting(spell)
end
```


Helpers should:


- Have a descriptive name that explains the condition, prefixed `SpellUnit_` when acting as a per-spell/unit validity check.
- Return a clear boolean, or whatever value type the caller expects.
- Avoid hidden side effects.
- Reuse existing Delphi state/utility functions where possible, rather than re-deriving something already available.
- Be defined before the code that calls them.


Keep class-specific helpers in the class file unless they're genuinely shared by multiple classes.


### 3.4 Cast Sequence Logic (`CoreLogic`)


All per-frame casting decisions for every spec in the class live in one function:


```lua
function _priest.CoreLogic()
    ...
end
```


Use the appropriate class name for other classes, e.g. `_paladin.CoreLogic()`.


**Opening pattern:** the function body always starts with `if 1==0 then` (always false), so every real condition that follows is an `elseif`. This keeps the whole decision tree as one flat, scannable chain instead of nested `if` blocks, and makes it easier for humans and AI tools to insert, disable, or compare branches without restructuring surrounding control flow. Don't replace this opening with an unconditional `if` unless there's a specific reason to change the project-wide convention. Anything written between `if 1==0 then` and the first real `elseif` is a comment-only placeholder for spec-specific exceptions, not live code.


**Shared exceptions**, checked before any spec branch, in this order:


```lua
elseif RedLight() then
    _global.Off()
elseif hermes.unit.player.channelling and hermes.unit.player.cast_remaining > 0.1 then
    print("CHANNELLING")
    _global.Off()
```


Other class-wide exceptions that belong ahead of the main sequence: pet-target recovery, mount/movement handling, and any other safety behavior that must override every spec's rotation.


**Per-spec branches**, one `elseif` per spec against `delphi.spec`, each visually separated with an ASCII banner comment for readability:


```lua
elseif discipline_spec == delphi.spec then ...
elseif holy_spec == delphi.spec then ...
elseif shadow_spec == delphi.spec then ...
end
```


**Inside each spec branch**, nesting is fixed, in this order:


1. PvE vs PvP (`pvp_off` / `pvp_on`)
2. Single-target vs AoE (`GodlyIsDD()` / `GodlyIsAOE()`)
3. Healing vs DPS (`heal_on` / `dps_on`)
4. Healer style, if healing (`regular_healer` / `attack_healer`)


Set a readable prefix at the top of each branch (e.g. `spam_string = "shadow_"`) and build it incrementally down this chain for diagnostic printing. Try higher-priority casts before lower-priority ones within a branch.


**Innermost cast chain** follows the same `if 1==0 then` pattern:


```lua
if 1 == 0 then
elseif CastSpellUnits(
    _spell.mindblast
    ,_unitids.target
    ,RemainingCooldown(_spell.mindblast) < 0.5 and stationary
    ,{
        SpellUnit_UnitAliveAndHostile
        ,SpellUnit_RangeCheck
        ,SpellUnit_ValidHarm
    }
) then print("Mind Blast")
else _global.Off()
end
```


`CastSpellUnits` args: spell, target unit, a boolean gate (cooldown/state), and a delegate list that must all pass.


Any branch not yet meaningfully handled should still terminate in a stub, so the tree stays complete and traceable:


```lua
else
    spam_string = spam_string .. "wtf?"
    print(spam_string)
end
```


Keep debug output intentional, avoid leaving noisy prints active unless they're meant for production diagnostics.


### 3.5 Empty-Class or Placeholder Sequence


When a class has no implemented rotation yet, keep the full structure and include one harmless example cast so the binding and sequence conventions stay visible for the next contributor (human or AI) to extend. A placeholder file should still have:


- A spell definition, e.g. `_spell.mindblast = "Mind Blast"`.
- A matching binding, e.g. `BindSpellToUnits(_spell.mindblast, _unitids.target)`.
- A `CoreLogic()` function beginning with `if 1==0 then`.
- A specialization branch containing the example cast.
- The normal global export at the end of the file (Section 3.6).


Replace the example with the real priority sequence when implementing the class for real, don't leave the placeholder cast in alongside genuine logic.


### 3.6 Closing the Module


Every module ends by exporting its spell table into the shared namespace:


```lua
-- pack it up and store it in global space
_paladin.spell = _spell
delphi.class.Paladin = _paladin
```


The names must match the class and namespace actually used elsewhere in that file, verify against the file's own `delphi.spec` references rather than assuming, don't copy this block into a new file without adjusting `_paladin`/`Paladin` to the correct class.


## 4. Error Handling & Taint Safety


WoWF's secure execution environment can produce "secret values" (protected/tainted data) when reading combat state during restricted moments. Wrap potentially unsafe reads, such as spell cooldowns, cast info, and charge counts, in `pcall`, and check for secret values before using the result, rather than assuming a raw API call always returns a plain usable value. This prevents an addon crash from cascading into a broken UI mid-combat.


## 5. Verification Discipline


This project targets WoW Forever specifically, a Classic+ ruleset that diverges from both retail and vanilla Classic in ways that aren't always obvious:


- Do not assume retail keybind defaults, retail API behavior, or retail creature-type/race interactions carry over. For example, `UnitCreatureType("player")` returns `"Humanoid"` for Undead-race characters on WoWF, unlike standard WoW where Undead players return `"Undead"`, this breaks naive Exorcism/Turn Undead-style validity checks.
- WoWF's client API is the modern retail/Midnight-era API, not the Classic API, despite the ruleset being Classic+. Prefer namespaced `C_*` tables (e.g. `C_Spell`, `C_Minimap`, `C_Timer`) over old bare globals whenever both exist. Confirmed so far: `GetNumTrackingTypes()`/`GetTrackingInfo()` are `nil` on WoWF, use `C_Minimap.GetNumTrackingTypes()`/`C_Minimap.GetTrackingInfo(i)` instead (see `SpellUnit_AnyTrackingActive()` in `Class_Paladin.lua`). Add a defensive `C_X and C_X.Func` check around any newly-used API rather than assuming a Classic-era global still exists.
- Do not assume a Hermes/Pixel (retail) convention applies to Delphi/Pythia (WoWF) just because the two projects look structurally similar. Verify against Delphi's own source first.
- When documenting or claiming a piece of WoWF behavior, prefer verifying it live in-game over assuming parity with retail or Classic. If a claim can't be verified, say so explicitly rather than asserting it as fact.
- Only reference API functions that are documented for the current WoWF client version. Don't invent or guess at function names.


## 6. Commit Conventions


Keep commits single-purpose where practical, a keybind logic fix and a blacklist table expansion are separate concerns even if done in the same sitting, and should generally be separate commits so the history stays easy to audit and, if needed, individually revert.


## 7. AI Editing Guidance


When modifying a class file, don't infer that a spell is available merely because it appears in a comment, search both the `_spell` definitions and the binding section before relying on it. When adding a new cast, update both locations in the same change.


Don't invent or import framework conventions from a single example, from another AI's prior attempt, or from a related-but-distinct project (see Section "Related projects" above). For anything not explicitly documented here, inspect Delphi's actual class and utility code first, and prefer the pattern already established there over a plausible-sounding alternative.


When adding a new specialization branch, preserve the existing branch order and `elseif` style. Keep emergency and channeling exceptions ahead of the main sequence. Prefer small, explicit conditions over opaque abstractions so the rotation stays auditable by both players and automated code-review tools.


## Implementation Checklist


Before committing a class rotation, verify:


- [ ] Every referenced spell has an exact `_spell.<key> = "In-Game Spell Name"` definition.
- [ ] Every castable spell has a matching `BindSpellToUnits()` call.
- [ ] Every macro has a matching `BindMacroToUnits()` call.
- [ ] The target unit group is appropriate for each action.
- [ ] Aura/buff checks follow Delphi's existing inline pattern; no `track_aura`-style table is added without confirmed supporting code.
- [ ] Optional helper functions are defined before use and return the expected type.
- [ ] All specs are handled inside the class's `CoreLogic()` function.
- [ ] Class-wide exceptions occur before the main `if 1==0 then` sequence.
- [ ] The main sequence begins with `if 1==0 then` and uses `elseif` branches throughout, including the inner `CastSpellUnits` chain.
- [ ] Each cast has suitable alive, range, harmful/helpful, aura, movement, or cooldown checks.
- [ ] `_global.Off()` is used when no action should be issued.
- [ ] Unhandled branches still terminate in a `wtf?` stub rather than being silently missing.
- [ ] The module is exported with the correct project namespace and class name (`delphi.class.<Name>`), verified against that file's actual references, not copied blind.
- [ ] Debug prints are intentional and don't create excessive chat output.
