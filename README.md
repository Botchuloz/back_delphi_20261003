# Delphi



Delphi is a rotation-assist and keybind-allocation addon for World of Warcraft: Forever (WoWF). It works alongside its companion project, **Pythia**, which handles output/state reporting back to Delphi (`Core_Output_Pythia.lua` is the bridge between the two).



This document is written for both human contributors and AI assistants working on this codebase. Where a convention is stated, follow it literally rather than approximating it, consistency across class modules matters more than any single file being "clever."



**Source/version note:** The controls and Paladin tracking sections below describe the replacements supplied in this conversation. A supplied file is not automatically installed or committed to GitHub. When a local file and the repository differ, verify which version you are actually testing.



## Related projects, do not confuse these



Delphi/Pythia has a sibling project pair for retail WoW: **Hermes** (rotation logic) and **Pixel** (its companion/output tool), analogous to how Delphi pairs with Pythia. Hermes and Pixel are separate codebases targeting a different game version, they may use different internal namespace names (e.g. `hermes.spec`, `hermes.class.Priest`) and may have conventions Delphi doesn't share.



**Do not port a Hermes/Pixel convention into Delphi without verifying it against Delphi's actual source first.** This README documents Delphi's conventions only, based on Delphi's own `Class_Paladin.lua` and `Class_Priest.lua`. Use `delphi.*` and the namespace in the actual Delphi class being edited, not `hermes.*`; do not assume that the Paladin role dispatcher and the Priest spec dispatcher have the same shape.



**Correction to an earlier version of this README:** Delphi itself has a `delphi.track_aura` table consumed by `Core_Events.lua`. Its existence is not a reason to register every buff or minimap tracking spell in that table, but it must not be dismissed as a Hermes-only convention.



## 1. Repository Map



| File | Role |
|---|---|
| `Delphi.toc` | Addon manifest, load order |
| `Core_Bootstrap.lua` | Initial addon load/setup, event registration and class core tick |
| `Core_Events.lua` | Game event registration and dispatch |
| `Core_Input_Keybinds.lua` | Keybind allocation system (see Section 2) |
| `Core_Output_CLI.lua` | Console/chat-based output |
| `Core_Output_Pythia.lua` | Bridge to the Pythia companion tool |
| `Core_Output_UI.lua` | In-game UI/frame output and NUMPAD mode bindings |
| `Core_Output_ToggleUI.lua` | Draggable icon picker for Mode, Context, Healing, Role, Aura, Blessing, Seal and Debuff Seal |
| `Global_Abilities_Racials.lua` | Racial and profession spell detection |
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
| `Unit_Logic.lua` | Unit-state logic helpers, including `GodlyIsOff()`, `GodlyIsDD()`, `GodlyIsAOE()` and `RedLight()` |
| `Units.lua` | Unit ID/reference definitions (`_unitids`) |
| `World.lua` | World/zone/instance-state helpers |
| `Class_<Name>.lua` | Per-class rotation modules (e.g. `Class_Paladin.lua`, `Class_Priest.lua`), see Section 3 |



If you're an AI generating a new file, match the naming convention: `Core_*` for addon infrastructure, `Global_*` for shared cross-class data, `SpellUnit_*` for casting-delegate logic, `Class_*` for one file per class.



Read `Delphi.toc` when adding a dependency. The output/UI files load before the class files; the event and bootstrap files load after the class files. A global may exist in a later file but not yet be available at the point a UI file runs.



## 2. Keybind & Macro Allocation System



`Core_Input_Keybinds.lua` owns all bind allocation. Do not hardcode a specific allocator key inside a class module, use the allocator so binds can never silently collide.



### Core tables



- `_bindable_keys` / `_bindable_mods`: raw keyboard key codes and modifier codes.
- `_combo_status` / `_combo_key_ascii` / `_combo_mod_ascii`: every generated modifier+key combination (e.g. `"LSHIFT-F9"`), and whether it's currently claimed.
- `_spellunit_to_combo_map`: maps a `spell..unit` string to its assigned combo.
- `_button`: holds the actual `SecureActionButtonTemplate` frames.



### Allocating a bind



Never assign an allocator bind manually. Use the allocator functions:



```lua
BindSpellToUnit(spell, unit, prefix, suffix, skipcontents, DelegateMacroCreation)
BindSpellToUnits(spell, units, prefix, suffix, skipcontents, DelegateMacroCreation)
BindMacroToUnits(spell, units, prefix, suffix)
```



