Store::Manager@ manager;

// The main entry point.
void Main() {
  @manager = Store::Manager();
}

// Render function called every frame intended for Plugin Store UI.
void RenderInterface() {
  if (!Store::STATE_IS_OPEN) return;
  manager.Render();
}

// Render Plugin Store menu item to toggle Plugin Store visibility.
void RenderMenu() {
  if (UI::MenuItem("\\$f39" + Icons::ShoppingBag + "\\$z Store", "", Store::STATE_IS_OPEN)) {
    Store::STATE_IS_OPEN = !Store::STATE_IS_OPEN;
  }
}
