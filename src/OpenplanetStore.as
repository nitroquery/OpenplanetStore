namespace OpenplanetStore {
  enum State {
    Destroyed,
    Loading,
    Loaded,
  }
  enum EventType {
    Noop,
    PluginUninstall,
    PluginUninstalling,
    PluginInstall,
    PluginInstalling,
    PluginUpdate,
    PluginUpdating,
  }
}