These call `GetNextFreeBind()` internally, which walks `_combo_status` and returns an unclaimed combination. This prevents two allocated spell/unit pairs from silently sharing a key. Do not assume the specific next key is stable across runs: verify the allocator's iteration and available-key state when debugging a bind.



`Core_Output_UI.lua` also has deliberately designated NUMPAD control buttons created with `CreateButton()`. Those project-wide controls are different from arbitrarily assigning a class spell one of the allocator's keys.

The inbound `follow` whisper command is queued from the sender and requires a deliberate keypress. Delphi allocates the action a key through the normal bind allocator and signals that key through the global Pythia pixel while the request is pending. Pressing the pixel-indicated key targets and follows that sender; the pixel returns to the normal sequence recommendation after the keypress. If the whisper arrives during combat, the macro is armed after combat ends and its keypress does nothing while combat-locked. Delphi does not attempt the protected action from the chat event.


### The bare-key blacklist



`bare_key_blacklist` removes specific *unmodified* keys from the allocator pool entirely (modified versions like `ALT-J` remain available), because they're claimed by the default WoW UI or by core movement/combat binds. Keys recorded in the original README as excluded, and their reasons:



| Key | Reason |
|---|---|
| `W`, `A`, `S`, `D` | Movement |
| `1`–`4`, `0` | Action bar slots |
| `F1`–`F4` | Default self/party target selection |
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



**Important WoWF-specific note:** The original README describes T, F, and G as combat binds on WoW Forever by default (`ATTACKTARGET`, `ASSISTTARGET`, `TARGETLASTHOSTILE` respectively), datamined from a 12.1.5 PTR client. That datamine was **not independently verified in this editing session**; treat it as the project's recorded rationale and re-verify against the current client before relying on it. This differs from retail WoW, where these keys may serve different or no default purpose. Any contributor porting assumptions from retail (Hermes-side) keybind knowledge should re-verify against Delphi's actual WoWF default bindings rather than assume parity.



## 3. Class Module Convention



Every class module (`Class_Paladin.lua`, `Class_Priest.lua`, etc.) follows a recognizable internal structure. Use an existing file such as `Class_Priest.lua` as the structural reference when writing a new one, but inspect the actual file before assuming that every class has the Paladin's Role/Healing grid or the Priest's specialization dispatch.



A class file should generally contain these sections, in this order:



1. Local tables and Delphi references.
2. Spell-name definitions.
3. Optional specialization constants and helper functions.
4. One-time key/button and spell bindings.
5. The class core logic function.
6. Export of the class table into the global Delphi namespace.



### 3.1 Spell Definitions



Every spell referenced through a local `_spell` key must be declared in that `_spell` table before the key is used:



```lua
_spell.mindblast = "Mind Blast"
```



The key follows the naming convention in its class file; Paladin also uses underscores, such as `_spell.seal_of_command`. The value is the exact in-game spell name used in API calls. Do not rename valid underscore-separated keys merely to satisfy an older README description.



Do not use a spell key that hasn't been initialized. A missing definition can result in `nil` being passed to a binding or cast call, which causes the rotation to fail silently rather than throwing a visible error, so this is easy to miss during testing.



Keep talent-only, utility, racial, pet, and macro names in the same `_spell` table when the class logic references them through `_spell`. Direct names supplied by verified profession/racial detection or used for the tracking bindings are not undeclared `_spell` keys.



#### Aura and buff state



Delphi's Paladin and Priest implementations can check buffs/auras inline against already-exposed unit state:



```lua
unit.player.buff["Shadow Covenant"].remaining
```



Follow the existing inline pattern where it applies. **The earlier assertion that Delphi has no aura-tracking registration table was incorrect:** `delphi.track_aura` exists and `Core_Events.lua` consumes it for selected combat-log tracking. Do not add a tracking-table entry by reflex; confirm whether its event consumer actually needs one. Conversely, do not remove existing `delphi.track_aura` support on the mistaken belief that it belongs only to Hermes.



Minimap tracking is a separate concern. A scan of player `HELPFUL` auras did not preserve the manually selected Find Herbs tracking in the user's test; the supplied Paladin replacement checks the relevant minimap entries by name instead (Section 3.8).



### 3.2 Spell Binding



