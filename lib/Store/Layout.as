namespace Store {
  class Layout {
    Layout() {

    }
    void InstalledPlugins(Manager@ manager) {
      UI::BeginChild("Installed");
      // Store banner
      vec2 bannersize = manager.Assets.GetTexture("store-banner").GetSize();
      float bannerscale = UI::GetWindowSize().x / bannersize.x;
      bannersize.x = UI::GetWindowSize().x;
      bannersize.y = bannersize.y * bannerscale;
      UI::Image(manager.Assets.GetTexture("store-banner"), bannersize);

      // Store banner
      vec2 ibannersize = manager.Assets.GetTexture("installed-banner").GetSize();
      float ibannerscale = UI::GetWindowSize().x / ibannersize.x;
      ibannersize.x = UI::GetWindowSize().x;
      ibannersize.y = ibannersize.y * ibannerscale;
      UI::Image(manager.Assets.GetTexture("installed-banner"), ibannersize);

      if (UI::BeginTable("Installed Plugins", 4, UI::TableColumnFlags::WidthStretch)) {
        UI::TableNextRow();
        for (uint i = 0; i < manager.Plugins.Length; i++) {
          if (!manager.Plugins[i].Installed) continue;
          UI::TableNextColumn();
          this.PluginCard(manager, manager.Plugins[i]);
        }
        UI::EndTable();
      }

      UI::EndChild();
    }

    void UnstablePlugins(Manager@ manager) {
      UI::BeginChild("Unstable");
      if (UI::BeginTable("Unstable Plugins", 4, UI::TableColumnFlags::WidthStretch)) {
        UI::TableNextRow();
        for (uint i = 0; i < manager.Plugins.Length; i++) {
          if (!manager.Plugins[i].Unstable) continue;
          UI::TableNextColumn();
          this.PluginCard(manager, manager.Plugins[i]);
        }
        UI::EndTable();
      }
      UI::EndChild();
    }

    // Render store main view
    void Home(Manager@ manager) {
      UI::BeginChild("Store");
      if (LOADING) {
        UI::Text("loading available plugins...");
        UI::EndChild();
        return;
      }

      // Featured plugins
      vec2 fbannersize = manager.Assets.GetTexture("featured-banner").GetSize();
      float fbannerscale = UI::GetWindowSize().x / fbannersize.x;
      fbannersize.x = UI::GetWindowSize().x;
      fbannersize.y = fbannersize.y * fbannerscale;
      UI::Image(manager.Assets.GetTexture("featured-banner"), fbannersize);

      if (UI::BeginTable("FeaturedPlugins", 4, UI::TableColumnFlags::WidthStretch)) {
        UI::TableNextRow();
        for (uint i = 0; i < manager.Plugins.Length; i++) {
          if (manager.Plugins[i].Featured) {
            UI::TableNextColumn();
            this.PluginCard(manager, manager.Plugins[i]);
          }
        }
        UI::EndTable();
      }

      // Plugin list page
      vec2 abannersize = manager.Assets.GetTexture("all-banner").GetSize();
      float abannerscale = UI::GetWindowSize().x / abannersize.x;
      abannersize.x = UI::GetWindowSize().x;
      abannersize.y = abannersize.y * abannerscale;
      UI::Image(manager.Assets.GetTexture("all-banner"), abannersize);

      float pages = Math::Ceil((manager.Plugins.Length * 3.6f) / (ITEMS_PER_PAGE  * 3.6f));
      if (UI::BeginTable("Plugins", 4, UI::TableColumnFlags::WidthStretch | UI::TableColumnFlags::NoResize)) {
        UI::TableNextRow();
        uint enditem = (STORE_CURR_PAGE * ITEMS_PER_PAGE) - 1;
        uint startitem = (enditem + 1) - ITEMS_PER_PAGE;
        for (uint i = startitem; i <= enditem; i++) {
          if (manager.Plugins.Length > i && !manager.Plugins[i].Unstable) {
            UI::TableNextColumn();
            this.PluginCard(manager, manager.Plugins[i]);
          }
        }
        UI::EndTable();
      }

      // Paging
      UI::Separator();
      UI::NewLine();
      for (int page = 1; page <= pages; page++) {
        UI::SameLine();
        UI::PushID(page);
        if (UI::Button(Text::Format("%d", page))) {
          STORE_CURR_PAGE = page;
        }
        UI::PopID();
      }
      UI::NewLine();
      UI::EndChild();
    }

    // Render plugin card
    void PluginCard(Manager@ manager, Store::Plugin@ plugin) {
      vec2 thumbsize = manager.Assets.GetTexture("no-thumb").GetSize();
      thumbsize /= thumbsize.x / 256;
      UI::Image(manager.Assets.GetTexture("no-thumb"), thumbsize);
      string titleColor = "";
      UI::Text(titleColor + plugin.Name + "\\$777 - v" + plugin.Version.String());
      UI::Text("by " + ColoredString(plugin.Author));
      UI::BeginGroup();
      UI::PushID("details-btn" + plugin.SiteID + plugin.Name);
      if (UI::Button(Icons::Eye + " Details")) {
        @manager.selected = plugin;
        CURRENT_VIEW = 2;
      }
      if (plugin.Installed) {
        UI::SameLine();
        if (plugin.UpdateAvailable()) {
          UI::Text("\\$db7 " + Icons::InfoCircle + " update available");
        } else {
          UI::Text("\\$486 " + Icons::CheckCircle + " installed");
        }
      }
      UI::PopID();
      UI::EndGroup();
    }

    // Plugin details view
    void Details(Manager@ manager) {
      if (manager.selected is null) {
        return;
      }
      UI::BeginChild(manager.selected.Name);
      if (UI::BeginTable("DetailsView", 2, UI::TableFlags::NoBordersInBody | UI::TableFlags::SizingStretchProp)) {
        // Left aside
        UI::TableSetupColumn("aside", UI::TableColumnFlags::WidthFixed, UI::GetWindowSize().x / 4);
        UI::TableNextRow();
        UI::TableSetColumnIndex(0);
        vec2 thumbsize = manager.Assets.GetTexture("no-thumb").GetSize();
        thumbsize /= thumbsize.x / 256;
        UI::Image(manager.Assets.GetTexture("no-thumb"), thumbsize);

        if (manager.selected.local !is null && manager.selected.local.Type == Meta::PluginType::Legacy) {
          UI::Separator();
          UI::Text("Legacy plugins are not supported!");
          UI::Separator();
        } else {
          // Show actions only if there is no pending action
          if (!manager.selected.Busy()) {
            if (manager.selected.Installed) {
              if (manager.selected.UpdateAvailable()) {
                UI::PushStyleColor(UI::Col::Button, vec4(0.867,0.733,0.467,1));
                UI::Button("Get " + manager.selected.Version.String());
                UI::PopStyleColor();
                UI::SameLine();
              }
              UI::PushStyleColor(UI::Col::Button, vec4(1,0,0,1));
              if (UI::Button("Uninstall")) {
                  manager.selected.Uninstall();
              }

              UI::PopStyleColor();
            } else {
              if (UI::Button("Install")) {
                manager.selected.Install();
              }
            }
          }
        }

        if (UI::BeginTable("DetailsView", 2, UI::TableFlags::Borders)) {
          // Version
          UI::TableNextRow();
          UI::TableNextColumn();
          UI::Text("Version:");
          UI::TableNextColumn();
          if (manager.selected.Installed) {
            UI::Text(manager.selected.local.Version);
          } else {
            UI::Text(manager.selected.Version.String());
          }
          // Author
          UI::TableNextRow();
          UI::TableNextColumn();
          UI::Text("Author:");
          UI::TableNextColumn();
          UI::Text(ColoredString(manager.selected.Author));
          // Last updated
          UI::TableNextRow();
          UI::TableNextColumn();
          UI::Text("Last updated:");
          UI::TableNextColumn();
          // DateTime(); API ??
          UI::Text(""+ manager.selected.LastUpdated);
          // Downloads
          UI::TableNextRow();
          UI::TableNextColumn();
          UI::Text("Downloads:");
          UI::TableNextColumn();
          UI::Text(""+manager.selected.Downloads);

          UI::EndTable();
        }
        // Details
        UI::TableNextColumn();
        if (manager.selected.Busy()) {
          UI::Separator();
          UI::Text(manager.selected.Status());
          UI::Separator();
        }
        UI::Text(manager.selected.Name);
        UI::Text(manager.selected.ShortDesc);

        UI::EndTable();
      }
      UI::EndChild();
    }
  }
}
