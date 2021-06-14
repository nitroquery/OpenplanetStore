namespace  OpenplanetStore {
  class Plugin {
    bool Enabled;
    string ID;
    int SiteID;
    string Name;
    string Author;
    string Category;
    Meta::PluginSource Source;
    string SourcePath;
    Meta::PluginType Type;
    bool Unstable;
    string Version;

    bool Installed;
    bool UpdateAvailable;
    string Desc;

    string AvailableVersion;
    string AvailableFilename;
    int AvailableFilesize;
    int Downloads;
    Json::Value Tags;
    string CreatedAt;
    string UpdatedAt;

    Resources::Texture@ Img;
    EventType EventType = EventType::Noop;

    Plugin(Meta::Plugin@ plugin) {
      this.UpdateLocal(plugin);
    }

    Plugin(Json::Value data) {
      this.UpdateRemoteInfo(data);
    }

    void UpdateLocal(Meta::Plugin@ plugin) {
      this.Enabled = plugin.Enabled;
      this.ID = plugin.ID;
      this.SiteID = plugin.SiteID;
      this.Name = plugin.Name;
      this.Author = plugin.Author;
      this.Category = plugin.Category;
      this.Source = plugin.Source;
      this.SourcePath = plugin.SourcePath;
      this.Type = plugin.Type;
      this.Unstable = plugin.Unstable;
      this.Version = plugin.Version;
      this.Installed = true;

      if (this.Installed && this.AvailableVersion.Length > 0 && Semver::Version(this.Version) < Semver::Version(this.AvailableVersion)) {
        this.UpdateAvailable = true;
      } else {
        this.UpdateAvailable = false;
      }
    }

    void UpdateRemoteInfo(Json::Value data) {
      this.SiteID = Text::ParseInt(data["id"]);
      this.Name = data["name"];
      this.Author = data["author"];
      this.Desc = data["shortdescription"];
      this.AvailableVersion = data["version"];
      this.AvailableFilename = data["filename"];
      this.AvailableFilesize = data["filesize"];
      this.Downloads = data["downloads"];
      this.Tags = data["tags"];
      this.CreatedAt = data["createdAt"];
      this.UpdatedAt = data["updatedAt"];
      if (this.Installed && Semver::Version(this.Version) < Semver::Version(this.AvailableVersion)) {
        this.UpdateAvailable = true;
      } else {
        this.UpdateAvailable = false;
      }
    }

    bool Install() {
      this.EventType = EventType::PluginInstalling;
      Import::Function@ DownloadPlugin = opstore.GetFunction("DownloadPlugin");
      if (DownloadPlugin is null) {
        Error("Openplanet Store DownloadPlugin not found!");
        return false;
      }
      if (this.SiteID == 0 || this.AvailableFilename.Length == 0) {
        Error("Invalid plugin filename or missing SiteID. Can not download!");
        return false;
      }
      string loadpath = DownloadPlugin.CallString(int(this.SiteID), this.AvailableFilename);
      if (loadpath.Length == 0) {
        Error("Failed to download plugin file!");
        return false;
      }
      Meta::Plugin@  newplugin = Meta::LoadPlugin(loadpath, Meta::PluginSource::UserFolder, Meta::PluginType::Zip);
      Print("downloaded: " + loadpath);
      if (!newplugin.Enabled) {
        newplugin.Enable();
      }
      this.UpdateLocal(newplugin);
      Print("enabled: " + this.Name);
      this.EventType = EventType::Noop;
      return true;
    }

    // Uninstall the plugin
    bool Uninstall() {
      this.EventType = EventType::PluginUninstalling;

      Meta::Plugin@ iplugin = this.GetMetaPlugin();
      if (iplugin is null) {
        Warn("did not find local installation of " + this.ID);
        this.EventType = EventType::Noop;
        return false;
      }

      if (iplugin.Source != Meta::PluginSource::UserFolder) {
        Error("you can only uninstall plugins from user UserFolder");
        return false;
      }

      // 1. Disable the plugin
      if (iplugin.Enabled) {
        iplugin.Disable();
      }

      // 2. Unload the plugin
      Meta::UnloadPlugin(iplugin);
      this.Installed = false;

      Import::Function@ DeletePlugin = opstore.GetFunction("DeletePlugin");
      if (DeletePlugin is null) {
        Error("Openplanet Store DeletePlugin not found!");
        return false;
      }
      string status = DeletePlugin.CallString(int(this.Type), this.SourcePath);
      Print("uninstall: (" + this.Name + ") " + status);
      this.EventType = EventType::Noop;
      return true;
    }

    bool Update() {
      Print("update: " + this.Name);
      this.EventType = EventType::PluginUpdating;
      sleep(100);
      if (this.Uninstall()) {
        sleep(100);
        if (this.Install()) {
          sleep(100);
          this.EventType = EventType::Noop;
          return true;
        }
      }
      this.EventType = EventType::Noop;
      return false;
    }

    Meta::Plugin@ GetMetaPlugin() {
      Meta::Plugin@[]@ installed = Meta::AllPlugins();
      Meta::Plugin@ iplugin;
      for (uint i2 = 0; i2 < installed.Length; i2++) {
        if (installed[i2].SiteID == this.SiteID && installed[i2].ID == this.ID) {
          return installed[i2];
        }
      }
      return null;
    }
  }
}
