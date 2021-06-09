namespace Store {
  // STATE_IS_OPEN is store open
  bool STATE_IS_OPEN = false;
  // CURRENT_VIEW
  // 0. Main Store view
  // 1. Available plugins view
  // 2. Installed view
  // 3. Unstable view
  // 4. Plugin details view
  uint CURRENT_VIEW = 0;

  bool LOADING = true;
  uint ITEMS_PER_PAGE = 8;
  uint STORE_CURR_PAGE = 1;
  array<uint> FEATURED_PLUGINS = {
    71, // AFK Queue Tool
    103, // Dashboard
    52, // TM 2020 Map Medals Window
    79, // Checkpoint Counter
  };
  bool HAS_UNSTABLE_PLUGINS;
}