Every spell the rotation **may cast** must be bound via the allocator (Section 2), never to an arbitrary raw key. A defined spell that the class does not cast does not itself require a bind:



```lua
BindSpellToUnits(_spell.mindblast, _unitids.target)
```



Choose the unit group according to the spell's purpose:



- `_unitids.target` — the current target.
- `_unitids.standard_hostile` — hostile units, iterated for effects like damage-over-time spells.
- `_unitids.player` — the player.
- `_unitids.standard_friendly` — friendly units.



If the action is a macro rather than a spell, use `BindMacroToUnits()` where appropriate. Binding happens once, typically in the module's `SetBinds` function, not inside the per-frame logic loop. When you add a new cast, update the spell definition (where applicable) and its binding together in the same change, not as separate follow-ups. Also verify its boolean permission gate and target delegates.



One-time bindings deserve special care for professions: a spell learned *after* `SetBinds()` cannot be used by the rotation if the only bind was skipped because a cached `delphi.profession` flag was nil at initialization. The supplied Paladin replacement binds Find Minerals, Find Herbs, and Sense Undead once, then checks spell knowledge at cast time.



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



Keep class-specific helpers in the class file unless they're genuinely shared by multiple classes. If a helper cannot read a WoWF API safely, make the failure behavior explicit rather than treating an unknown result as permission to cast.



### 3.4 Cast Sequence Logic (`CoreLogic`)



All per-frame casting decisions for a class live in its core logic function:



```lua
function _priest.CoreLogic()
    ...
end
```



Use the appropriate class name for other classes, e.g. `_paladin.CoreLogic()`.



**Opening pattern:** The original README described a convention of starting the main chain with `if 1==0 then` (always false), so real conditions follow as `elseif` branches. Preserve this where the actual class file uses it: it keeps a priority chain scannable and makes inserting, disabling, or comparing branches easier. Do **not** infer that every nested decision inside every class has to be flattened. Anything written between `if 1==0 then` and the first real `elseif` is not a live cast branch.



**Shared exceptions**, checked before ordinary class branches, begin with the relevant Delphi safety checks:



```lua
elseif RedLight() then
    _global.Off()
```



The former example in this spot used `hermes.unit.player.channelling`; that is a retail-project symbol and has been removed from a Delphi code sample. A channeling stop belongs here **only if** the Delphi class actually supports and requires it. Other class-wide exceptions that may belong ahead of the main sequence include pet-target recovery, mount/movement handling, and any other safety behavior that must override its ordinary rotation. Verify each against Delphi before adding it.



**Per-spec branches:** A spec-oriented class may use one `elseif` per specialization against its actual Delphi spec field, separated by banners for readability:



```lua
elseif discipline_spec == delphi.spec then ...
elseif holy_spec == delphi.spec then ...
elseif shadow_spec == delphi.spec then ...
end
```



This is a spec-branch example, **not** a description of the current Paladin Role/Healing implementation. Paladin currently branches on PvE/PvP context, `GodlyIsDD()`/`GodlyIsAOE()`, Healing, and Role. Preserve the actual class's branch structure instead of forcing its logic to match another class's layout.



**Inside a spec branch**, the original README proposed nesting these decisions in this order when the class has them:



1. PvE vs PvP (`pvp_off` / `pvp_on`).
2. Single-target vs AoE (`GodlyIsDD()` / `GodlyIsAOE()`).
3. Healing vs DPS (`heal_on` / `dps_on`).
4. Healer style, if healing (`regular_healer` / `attack_healer`).



Keep this as a guide for a class with those controls, **not** an assertion that Paladin currently implements all of them or that every class uses the same toggle names. In the supplied Paladin replacement, a Healing On branch tries healing first and then falls through to its selected Role if no heal is issued. A Role Off + Healing On combination is intended to support healing-only; Mode Off is the master stop.



Set a readable prefix at the top of a branch where the class uses diagnostic prefixes (e.g. `spam_string = "shadow_"`) and build it incrementally for useful diagnostic printing. Try higher-priority casts before lower-priority ones within a branch. Do not introduce noisy per-tick prints merely to follow the example.



**Innermost cast chain** may follow the same `if 1==0 then` pattern:



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



`CastSpellUnits` args: spell, target unit or unit group, a boolean gate (cooldown/state), a table of delegates that must all pass, and an optional **single function** for rank selection. `SpellUnit_CastLoops.lua` determines the exact calling convention; never substitute a table for the rank function.

