namespace OpenplanetStore {
  class ViewPlugins : View {
    uint ITEMS_PER_PAGE = 8;
    uint STORE_CURR_PAGE = 1;

    View@ PluginDetails;

    bool availableOpen;
    bool installedOpen;
    ViewPlugins() {
      super(ViewID::PluginList, "Plugins");
      @this.PluginDetails = ViewPluginDetails();
    }

    void RenderInterface(Manager@ manager) {
      // Plugin list page
      vec2 titlesize = manager.Assets.GetTexture("title-plugins").GetSize();
      float titlescale = UI::GetWindowSize().x / titlesize.x;
      titlesize.x = UI::GetWindowSize().x;
      titlesize.y = titlesize.y * titlescale;
      UI::Image(manager.Assets.GetTexture("title-plugins"), titlesize);

      UI::BeginTabBar("Plugins View", UI::TabBarFlags::FittingPolicyResizeDown);
      if (UI::BeginTabItem("Available (" + manager.Plugins.Length + ")", availableOpen, UI::TabItemFlags::NoCloseWithMiddleMouseButton | UI::TabItemFlags::NoReorder | UI::TabItemFlags::NoTooltip)) {
        @manager.SelectedPlugin = null;
        this.renderAvailable(manager);
        UI::EndTabItem();
      }

      if (UI::BeginTabItem("Installed (" + manager.InstalledPluginsCount + ")", installedOpen, UI::TabItemFlags::NoCloseWithMiddleMouseButton | UI::TabItemFlags::NoReorder | UI::TabItemFlags::NoTooltip)) {
        @manager.SelectedPlugin = null;
        this.renderInstalled(manager);
        UI::EndTabItem();
      }

      // Details view
      if (manager.SelectedPlugin !is null) {
        if (this.PluginDetails.Open) {
          if (UI::BeginTabItem(manager.SelectedPlugin.Name, this.PluginDetails.Open, UI::TabItemFlags::SetSelected | UI::TabItemFlags::NoCloseWithMiddleMouseButton | UI::TabItemFlags::NoReorder | UI::TabItemFlags::NoTooltip)) {
            this.PluginDetails.RenderInterface(manager);
            UI::EndTabItem();
          }
        } else {
          @manager.SelectedPlugin = null;
        }

      }
      UI::EndTabBar();
    }

    void renderInstalled(Manager@ manager) {
      if (UI::BeginTable("Installed Plugins", 4, UI::TableColumnFlags::WidthStretch)) {
        UI::TableNextRow();
        for (uint i = 0; i < manager.Plugins.Length; i++) {
          if (!manager.Plugins[i].Installed) continue;
          UI::TableNextColumn();
          this.renderPluginCard(manager, manager.Plugins[i], i);
        }
        UI::EndTable();
      }
    }

    void renderAvailable(Manager@ manager) {
      UI::BeginChild("AllPlugins");
      float pages = Math::Ceil((manager.Plugins.Length * 3.6f) / (ITEMS_PER_PAGE  * 3.6f));
      if (UI::BeginTable("Plugins", 4, UI::TableColumnFlags::WidthStretch | UI::TableColumnFlags::NoResize)) {
        UI::TableNextRow();
        uint enditem = (STORE_CURR_PAGE * ITEMS_PER_PAGE) - 1;
        uint startitem = (enditem + 1) - ITEMS_PER_PAGE;

        for (uint i = startitem; i <= enditem; i++) {
          if (manager.Plugins.Length > i) {
            UI::TableNextColumn();
            this.renderPluginCard(manager, manager.Plugins[i], i);
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
    void renderPluginCard(Manager@ manager, Plugin@ plugin, int idx) {
      // dont display core plugins
      /* if (plugin.Source == Meta::PluginSource::ApplicationFolder) return; */

      if (plugin.Img !is null) {
        vec2 thumbsize = plugin.Img.GetSize();
        thumbsize /= thumbsize.x / 256;
        UI::Image(plugin.Img, thumbsize);
      } else {
        vec2 thumbsize = manager.Assets.GetTexture("no-thumb").GetSize();
        thumbsize /= thumbsize.x / 256;
        UI::Image(manager.Assets.GetTexture("no-thumb"), thumbsize);
      }

      string titleColor = "#" + idx + " ";
      UI::Text(titleColor + plugin.Name + "\\$777 - v" + plugin.Version);
      UI::Text("by " + ColoredString(plugin.Author));
      UI::BeginGroup();
      UI::PushID("details-btn" + plugin.SiteID + plugin.Name);
      if (UI::Button(Icons::Eye + " Details")) {
        @manager.SelectedPlugin = plugin;
        this.PluginDetails.Open = true;
      }
      if (plugin.Installed) {
        UI::SameLine();
        if (plugin.UpdateAvailable) {
          UI::Text("\\$db7 " + Icons::InfoCircle + " update available");
        } else {
          UI::Text("\\$486 " + Icons::CheckCircle + " installed");
        }
      }
      UI::PopID();
      UI::EndGroup();
    }
  }
}
