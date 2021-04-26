namespace ItemTradeHook
{
	class ItemTrade : UserWindow
	{
		Widget@ m_wItemList;
		Widget@ m_wItemTemplate;
		
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

			auto gm = cast<Campaign>(g_gameMode);
			auto record = GetLocalPlayerRecord();

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

			int numPlayers = Lobby::GetLobbyPlayerCount();

			//m_lastNumPlayers = numPlayers;

			m_wPlayerList.ClearChildren();

			for (int i = 0; i < numPlayers; i++)
			{
				auto wPlayer = cast<ScalableSpriteButtonWidget>(m_wPlayerTemplate.Clone());
				wPlayer.SetID("player-" + i);
				wPlayer.m_func = "send-items " + i;

				wPlayer.SetText(Lobby::GetPlayerName(i));
				wPlayer.m_visible = true;

				//UpdatePlayer(wPlayer, i);

				m_wPlayerList.AddChild(wPlayer);
			}
		}

		void UpdateButton()
		{
			int numSelected = 0;
			for (uint i = 0; i < m_wItemList.m_children.length(); i++)
			{
				auto wItem = cast<CheckBoxWidget>(m_wItemList.m_children[i]);
				if (wItem !is null && wItem.IsChecked())
				{
					numSelected++;
					
				}
			}
		}

		void SendItems()
		{
			//auto item = g_items.GetItem(wItem.m_value);
			//if (item is null)
			//	return;

			//player.TakeItem(item);
			//print(item.name);
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

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "close")
				Close();
			else if(name == "send-items")
			{
				SendItems();
			}
			else if (name == "item-checked")
				UpdateButton();
		}
	}
}	