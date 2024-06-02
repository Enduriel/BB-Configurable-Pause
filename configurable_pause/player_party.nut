::mods_hookExactClass("entity/world/player_party", function (o)
{
	o.m.ConfigurablePause <- {
		PausedTile = null
	}
	local onUpdate = o.onUpdate;
	o.onUpdate = function()
	{
		if (!::World.State.ConfigurablePause_isInThread())
		{
			if (this.m.ConfigurablePause.PausedTile != null && !this.getTile().isSameTileAs(this.m.ConfigurablePause.PausedTile))
				this.m.ConfigurablePause.PausedTile = null;

			if (!::MSU.isNull(::World.State.getEscortedEntity()) && this.m.ConfigurablePause.PausedTile == null && ::World.getTime().IsDaytime && this.getTile().IsOccupied && !::World.State.isPaused())
			{
				foreach (settlement in ::World.EntityManager.getSettlements())
				{
					if (settlement.getTile().isSameTileAs(this.getTile()))
					{
						this.m.ConfigurablePause.PausedTile = this.getTile();
						::logInfo("setAutoPause");
						::World.State.setAutoPause(true);
						break;
					}
				}
			}
			::logInfo("inner onUpdate");
		}
		else
		{

			::logInfo("inner onUpdate non-threaded");
		}
		return onUpdate();
	}
});
