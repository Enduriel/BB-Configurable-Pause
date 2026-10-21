// Escort, camp and button speeds on BB 1.5.2.2+, plus configurable_pause's escort and pause-on-sight hooks.
// Reproduces: swifter #171678200/#175411815 (Barbarian King escort breaks), #175652712 (4x buttons overlap),
// configurable_pause #171252866 (arity error on load), bug #963286 (pause on sight when off),
// and caravans breaking with both mods (#172241453).
// Mods: Modern Hooks, MSU, and any of swifter / configurable_pause (each check reports "n/a" if its mod is absent).
// Mode: campaign.
//
// Passing run with both fixed mods (PROBE lines, in order):
//   mods = swifter 1 configurable_pause 1
//   settle closing = event screen        (the scenario intro; may be absent)
//   settle quiet = true
//   paused after settle = false
//   legends = absent                     (or its version)
//   speed settings = CampMult=3 EscortMult=3.75 FastMult=2 NormalMult=1 SuperfastMult=8 VeryFastMult=4
//   escort wrapper params = 3            (this, _e, _fastEscort)
//   caravan escort call = ok
//   caravan escort min, speed = 3.75 3.75
//   fast escort call = ok
//   fast escort min, speed = 2 2
//   escort 8x speed = 8
//   escort 4x speed = 4
//   escort 1x speed = 2
//   escort end min, speed = 1 1
//   camp min, speed = 3 3
//   camp 8x speed = 8
//   camp 4x speed = 4
//   camp end speed = 1
//   normal/fast/veryfast speed = 1 2 4
//   pause on sight off -> pause requested = false
//   pause on sight on -> pause requested = true
//   errors during probe = 0
// Legends 19.4.22 (passes, 2026-10-21) differs only by its own constants: speed settings CampMult=2.5 EscortMult=4
// FastMult=2.5, so caravan escort 4 4, fast escort 2.5 2.5, escort 1x 2.5, camp 2.5 2.5, normal/fast/veryfast 1 2.5 4.
// With topbar_buttons.js (--js): five buttons, l-very-fast-time-button showing time_x4_sw.png, no l-veryfast-time-button.
//
// Run (from /home/end/dev/battle_brothers/modern_engine):
//   python3 .claude/skills/bb-game-probe/run_probe.py <this> --js <dir>/topbar_buttons.js --mode campaign --seed e2e \
//     --with-mod held:mod_msu --with-mod <swifter zip> --with-mod <configurable_pause zip> --out <scratch>/runN

::ClaudeProbe.DeferDone = true;

local function p( k, f )
{
	local v;
	try { v = f(); } catch (e) { v = "ERROR: " + e; }
	::logInfo("PROBE " + k + " = " + v);
}

local hasSwifter = "Swifter" in ::getroottable();
local hasPause = "ConfigurablePause" in ::getroottable();
local ws = ::World.State;
local state = { Errors = 0, Caravan = null, Enemy = null };

local function speed()
{
	return ::World.getSpeedMult();
}
local function minSpeed()
{
	return ws.getMinWorldSpeedMult();
}
local function call( _k, _f )
{
	try { _f(); ::logInfo("PROBE " + _k + " = ok"); }
	catch (e) { state.Errors++; ::logInfo("PROBE " + _k + " = ERROR: " + e); }
}

p("mods", @() "swifter " + (hasSwifter ? 1 : 0) + " configurable_pause " + (hasPause ? 1 : 0));
p("legends", @() ::Hooks.hasMod("mod_legends") ? ::Hooks.getMod("mod_legends").getVersionString() : "absent");
p("speed settings", function() {
	local keys = [];
	foreach (k, v in ::Const.World.SpeedSettings) keys.push(k + "=" + v);
	keys.sort();
	local s = ""; foreach (k in keys) s += k + " ";
	return s;
});
p("escort wrapper params", @() ws.setEscortedEntity.getinfos().parameters.len());
p("teleport overloads", function() {
	local keys = [];
	foreach (k, v in ::TacticalNavigator) if (typeof k == "string" && k.find("teleport") != null) keys.push(k + ":" + typeof v);
	keys.sort();
	local s = ""; foreach (k in keys) s += k + " ";
	return s;
});

local playerTile = ws.getPlayer().getTile();
local function nearTile( _dx )
{
	return ::World.getTileSquare(playerTile.SquareCoords.X + _dx, playerTile.SquareCoords.Y);
}

