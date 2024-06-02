::mods_hookExactClass("entity/world/party", function (o)
{
	local create = o.create;
	o.create = function()
	{
		create();
		this.getFlags().add(::ConfigurablePause.FlagID.WasSeen, false)
		this.getFlags().add(::ConfigurablePause.FlagID.WasInPlayerVision, false);
	}

	local onDiscovered = ::mods_getMember(o, "onDiscovered");
	o.onDiscovered <- function()
	{
		this.getFlags().set(::ConfigurablePause.FlagID.WasSeen, true);
		if (::ConfigurablePause.Mod.ModSettings.getSetting(::ConfigurablePause.SettingID.PauseOnCampingNewDay).getValue())
			this.ConfigurablePause_onEnterVision();
		return onDiscovered();
	}

	local onUpdate = ::mods_getMember(o, "onUpdate");
	o.onUpdate <- function()
	{
		local ret = onUpdate();
		// ::MSU.Utils.Timer("PerfTestCP").unpause()
		if (!this.m.IsPlayer && ::ConfigurablePause.Mod.ModSettings.getSetting(::ConfigurablePause.SettingID.PauseOnCampingNewDay).getValue() && this.getFlags().get(::ConfigurablePause.FlagID.WasSeen)) // means that onDiscovered no longer works
		{
			// ::World.State.m.ConfigurablePause.NumChecks++;
			if (::World.State.getPlayer().isAbleToSee(this)) // player can see the entity in this update
			{
				if (!this.getFlags().get(::ConfigurablePause.FlagID.WasInPlayerVision)) // player couldn't see the entity in the last update, but can in this update
				{
					this.ConfigurablePause_onEnterVision();
				}
			}
			else if (this.getFlags().get(::ConfigurablePause.FlagID.WasInPlayerVision)) // if the player can't see the entity in this update, but could see it in the last update
				this.getFlags().set(::ConfigurablePause.FlagID.WasInPlayerVision, false);
		}
		// ::MSU.Utils.Timer("PerfTestCP").pause()
		return ret;
	}

	o.ConfigurablePause_onEnterVision <- function()
	{
		this.getFlags().set(::ConfigurablePause.FlagID.WasInPlayerVision, true);
		if (!::World.State.isPaused() && this.isAttackable() && this.getFaction() != 0 && !this.isAlliedWithPlayer() && this.getTile().getDistanceTo(::World.State.getPlayer().getTile()) <= 8)
		{
			::World.State.m.ConfigurablePause.LastPauseOnSeeEnemy = ::Time.getExactTime();
			::World.State.setPause(true);
		}
	}
});
