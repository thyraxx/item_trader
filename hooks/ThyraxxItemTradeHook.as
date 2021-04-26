namespace ItemTradeHook
{
	ItemTrade@ g_interface;

	[Hook]
	void GameModeUpdate(Campaign@ campaign, int dt, GameInput& gameInput, MenuInput& menuInput)
	{
		if (g_interface is null)
			return;

		if (Platform::GetKeyState(64).Pressed) // F7
			campaign.ToggleUserWindow(g_interface);
	}

	[Hook]
	void GameModeStart(Campaign@ campaign, SValue@ save)
	{
		campaign.m_userWindows.insertLast(@g_interface = ItemTrade(campaign.m_guiBuilder));
	}
}