`MovementStatus()` returns `moving, moving_for, stationary, stationary_for, speed`. It is driven by `PLAYER_STARTED_MOVING` / `PLAYER_STOPPED_MOVING` events so its moving/stationary flags remain usable in combat when `GetUnitSpeed("player")` may be secret. On `PLAYER_ENTERING_WORLD`, Delphi seeds the state from `GetUnitSpeed` only when the value is readable; until either a readable seed or a movement event exists, both flags are false and stationary-only recommendations should fail closed. The fifth return is the normalized speed from the readable seed and becomes nil after a start-moving event (events provide status, not speed).



Any branch not yet meaningfully handled should still be visibly marked so the tree stays complete and traceable. The original diagnostic-stub example was:



```lua
else
    spam_string = spam_string .. "wtf?"
    print(spam_string)
end
```



Keep that stub **only where the actual class uses this diagnostic convention**. In a class that uses `_global.Off()` for no valid cast, preserve that safe fallthrough instead. In either case, label a placeholder as a placeholder. Keep debug output intentional; avoid leaving noisy prints active unless they're meant for production diagnostics.



### 3.5 Empty-Class or Placeholder Sequence



When a class has no implemented rotation yet, keep the full structure and include one harmless example cast when it is useful to make the binding and sequence conventions visible for the next contributor (human or AI) to extend. A placeholder file should still have:



- A spell definition, e.g. `_spell.mindblast = "Mind Blast"`.
- A matching binding, e.g. `BindSpellToUnits(_spell.mindblast, _unitids.target)`.
- A `CoreLogic()` function beginning with `if 1==0 then` when that is the class convention.
- A specialization or other class-specific branch containing the example cast.
- The normal global export at the end of the file (Section 3.6).



Replace the example with the real priority sequence when implementing the class for real, don't leave the placeholder cast in alongside genuine logic. A scaffold cast should not be described as a complete working rotation.



### 3.6 Closing the Module



Every class module ends by exporting its spell table into the shared namespace:



```lua
-- pack it up and store it in global space
_paladin.spell = _spell
delphi.class.Paladin = _paladin
```



The names must match the class and namespace actually used elsewhere in that file. Verify against the file's own class and spec references rather than assuming; don't copy this block into a new file without adjusting `_paladin`/`Paladin` to the correct class.



### 3.7 Mode, Context, Healing and Role



The most recently supplied `Core_Output_ToggleUI.lua` mini bar has this order: **handle, Mode, Context, Healing, Role, Aura, Blessing, Seal, Debuff Seal**. Its shared picker uses icon buttons. Preserve the user's changed Context icons: PvE `136235` (`temp`), PvP `132486` (`inv_bannerpvp_02`). Mode uses DD `589068`, AoE `236303`, and the existing disabled/red-X icon for Off. The fact that an icon updates does **not** prove `CoreLogic()` reached a cast.



| Picker | Stored value | Purpose |
|---|---|---|
| Mode | `delphi.runtime.profile`: `"dd"`, `"aoe"`, `"off"` | Select DD or AoE; Off is the master stop |
| Context | `delphi.override.context`: `"pve"`, `"pvp"` | Select PvE or PvP class branch |
| Healing | `delphi.override.healing`: true or false | Try healing first when enabled; independent of Role |
| Role | `delphi.override.role`: `"main_tank"`, `"off_tank"`, `"dps"`, `"off"` | Non-healing job; Off Tank is PvE-only |
| Aura/Blessing | `0`, `false`, spell name or `"__FB__"` | Auto, Disabled, manual, or inherit from ForeverBlessings |
| Seal/Debuff Seal | `0`, `false` or spell name | Auto, Disabled, or manual choice |



Selecting a DD/AoE mode in the **picker** does not itself change Role or Healing. In the supplied replacement `Core_Output_UI.lua`, NUMPAD7 intentionally selects **DD and DPS**, NUMPAD8 selects **AoE and DPS**, and NUMPAD9 selects **Mode Off**. The NUMPAD7/8 shortcuts therefore override a tank or Off role; all three preserve the current Healing value. If you change that behavior, update both the UI tooltip and the tests. Off Tank is not selectable in the PvP Role picker.



