Import::Library@ opstore;
OpenplanetStore::Manager@ manager;

bool IsValid;
bool IsOpen;
bool IsRequested; // true when user first selects store

// The main entry point.
void Main() {
  Meta::Plugin@ selfplugin = Meta::ExecutingPlugin();
  @manager = OpenplanetStore::Manager();
  manager.Version = selfplugin.Version;

  // TODO https://github.com/nitroquery/OpenplanetStore/issues/7
  string dllpath = selfplugin.SourcePath + "/lib/opstore/opstore.dll";

  if (IO::FileExists(dllpath)) {
    @opstore = Import::GetLibrary(dllpath);
  }

  if (opstore is null) {
    Error("failed to load Openplanet store shared library");
    return;
  }

  startnew(initialize);
  while (true) {
    manager.Tick();
    yield();
  }
}

// Called when the plugin is getting disabled from the settings.
void OnDisabled() {
  IsOpen = false;
  Print("OnDisabled");
}

// Render Store interface
void RenderInterface() {
  if (IsValid && IsOpen) {
    manager.RenderInterface();
  }
}

// Render main menu link
void RenderMenuMain() {
  if (!IsValid) return;

  if (UI::MenuItem("\\$f39" + Icons::ShoppingBag + "\\$z Store", "", IsOpen)) {
    IsOpen = !IsOpen;
    // Call once on first click
    if (!IsRequested && IsOpen) {
      IsRequested = true;
      manager.RefreshPluginList();
    }
  }
}

// Called when the plugin is getting unloaded from menu.
void OnDestroyed() {
  shutdown("OnDestroyed");
}

// Initialize Store background job
void initialize() {
  if (opstore is null) return;

  string userDir = IO::FromDataFolder(".");
  Import::Function@ Initialize = opstore.GetFunction("Initialize");
  string err = Initialize.CallString(userDir);
  if (err.Length > 0) {
    Error("failed to initialize Openplanet store instance (" + err + ")");
    return;
  }

  IsValid = true;
  Print("Openplanet Store loaded");
}

// shutdown performs graceful shutdown of Openplanet store
void shutdown(string caller) {
  Print(caller + " - shutting down");
  IsValid = false;
  IsOpen = false;
  if (opstore !is null) {
    Import::Function@ Dispose = opstore.GetFunction("Dispose");
    if(Dispose is null || !Dispose.CallBool()) {
      Warn(caller + " - failed to gracefully shutdown Openplanet store instance");
      return;
    }
    Print(caller + " - Openplanet store graceful shutdown successful");
  }
}

// Logger namespace
void Print(string msg) { print("[STORE]: " + msg); }
void Error(string msg) {
  error("[STORE]: " + msg);
  manager.StatusMsg = "[error]: " + msg;
}
void Warn(string msg) { warn("[STORE]: " + msg); }
