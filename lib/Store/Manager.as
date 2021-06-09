namespace Store {
  // Store Manager
  class Manager {
    ////////// PUBLIC
    // Loaded assets
    Store::AssetManager@ Assets;
    // Store interface
    Store::Layout@ Layout;
    // Loaded plugins
    array<Store::Plugin@> Plugins;
    // Featured plugins
    array<Store::Plugin@> Featured;

    ////////// PRIVATE
    // Store plugin
    Meta::Plugin@ plugin;
    // Store manager network tools
    Store::Network@ net;

    Store::Plugin@ selected;

    // Initialize Store Manager
    Manager() {
      LOADING = true;
      @plugin = Meta::ExecutingPlugin();
      @Assets = AssetManager();
      @Layout = Store::Layout();
      @net = Store::Network();

      // Get initital plugin list
      Plugins = net.GetAvailablePlugins();

      LOADING = false;
    }

    // Render is called everytime when Store plugin RenderInterface is called.
    void Render() {
      if (UI::Begin(" \\$f39 " + Icons::ShoppingBag + " \\$fff Plugin Store \\$555 v" + plugin.Version + "###", Store::STATE_IS_OPEN, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoMove | UI::WindowFlags::NoResize)) {
        UI::SetWindowSize(vec2(Draw::GetWidth() * 0.8, Draw::GetHeight() * 0.8));
        UI::SetWindowPos(vec2(Draw::GetWidth() * 0.1, Draw::GetHeight() * 0.1));

        UI::BeginTabBar("Plugin Store", UI::TabBarFlags::FittingPolicyResizeDown);
        UI::PushStyleColor(UI::Col::Tab, vec4(0, 0, 0, 1));
        UI::PushStyleColor(UI::Col::TabHovered, vec4(1, 0.50, 0.75, 1));
        UI::PushStyleColor(UI::Col::TabActive, vec4(1, 0.2, 0.6, 1));

        UI::PushStyleColor(UI::Col::Button, vec4(1, 0.2, 0.6, 1));
        UI::PushStyleColor(UI::Col::ButtonHovered, vec4(1, 0.50, 0.75, 1));
        UI::PushStyleColor(UI::Col::ButtonActive, vec4(1, 0.50, 0.75, 1));

        if (UI::BeginTabItem("Store")) {
          CURRENT_VIEW = 0;
          this.Layout.Home(this);
          UI::EndTabItem();
        }

        if (UI::BeginTabItem("Installed")) {
          CURRENT_VIEW = 1;
          this.Layout.InstalledPlugins(this);
          UI::EndTabItem();
        }

        if (UI::BeginTabItem("Unstable") && HAS_UNSTABLE_PLUGINS) {
          CURRENT_VIEW = 3;
          this.Layout.UnstablePlugins(this);
          UI::EndTabItem();
        }

        if (CURRENT_VIEW == 2 && this.selected !is null) {
          if (UI::BeginTabItem(this.selected.Name, UI::TabItemFlags::SetSelected)) {
            this.Layout.Details(this);
            UI::EndTabItem();
          }
        }

        UI::PopStyleColor(6);
        UI::EndTabBar();
        // Main view
        UI::End();
      }
    }
  }
}