The earlier Paladin file still tested `"dps_dd"` and `"dps_aoe"`; the new picker and shortcuts set Role to `"dps"`. This mismatch produced a real in-game diagnostic of `mode dd role dps heal false off false` with no DPS actions. The subsequently supplied `Class_Paladin.lua` replacement changes its default Role, `RoleOverrides()` and all four DPS branch predicates to `"dps"`. **Do not install only the UI/keybind changes and assume DPS will work with an older Paladin file.**



Mode Off is the master stop. Role Off and Healing Off together also mean there is no class job. DD/AoE + Role Off + Healing On is intended to permit healing-only; DD/AoE + tank or DPS + Healing Off is intended to run that Role. Healing On gets a first attempt where a healing branch is implemented, but it does not erase Role. The attached Paladin implementation currently has a PvE/DD `Flash of Light` healing attempt; its other context/mode healing branches are placeholders, so do not describe them as completed heal rotations.



For a quick control-state check that does not depend on the displayed icons:



```lua
/run print("mode",delphi.runtime.profile,"role",delphi.override.role,"heal",tostring(delphi.override.healing),"off",tostring(GodlyIsOff()))
```



The result reports selected state, not the result of cooldown, resource, target or delegate checks. Inspect the class branch and actual output if a spell still does not fire.



### 3.8 Profession and minimap tracking



`Global_Abilities_Racials.lua` detects learned racial and profession abilities. The supplied detection candidates include Find Minerals (spell ID `2580`) and Find Herbs (spell ID `2383`); the Paladin spell table also names Sense Undead. Detection runs when the file loads and the supplied `Core_Events.lua` reruns it on `PLAYER_ENTERING_WORLD`. A profession learned later may not be reflected in the cached `delphi.profession` table until detection runs again.



This happened during testing: the player knew Mining and Herbalism, but `delphi.profession.findminerals` was `"Find Minerals"` while `delphi.profession.findherbs` was `nil`. A manual `DetectRacialAndProfessionAbilities()` rerun populated Find Herbs; at that point `C_SpellBook.IsSpellKnown(2383)` and `C_SpellBook.IsSpellInSpellBook(2383)` both returned true. A nil cached flag was a timing problem in that test, **not** proof the spell was unknown. Do not claim that `SPELLS_CHANGED` or `SKILL_LINES_CHANGED` handlers were added unless the installed `Core_Events.lua` actually contains them.



The supplied Paladin replacement uses a **single preferred default** when no relevant tracking is selected: **Find Minerals first, then Find Herbs, then Sense Undead**, checking whether each spell is known. It does not try the next preference simply because a known higher-priority spell is on cooldown. The three tracking spell names are bound once so a spell learned after initialization is not missing its binding. The actual tracking attempt remains out of combat and behind the existing Paladin stop conditions.



To preserve a manual choice, it checks the active state of only the named `C_Minimap.GetTrackingInfo(i)` entries for `"Find Minerals"`, `"Find Herbs"` and `"Sense Undead"`. The user observed the following *with Find Herbs selected*:



```text
1 Sense Undead false
2 Find Herbs true
3 Find Minerals false
```



A previous check for **any** active tracking entry returned a false positive on WoWF even without the desired tracking selection; a player `HELPFUL` aura scan failed to protect manually selected Herbs. The named-entry test addresses both observed problems. If tracking status cannot be read, the replacement skips automatic tracking instead of risking an overwrite. The full replacement still needs in-game regression testing with each manually selected tracking type and with none selected.



Do not add a blanket `and not delphi.profession.findherbs` prohibition to the Find Minerals branch. It would prevent the requested Minerals-first default when both professions are learned; it also cannot protect Herbs while its cached flag is nil. Use the selected minimap tracking state, not merely the set of known professions, to decide whether to leave a manual choice alone.



### 3.9 Aura, blessing, seal and debuff-seal overrides



The Paladin override pattern uses `0`/nil for Auto, `false` for Disabled, a spell name for Manual, and `"__FB__"` for ForeverBlessings inheritance where supported. `ResolveOverride()` falls back to the role's automatic choice if the optional ForeverBlessings assignment cannot be read. Aura and Blessing offer the inherit choice in the UI; Seal and Debuff Seal do not. Keep the UI's choice values in sync with the Paladin resolver.



