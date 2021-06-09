namespace Store {
  // Plugin representation for Plugin Store
  class Plugin {
    int SiteID;
    string Name;
    string Author;
    Semver::Version Version;
    uint64 LastUpdated;
    string ShortDesc;
    uint Downloads;

    bool Featured;
    bool Installed;
    bool Unstable;

    Meta::Plugin@ local;

    // Status
    // 0 = none
    // 1 = downloading
    // 2 = installing
    // 3 = updating
    // 4 = uninstalling
    uint status;
    string msg;

    Plugin(Meta::Plugin@ plugin) {
      Name = plugin.Name;
      Author = plugin.Author;
      Version = Semver::Version(plugin.Version);
      Installed = true;
      @local = plugin;
    }

    Plugin(Json::Value data) {
      SiteID = Text::ParseInt(data["id"]);
      Name = data["name"];
      Author = data["author"];
      Version = Semver::Version(data["version"]);
      LastUpdated = data["updatetime"];
      Downloads = data["downloads"];
      ShortDesc = data["shortdescription"];
      Featured = FEATURED_PLUGINS.Find(SiteID) > -1;
      status = 0;
    }

    bool UpdateAvailable() {
      // If plugin is not installed then return true
      if (local is null) return false;

      /* return (Semver::Version(plugin.Version) > this.Version); */
      return (this.Version > Semver::Version(local.Version));
    }

    bool Busy() {
      return this.status > 0;
    }

    string Status() {
      if (this.msg.Length > 0) {
        return this.msg;
      }
      switch (this.status) {
        case 1:
          this.msg = "Downloading...";
        break;
        case 2:
          this.msg = "Installing...";
        break;
        case 3:
          this.msg = "Updating...";
        break;
        case 4:
          this.msg = "Uninstalling...";
        break;
        default:
          this.msg = "";
        break;
      }
      return this.msg;
    }

    void Uninstall() {
      if (this.Busy()) return;

      this.status = 4;
      print(this.Status() + " " + this.Name);
      if (this.local.Source != Meta::PluginSource::UserFolder) {
        this.msg = "can only uninstall from user UserFolder";
        return;
      }
      // 1. Disable the plugin
      if (this.local.Enabled) {
        this.local.Disable();
      }

      // 2. Unload plugin
      /* Meta::UnloadPlugin(this.local); */

      // 3. Delete plugin files | zip
      if (IO::FolderExists(this.local.SourcePath)) {
        string[]@ paths = IO::IndexFolder(this.local.SourcePath, true);
        for (uint i = 0; i < paths.Length; i++) {
          this.msg = "removing: " + paths[i];
          /* IO::Delete(paths[i]); */
        }
      }
      this.msg = "";
      this.status = 0;
    }

    void Install() {
      if (this.Busy()) return;

      this.status = 2;
      print(this.Status() + " " + this.Name);
      // Download file
      this.Download();
      status = 0;
    }

    void Update() {
      if (this.Busy()) return;

      print(this.Status() + " " + this.Name);
      this.Download();
      this.status = 3;
      this.Uninstall();
      this.Install();
      /* status = 0; */
    }

    void Download() {
      if (this.Busy()) return;

      this.status = 1;
      print(this.Status() + " " + this.Name);
      /* status = 0; */
    }
  }
}
