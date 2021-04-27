namespace ItemTradeHook
{
	void GiveItemTrade(string itemID)
	{
		auto peerPlayer = GetLocalPlayer();
		auto item = g_items.GetItem(itemID);
		peerPlayer.AddItem(item);
		peerPlayer.RefreshModifiers();

		ReloadItemList();
	}
}