The selected Role supplies the automatic aura, ordinary Seal, blessing, and Judgement Seal defaults even when Healing is On; Role Off with Healing On uses the healer-oriented defaults. Auto Seal pairs are: PvE main tank Fury/Crusader, PvP main tank Justice/Crusader, PvE off tank Righteousness/Crusader, DPS Command/Crusader, and Role Off Wisdom/Wisdom (ordinary Seal/Judgement Seal). The ordinary Seal and Judgement Seal are resolved independently.

Delphi prebuilds role-rotation macros for each available pair, named `DelphiPaladin<Role>_Judgement<Choice>_Seal<Choice>`, and the rotation recommends the macro matching the resolved pair. For example, the DPS macro for Judgement of Wisdom with Seal of Command is `DelphiPaladinDPSSequence_JudgementWisdom_SealCommand`. The three attack roles × six Judgement-Seal states (five choices plus Disabled) × eight ordinary-Seal states (seven choices plus Disabled) use 144 allocator keys. Healing retains one separate heal-only macro and one allocator key; it does not consume Seal-pair variants.

The Judgement Seal is applied before Judgement to produce that Judgement effect; when a different ordinary Seal is enabled, the macro then applies it for the remaining rotation. A matching ordinary Seal is not recast because Judgement does not consume the active Seal. If the Judgement Seal is Disabled, the macro skips the Judgement setup and applies only the ordinary Seal. If the ordinary Seal is Disabled, the Judgement Seal remains active after the opening Judgement. DPS and off-tank macros omit subsequent Judgement casts when there is no different ordinary Seal to use. Both Disabled means neither Seal nor Judgement is cast by the macro. Healing remains the existing Flash of Light-only macro while Healing On takes priority; the selected Seal pair is used again when the role rotation resumes.

Aura, Blessing, Seal, and Judgement selections made from the flyout are saved directly to the `DelphiDB` SavedVariables table and restored next session, including Auto and Disabled selections. Saved overrides are reapplied on Delphi's `ADDON_LOADED` event, after WoW has loaded its SavedVariables, and synchronized on `PLAYER_LOGOUT` (including `/reload`). Context, Healing, and Attack Role are not part of this saved override set.



## 4. Error Handling & Taint Safety



WoWF's secure execution environment can produce "secret values" (protected/tainted data) when reading combat state during restricted moments. Wrap potentially unsafe reads, such as spell cooldowns, cast info, and charge counts, in `pcall` where needed, and check for secret values **before comparing, doing arithmetic, or branching on them**. Do not assume a raw API call always returns a plain usable value. `pcall` catches an error; it does not make a secret return value safe to inspect.



A prior Paladin helper crashed at an explicit `UnitPower("player", 0) < cost` comparison in combat (`attempt to compare a secret number value`). The replacement calls `C_Spell.IsSpellUsable(spell)` behind `pcall` and fails closed if the call errors or its results are secret. That avoids the specific mana-comparison crash. It has **not** been established that `C_Spell.IsSpellUsable()` returns accessible results in every WoWF combat state; lack of output after a fix requires testing the actual gate rather than assuming it passed.



Do not "fix" a secret-value crash by forcing a cast or treating an unreadable number as zero. Record the exact WoWF state and API return behavior, then use only a documented, verified alternative.



## 5. Verification Discipline



This project targets WoW Forever specifically, a Classic+ ruleset that diverges from both retail and vanilla Classic in ways that aren't always obvious:



- Do not assume retail keybind defaults, retail API behavior, or retail creature-type/race interactions carry over. The original README recorded `UnitCreatureType("player")` returning `"Humanoid"` for an Undead-race character on WoWF, which could break naive Exorcism/Turn Undead checks. Re-verify on the current client before treating that observation as universal.
- WoWF uses namespaced modern APIs in several tested places, but that does not establish that *all* retail/Midnight APIs have identical WoWF behavior. The original project reported `GetNumTrackingTypes()`/`GetTrackingInfo()` bare globals as nil; the player has now tested `C_Minimap.GetNumTrackingTypes()`/`C_Minimap.GetTrackingInfo(i)` for named tracking entries. The old `SpellUnit_AnyTrackingActive()` reference applied to the older Paladin version; the supplied replacement uses a named-entry helper instead. Add defensive checks around newly used APIs and verify their returns in this client.
- Do not assume a Hermes/Pixel (retail) convention applies to Delphi/Pythia (WoWF) just because the two projects look structurally similar. Verify against Delphi's own source first.
- When documenting or claiming a piece of WoWF behavior, prefer verifying it live in-game over assuming parity with retail or Classic. If a claim can't be verified, say so explicitly rather than asserting it as fact.
- Only reference API functions that are officially documented for the current WoWF client version. Don't invent or guess at function names.
- Distinguish the installed addon, an attached or pasted local file, a generated replacement, and GitHub's current branch. An edit to one is not automatically present in another.



