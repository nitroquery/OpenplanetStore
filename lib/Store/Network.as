namespace Store {
  // Plugin store Network utils
  class Network {
    // Fetches and returns list of all available plugins
    array<Plugin@> GetAvailablePlugins() {
      print("STORE: fetch available plugins from Openplanet API");
      array<Plugin@> plugins;
      this.apiFetchAvailablePluginsList(0, plugins);
      print("STORE: received information of " + plugins.Length + " plugins");

      Meta::Plugin@[]@ installed = Meta::AllPlugins();
      for (uint i = 0; i < plugins.Length; i++) {
        for (uint i2 = 0; i2 < installed.Length; i2++) {
          if (installed[i2].SiteID == plugins[i].SiteID && !installed[i2].Unstable) {
            @plugins[i].local = installed[i2];
            plugins[i].Installed = true;
            installed.RemoveAt(i2);
          }
        }
      }

      for (uint i = 0; i < installed.Length; i++) {
        if (installed[i].Source == Meta::PluginSource::UserFolder) {
          Plugin@ plugin = Plugin(installed[i]);
          plugin.Unstable = true;
          plugins.InsertLast(plugin);
          HAS_UNSTABLE_PLUGINS = true;
        }
      }
      return plugins;
    }

    // https://openplanet.nl/api/files
    void apiFetchAvailablePluginsList(int page, array<Plugin@> &plugins) {
      dictionary@ Headers = dictionary();
      Headers["Accept"] = "application/json";
      Headers["Contrnt-Type"] = "application/json";
      Headers["User-Agent"] = "Openplanet Plugin Store";
      Net::HttpRequest req;
      req.Method = Net::HttpMethod::Get;
      req.Url = "https://openplanet.nl/api/files/" + page;
      @req.Headers = Headers;
      req.Start();
      while (!req.Finished()) {
        yield();
      }
      Json::Value response;
      // Try to read the response
      try {
        response = Json::Parse(req.String());
      } catch {
        error("failed to fetch available plugins");
        return;
      }

      // Check does page has plugins
      if (!response.HasKey("items")) {
        return;
      }

      // Parse fetched plugins
      for (uint i = 0; i < response["items"].Length; i++) {
        plugins.InsertLast(Plugin(response["items"][i]));
      }

      // Check do we need to recurse the network request for next page
      page = response["page"];
      int pages = response["pages"];
      if (page < pages) {
        this.apiFetchAvailablePluginsList(page + 1, plugins);
      }
    }
  }
}