local steps = [
	function() {
		p("paused after settle", @() ws.isPaused());
		local faction = ::World.FactionManager.getFaction(::World.EntityManager.getSettlements()[0].getFaction());
		state.Caravan = faction.spawnEntity(nearTile(1), "Probe Caravan", false, ::Const.World.Spawn.CaravanEscort, 100);
		state.Caravan.getFlags().set("IsCaravan", true);
		// a caravan escort contract calls setEscortedEntity(_caravan)
		call("caravan escort call", @() ws.setEscortedEntity(state.Caravan));
	},
	function() {
		p("paused", @() ws.isPaused());
		p("caravan escort min, speed", @() minSpeed() + " " + speed());
		// the Barbarian King and greenskin siege contracts call setEscortedEntity(_e, true)
		call("fast escort call", @() ws.setEscortedEntity(state.Caravan, true));
	},
	function() {
		p("fast escort min, speed", @() minSpeed() + " " + speed());
		if (hasSwifter) ws.setSuperfastTime();
	},
	function() {
		p("escort 8x speed", @() hasSwifter ? speed() : "n/a");
		ws.setVeryFastTime();
	},
	function() {
		p("escort 4x speed", @() speed());
		ws.setNormalTime();
	},
	function() {
		p("escort 1x speed", @() speed());
		call("escort end call", function() { ws.setEscortedEntity(null); ws.resetSpeedToNormal(); });
	},
	function() {
		p("escort end min, speed", @() minSpeed() + " " + speed());
		state.Caravan.die();
		ws.onCamp();
	},
	function() {
		p("camp min, speed", @() minSpeed() + " " + speed());
		if (hasSwifter) ws.setSuperfastTime();
	},
	function() {
		p("camp 8x speed", @() hasSwifter ? speed() : "n/a");
		ws.setVeryFastTime();
	},
	function() {
		p("camp 4x speed", @() speed());
		ws.onCamp();
	},
	function() {
		p("camp end speed", @() speed());
		ws.setFastTime();
	},
	function() {
		state.Fast <- speed();
		ws.setVeryFastTime();
	},
	function() {
		state.VeryFast <- speed();
		ws.setNormalTime();
	},
	function() {
		p("normal/fast/veryfast speed", @() speed() + " " + state.Fast + " " + state.VeryFast);
		local bandits = ::World.FactionManager.getFactionOfType(::Const.FactionType.Bandits);
		state.Enemy = bandits.spawnEntity(nearTile(4), "Probe Brigands", false, ::Const.World.Spawn.BanditRaiders, 80);
		state.Enemy.getController().clearOrders();
	},
	function() {
		// the enemy has updated once while unpaused; now simulate it coming into view
		if (!hasPause)
		{
			::logInfo("PROBE pause on sight off -> pause requested = n/a");
			::logInfo("PROBE pause on sight on -> pause requested = n/a");
			return;
		}
		local setting = ::ConfigurablePause.Mod.ModSettings.getSetting("PauseOnSight");
		local old = setting.getValue();
		foreach (value in [false, true])
		{
			setting.set(value);
			ws.m.ConfigurablePause_Pause = false;
			state.Enemy.getFlags().set(::ConfigurablePause.FlagID.LastSeenInPlayerVision, 0.0);
			ws.m.ConfigurablePause_LastPauseOnSeeEnemy = 0.0;
			p("pause on sight " + (value ? "on" : "off") + " -> pause requested", function() {
				state.Enemy.onDiscovered();
				return ws.m.ConfigurablePause_Pause;
			});
		}
		ws.m.ConfigurablePause_Pause = false;
		setting.set(old);
	},
	function() {
		state.Enemy.die();
		ws.setPause(true);
		p("errors during probe", @() state.Errors);
	}
];

local runStep;
runStep = function( _i )
{
	if (_i >= steps.len())
	{
		::ClaudeProbe.done();
		return;
	}
	try { steps[_i](); } catch (e) { state.Errors++; ::logInfo("PROBE step " + _i + " = ERROR: " + e); }
	::Time.scheduleEvent(::TimeUnit.Real, 500, function( _d ) { runStep(_i + 1); }, null);
};
// The probe starts right after world_state.init(), while the new campaign is still auto-paused behind the loading
// screen, and the scenario intro event pauses it again later. Wait until that's over, close any event screen,
// then unpause.
local settle;
settle = function( _tries, _quiet )
{
	local busy = ::LoadingScreen.isVisible() || ::LoadingScreen.isAnimating() || ws.m.MenuStack.hasBacksteps();
	if (ws.m.MenuStack.hasBacksteps() && !ws.m.EventScreen.isAnimating() && !::LoadingScreen.isVisible())
	{
		// the event screen's backstep validator always refuses, so skip it like closing the intro would
		::logInfo("PROBE settle closing = " + (ws.m.EventScreen.isVisible() ? "event screen" : "other menu"));
		ws.m.MenuStack.pop(true);
	}
	_quiet = busy ? 0 : _quiet + 1;
	if (_quiet >= 6 || _tries >= 80)
	{
		::logInfo("PROBE settle quiet = " + (_quiet >= 6));
		ws.setAutoPause(false);
		ws.setPause(false);
		ws.setNormalTime();
		::Time.scheduleEvent(::TimeUnit.Real, 500, function( _d ) { runStep(0); }, null);
		return;
	}
	::Time.scheduleEvent(::TimeUnit.Real, 500, function( _d ) { settle(_tries + 1, _quiet); }, null);
};
::Time.scheduleEvent(::TimeUnit.Real, 500, function( _d ) { settle(0, 0); }, null);