## 6. Commit Conventions



Keep commits single-purpose where practical, a keybind logic fix and a blacklist table expansion are separate concerns even if done in the same sitting, and should generally be separate commits so the history stays easy to audit and, if needed, individually revert.



A downloadable file generated in chat is **not** a GitHub commit. Before committing a cross-file change, make sure the UI, keybindings, class dispatch, and README describe the same installed behavior. Obtain confirmation before writing to GitHub; do not claim a repository change was made when only a replacement file was supplied.



## 7. AI Editing Guidance



When modifying a class file, don't infer that a spell is available merely because it appears in a comment, search both the `_spell` definitions and the binding section before relying on it. When adding a new cast, update both locations in the same change. Check learned-spell status where a talent, racial, or profession ability may not be available.



Don't invent or import framework conventions from a single example, from another AI's prior attempt, or from a related-but-distinct project (see Section "Related projects" above). For anything not explicitly documented here, inspect Delphi's actual class and utility code first, and prefer the pattern already established there over a plausible-sounding alternative.



When adding a new specialization or context branch, preserve the existing branch order and `elseif` style. Keep real emergency and channeling exceptions ahead of the main sequence **when the target class actually has them**. Prefer small, explicit conditions over opaque abstractions so the rotation stays auditable by both players and automated code-review tools.



When updating comments, remove a demonstrably stale comment as part of the same code change. Examples from this work: a player-aura check must not still be described as protecting manual tracking after it is removed; a Role value of `"dps"` must not still be documented as `"dps_dd"` or `"dps_aoe"`; and placeholder AoE/PvP healing must not be described as working.



## Implementation Checklist



Before committing a class rotation, verify:



- [ ] Every referenced spell has an exact `_spell.<key> = "In-Game Spell Name"` definition, or its direct detected/string name is documented and checked.
- [ ] Every castable spell has a matching `BindSpellToUnits()` or `BindSpellToUnit()` call.
- [ ] Every macro has a suitable existing binding/button, using `BindMacroToUnits()` when that is the relevant helper.
- [ ] The target unit group is appropriate for each action.
- [ ] Aura/buff checks follow Delphi's supporting code; `delphi.track_aura` exists but new entries require an actual consumer.
- [ ] Optional helper functions are defined before use and return the expected type.
- [ ] The class's spec, context, Mode, Healing, and Role branches that are claimed to work are actually implemented in `CoreLogic()`.
- [ ] Class-wide exceptions occur before the ordinary main sequence.
- [ ] The main sequence preserves the target class's `if 1==0 then`/`elseif` pattern where it is used, including inner `CastSpellUnits` chains.
- [ ] Each cast has suitable alive, range, harmful/helpful, aura, movement, resource, or cooldown checks where appropriate.
- [ ] `_global.Off()` is used when no action should be issued.
- [ ] Unhandled branches are visibly labelled placeholders or use the target class's intentional diagnostic stub; they are not silently advertised as functional.
- [ ] The module is exported with the correct project namespace and class name (`delphi.class.<Name>`), verified against that file's actual references, not copied blind.
- [ ] UI picker values and icons, NUMPAD bindings, `GodlyIsOff()`, and Paladin Role predicates agree; the older `dps_dd`/`dps_aoe` versus `dps` mismatch is gone.
- [ ] Healing-only, Role-only, Role Off plus Healing Off, DD/AoE/Off, PvE/PvP and every Role have been tested independently; UI state is not mistaken for a successful cast.
- [ ] Automatic tracking does not overwrite a manually selected Herbs, Minerals, or Sense Undead entry; test with no tracking selected and with professions learned after loading.
- [ ] Secret or unknown values cannot reach an unsafe comparison and are not treated as permission to cast.
- [ ] Debug prints are intentional and don't create excessive chat output.
- [ ] The README and comments match the source actually being shipped; generated-but-untested or uncommitted changes are labelled as such.
