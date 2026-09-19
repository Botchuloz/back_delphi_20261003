delphi = {}

_now  = 0
_null = ""
_dd   = "dd"
_aoe  = "aoe"
_off  = "off"

delphi.event  = {} -- events to register
delphi.track_aura =  {} -- unique buff/debuffs to track where src == player/pet. form is delphi.track_aura.<spell>.<dest_guid>.<event_name> = event_time, where dest_guid is nil'd when unit dies or buff/debuff is removed
delphi.class  = {} -- where all logic / strings etc get stored per class
delphi.unitids= {} -- ipairs of unitids - eg, delphi.unitids.party  = {"party1","party2","party3","party4"}
delphi.unit   = {} -- meta table that determines information about a unit (by unitid) - eg, delphi.unit["player"].health.percent
delphi.spell  = {}
delphi.player = {}
delphi.ui     = {}
delphi.error  = {}
--delphi.buttons= {}

delphi.runtime  = {} -- godlies current statuses (eg, profile == aoe, cleave == off)
delphi.pythia   = {} -- the pixels we use (currently just "instant" and "global")

delphi.keyboard = {}
delphi.keyboard.key_ascii = {} -- ascii value for that key
delphi.keyboard.mod_ascii = {} -- ascii value for than modifier

delphi.keycombo = {}
delphi.keycombo.status        = {} -- true if the keycombo has been used
delphi.keycombo.key_ascii     = {} -- ascii value for the key-component of that keycombo (eg, value for "A" in a "CTRL-A" keycombo)
delphi.keycombo.mod_ascii     = {} -- ascii value for the modifier-component of that keycombo (eg, combined value for "CTRL-SHIFT-" in a "CTRL-SHIFT-A" combo)

delphi.bind = {}
delphi.bind.spellunit_to_keycombo = {} -- mapping of "CorruptionTarget" to "CTRL-A"
delphi.bind.button    = {}             -- the button objects that define each OverrideModifier(), in case I want to make changes to them after loading.
