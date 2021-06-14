namespace OpenplanetStore {
  class Layout {
    bool Open;
    array<View@> Views;

    // Construct Store layout
    Layout() {
      Views.InsertLast(ViewHome());
      Views.InsertLast(ViewBlank());
      Views.InsertLast(ViewPlugins());
    }

    void RenderInterface(Manager@ manager) {
      if (UI::Begin(" \\$f39 " + Icons::ShoppingBag + " \\$fff Openplanet Store \\$555 v" + manager.Version + "###", IsOpen,
        UI::WindowFlags::NoCollapse |
        UI::WindowFlags::NoMove |
        UI::WindowFlags::NoDocking |
        UI::WindowFlags::NoResize)) {
        // Store view
        UI::SetWindowSize(vec2(Draw::GetWidth() * 0.8, Draw::GetHeight() * 0.8));
        UI::SetWindowPos(vec2(Draw::GetWidth() * 0.1, Draw::GetHeight() * 0.1));

        // Store banner
        vec2 bannersize = manager.Assets.GetTexture("store-banner").GetSize();
        float bannerscale = UI::GetWindowSize().x / bannersize.x;
        bannersize.x = UI::GetWindowSize().x;
        bannersize.y = bannersize.y * bannerscale;
        UI::Image(manager.Assets.GetTexture("store-banner"), bannersize);

        // Loading viwe
        if (manager.state == State::Loading) {
          vec2 loadingsize = manager.Assets.GetTexture("store-loading").GetSize();
          float loadingscale = UI::GetWindowSize().x / loadingsize.x;
          loadingsize.x = UI::GetWindowSize().x;
          loadingsize.y = loadingsize.y * loadingscale;
          UI::Image(manager.Assets.GetTexture("store-loading"), loadingsize);
          UI::Text(manager.StatusMsg);

        } else if (manager.state == State::Loaded) {
          UI::SetWindowSize(vec2(Draw::GetWidth() * 0.8, Draw::GetHeight() * 0.8));
          UI::SetWindowPos(vec2(Draw::GetWidth() * 0.1, Draw::GetHeight() * 0.1));
          // Store navigation
          UI::BeginTabBar("Openplanet Store", UI::TabBarFlags::FittingPolicyResizeDown);
          UI::PushStyleColor(UI::Col::Tab, vec4(0, 0, 0, 1));
          UI::PushStyleColor(UI::Col::TabHovered, vec4(1, 0.50, 0.75, 1));
          UI::PushStyleColor(UI::Col::TabActive, vec4(1, 0.2, 0.6, 1));
          UI::PushStyleColor(UI::Col::Button, vec4(1, 0.2, 0.6, 1));
          UI::PushStyleColor(UI::Col::ButtonHovered, vec4(1, 0.50, 0.75, 1));
          UI::PushStyleColor(UI::Col::ButtonActive, vec4(1, 0.50, 0.75, 1));

          // Views
          for (uint i = 0; i < this.Views.Length; i++) {
            if (this.Views[i].ShowInNv) {
              if (UI::BeginTabItem(this.Views[i].Title, UI::TabItemFlags::NoCloseWithMiddleMouseButton | UI::TabItemFlags::NoReorder | UI::TabItemFlags::NoTooltip)) {
                manager.CurrentViewID = this.Views[i].id;
                this.Views[i].Open = true;
                this.Views[i].RenderInterface(manager);
                UI::EndTabItem();
              }
            }
          }
          UI::PopStyleColor(6);
          UI::EndTabBar();
        } else {
          /* UI::Text("error"); */
        }
        UI::End();
      }
    }
  }
}
