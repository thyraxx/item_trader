namespace ItemTradeHook
{
	Widget@ m_wItemList;
	Widget@ m_wItemTemplate;

	class ItemTrade : UserWindow
	{
		Widget@ m_wPlayerList;
		ScalableSpriteButtonWidget@ m_wPlayerTemplate;
		array<ActorItem> selectedItems;

		ItemTrade(GUIBuilder@ b)
		{
			super(b, "gui/itemtrade/thyraxxitemtrade.gui");

			@m_wItemList = m_widget.GetWidgetById("list-items");
			@m_wItemTemplate = m_widget.GetWidgetById("template-item");
			@m_wPlayerList = m_widget.GetWidgetById("playerlist");
			@m_wPlayerTemplate = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("player-template"));

			ReloadItemList();
			UpdateButton();
		}

		void Show() override
		{
			selectedItems.removeRange(0, selectedItems.length());
			
			UpdatePlayerList();
			ReloadItemList();

			UserWindow::Show();
		}

		void UpdatePlayerList()
		{
			if (!Lobby::IsInLobby())
				return;

			auto lpRecord = GetLocalPlayerRecord();

			m_wPlayerList.ClearChildren();

			int numPlayers = Lobby::GetLobbyPlayerCount();
			for (int i = 0; i < numPlayers; i++)
			{
				auto wPlayer = cast<ScalableSpriteButtonWidget>(m_wPlayerTemplate.Clone());
				wPlayer.SetID("player-" + i);
				wPlayer.m_func = "send-items " + i;

				wPlayer.SetText(Lobby::GetPlayerName(i));
				//wPlayer.m_enabled = (i != lpRecord.peer);
				wPlayer.m_visible = (i != lpRecord.peer);

				m_wPlayerList.AddChild(wPlayer);
			}
		}

		void UpdateButton()
		{
			selectedItems.removeRange(0, selectedItems.length());
			for (uint i = 0; i < m_wItemList.m_children.length(); i++)
			{
				auto wItem = cast<CheckBoxWidget>(m_wItemList.m_children[i]);
				auto item = g_items.GetItem(wItem.m_value);
				if (wItem !is null && wItem.IsChecked())
				{
					selectedItems.insertLast(item);
				}
			}
		}

		void SendItems(uint peer)
		{
			auto player = GetLocalPlayer();

			for(uint i = 0; i < selectedItems.length(); i++)
			{
				auto item = selectedItems[i];
				player.TakeItem(item);

				(Network::Message("GiveItemTrade") << item.id).SendToPeer(peer);
			}

			ReloadItemList();
			UpdateButton();
			player.RefreshModifiers();
		}

		void OnFunc(Widget@ sender, string name) override
		{
			string commandName = name.split(" ")[0];
			if (commandName == "close")
				Close();
			else if(commandName == "send-items")
			{
				uint peer = parseInt(name.split(" ")[1]);
				SendItems(peer);
			}
			else if (commandName == "item-checked")
				UpdateButton();
		}
	}

	void ReloadItemList(bool enabled = true)
	{
		m_wItemList.ClearChildren();

		auto record = GetLocalPlayerRecord();
		for (uint i = 0; i < record.items.length(); i++)
		{
			auto item = g_items.GetItem(record.items[i]);
			if (item is null)
			{
				PrintError("Couldn't find item at index " + i);
				continue;
			}

			auto wNewItem = cast<CheckBoxWidget>(AddActorItemToGuiList(record, m_wItemList, m_wItemTemplate, item));
			if (wNewItem !is null)
				wNewItem.m_enabled = enabled;
		}
	}
}