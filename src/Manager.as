namespace OpenplanetStore {
  OpenplanetStore::Layout@ layout;
  class Manager {
    // Store manager version
    string Version;
    // Store State
    State state = State::Loading;
    // ID of currently active view
    ViewID CurrentViewID;
    // Asset manager
    AssetManager@ Assets;

    array<Plugin@> Plugins;

    Plugin@ SelectedPlugin;

    string StatusMsg;

    int InstalledPluginsCount;

    EventType PendingEvent;

    // Store manager constructor
    Manager() {
      @layout = Layout();
      @this.Assets = AssetManager();
      this.CurrentViewID = ViewID::Home;
      @this.SelectedPlugin = null;
    }

    void Tick() {
      if (!IsValid || this.PendingEvent == EventType::Noop) return;

      switch (this.PendingEvent) {
        case EventType::PluginUninstall:
          if (this.SelectedPlugin !is null) {
            this.SelectedPlugin.Uninstall();
            this.InstalledPluginsCount--;
          }
        break;
        case EventType::PluginInstall:
          if (this.SelectedPlugin !is null) {
            this.SelectedPlugin.Install();
            this.InstalledPluginsCount++;
          }
        break;
        case EventType::PluginUpdate:
          if (this.SelectedPlugin !is null) {
            this.SelectedPlugin.Update();
          }
        break;
      }

      this.PendingEvent = EventType::Noop;
      yield();
    }

    void RenderInterface() {
      layout.RenderInterface(this);
    }

    void RefreshPluginList() {
      if (opstore is null) {
        Error("Openplanet Store core not loaded!");
        return;
      }

      Manager@ manager = this;
      startnew(function(){
        // since game startup is slow wait 15sec before initializing the store
        sleep(100);

        // truncate old list
        if (manager.Plugins.Length > 0) {
          manager.Plugins.RemoveRange(0, manager.Plugins.Length);
        }

        // Get available plugins
        manager.StatusMsg = "fetch available plugins...";
        Import::Function@ GetAvailablePlugins = opstore.GetFunction("GetAvailablePlugins");
        if (GetAvailablePlugins is null) {
          Error("Openplanet Store GetAvailablePlugins not found!");
          return;
        }
        string jsonstr = GetAvailablePlugins.CallString();
        Json::Value remoteplugins;
        manager.StatusMsg = "parse available plugins...";
        try {
          remoteplugins = Json::Parse(jsonstr);
        } catch {
          Error("Failed parse json of GetAvailablePlugins");
          return;
        }

        Import::Function@ GetPluginImagePath = opstore.GetFunction("GetPluginImagePath");
        if (GetPluginImagePath is null) {
          Error("Openplanet Store GetPluginImagePath not found!");
          return;
        }

        manager.StatusMsg = "check local plugins...";
        // Get installed plugins
        Meta::Plugin@[]@ plugins = Meta::AllPlugins();
        manager.InstalledPluginsCount = plugins.Length;
        for (uint i = 0; i < plugins.Length; i++) {
          Plugin@ plugininfo = Plugin(plugins[i]);

          // Attach remote info if available
          for (uint j = 0; j < remoteplugins.Length; j++) {
            manager.StatusMsg = "load installed (" + plugininfo.Name + ") plugin information...";
            if (plugins[i].SiteID > 0 && remoteplugins[j].HasKey("id") && plugins[i].SiteID == Text::ParseInt(remoteplugins[j]["id"])) {
              plugininfo.UpdateRemoteInfo(remoteplugins[j]);
              string imgpath = GetPluginImagePath.CallString(plugininfo.SiteID);
              @plugininfo.Img = Resources::GetTexture(imgpath);
              if (plugininfo.Img is null) {
                Warn("failed to load image from: " + imgpath);
              }
              remoteplugins[j].Remove("id");
            }
          }
          // Add plugin to manager
          manager.Plugins.InsertLast(plugininfo);
          yield();
        }

        manager.StatusMsg = "check available plugins...";
        if (remoteplugins.Length > 0) {
          for (uint i = 0; i < remoteplugins.Length; i++) {
            if (!remoteplugins[i].HasKey("id")) continue;
            Plugin@ plugininfo = Plugin(remoteplugins[i]);
            manager.StatusMsg = "load available (" + plugininfo.Name + ") plugin information...";
            if (plugininfo.SiteID > 0) {
              string imgpath = GetPluginImagePath.CallString(plugininfo.SiteID);
              @plugininfo.Img = Resources::GetTexture(imgpath);
              if (plugininfo.Img is null) {
                Warn("failed to load image from: " + imgpath);
              }
            }
            manager.Plugins.InsertLast(plugininfo);
            yield();
          }
        }
        manager.state = State::Loaded;
      });
      manager.StatusMsg = "";
    }
  }
}
