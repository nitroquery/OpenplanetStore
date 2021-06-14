namespace OpenplanetStore {
  enum ViewID {
    Blank,
    Home,
    PluginList,
    PluginDetails,
  }

  class View {
    ViewID id;
    string Title;
    bool ShowInNv;
    bool Open;

    View(ViewID id, string title) {
      this.id = id;
      this.Title = title;
      this.ShowInNv = true;
    }

    ViewID ID() {
      return this.id;
    }

    void RenderInterface(Manager@ manager) {}
  }
}
