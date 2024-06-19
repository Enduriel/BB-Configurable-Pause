::ConfigurablePause.MH.hook("scripts/entity/world/player_party", function(q) {
	q.m.ConfigurablePause_PausedTile <- null;

	q.onUpdate = @(__original) function() {
		this.ConfigurablePause_updatePausedTileNull();
		return __original();
	}

	q.ConfigurablePause_updatePausedTileNull <- function () {
		local settingValue = ::ConfigurablePause.Mod.ModSettings.getSetting("PauseOnEscortOverCity").getValue();

		if (settingValue == "Never" || (settingValue == "Day Only" && !::World.getTime().IsDaytime)) {
			return;
		}
		if (this.m.ConfigurablePause_PausedTile != null) {
			if (this.getTile().isSameTileAs(this.m.ConfigurablePause_PausedTile)) {
				return;
			}
			this.m.ConfigurablePause_PausedTile = null;
		}
		if (::MSU.isNull(::World.State.getEscortedEntity()) || !this.getTile().IsOccupied) {
			return;
		}
		foreach (settlement in ::World.EntityManager.getSettlements()) {
			if (settlement.getTile().isSameTileAs(this.getTile())) {
				this.m.ConfigurablePause_PausedTile = this.getTile();
				::World.State.ConfigurablePause_setPause(true);
				break;
			}
		}
	}
});
