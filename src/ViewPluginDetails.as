namespace OpenplanetStore {
  class ViewPluginDetails : View {
    ViewPluginDetails() {
      super(ViewID::PluginList, "Plugins Details");
    }

    void RenderInterface(Manager@ manager) {
      // Plugin details page
      UI::BeginChild("Plugin: " + manager.SelectedPlugin.Name);
      if (UI::BeginTable("DetailsView", 2, UI::TableFlags::NoBordersInBody | UI::TableFlags::SizingStretchProp)) {
        UI::TableSetupColumn("aside", UI::TableColumnFlags::WidthFixed, UI::GetWindowSize().x / 4);
        UI::TableNextRow();
        UI::TableSetColumnIndex(0);
        if (manager.SelectedPlugin.Img !is null) {
          vec2 thumbsize = manager.SelectedPlugin.Img.GetSize();
          thumbsize /= thumbsize.x / 256;
          UI::Image(manager.SelectedPlugin.Img, thumbsize);
        } else {
          vec2 thumbsize = manager.Assets.GetTexture("no-thumb").GetSize();
          thumbsize /= thumbsize.x / 256;
          UI::Image(manager.Assets.GetTexture("no-thumb"), thumbsize);
        }

        if (manager.SelectedPlugin.EventType == EventType::Noop) {
          if (manager.SelectedPlugin.Installed) {
            if (manager.SelectedPlugin.Source != Meta::PluginSource::UserFolder) {
              UI::Text("Core plugin");
            } else {
              if (manager.SelectedPlugin.UpdateAvailable) {
                UI::PushStyleColor(UI::Col::Button, vec4(0.867,0.733,0.467,1));
                if (UI::Button("Get " + manager.SelectedPlugin.AvailableVersion)) {
                  manager.PendingEvent = EventType::PluginUpdate;
                }
                UI::PopStyleColor();
                UI::SameLine();
              }
              UI::PushStyleColor(UI::Col::Button, vec4(1,0,0,1));
              if (UI::Button("Uninstall")) {
                manager.PendingEvent = EventType::PluginUninstall;
              }

              UI::PopStyleColor();
            }
          } else {
            if (UI::Button("Install")) {
              manager.PendingEvent = EventType::PluginInstall;
            }
          }
        } else {
          switch (manager.SelectedPlugin.EventType) {
            case EventType::PluginInstalling:
              UI::Text("installing...");
            break;
            case EventType::PluginUpdating:
              UI::Text("updating...");
            break;
            case EventType::PluginUninstalling:
              UI::Text("uninstalling...");
            break;
            default:
              UI::Text("wait...");
            break;
          }
        }


        if (UI::BeginTable("DetailsView", 2, UI::TableFlags::Borders)) {
          // Version
          UI::TableNextRow();
          UI::TableNextColumn();
          UI::Text("Version:");
          UI::TableNextColumn();
          if (manager.SelectedPlugin.Installed) {
            UI::Text(manager.SelectedPlugin.Version); // get installed v
          } else {
            UI::Text(manager.SelectedPlugin.Version);
          }
          // Author
          UI::TableNextRow();
          UI::TableNextColumn();
          UI::Text("Author:");
          UI::TableNextColumn();
          UI::Text(ColoredString(manager.SelectedPlugin.Author));
          // Last updated
          UI::TableNextRow();
          UI::TableNextColumn();
          UI::Text("Last updated:");
          UI::TableNextColumn();
          // DateTime(); API ??
          UI::Text(""+ manager.SelectedPlugin.UpdatedAt);
          // Downloads
          UI::TableNextRow();
          UI::TableNextColumn();
          UI::Text("Downloads:");
          UI::TableNextColumn();
          UI::Text(""+manager.SelectedPlugin.Downloads);

          UI::EndTable();
        }
        // Details
        UI::TableNextColumn();

        UI::Text(manager.SelectedPlugin.Name);
        UI::Text(manager.SelectedPlugin.Desc);

        UI::EndTable();
      }
      UI::EndChild();
    }
  }
}
