Store::Manager@ manager;

// The main entry point.
void Main() {
  @manager = Store::Manager();
}

// Render function called every frame intended for Plugin Store UI.
void RenderInterface() {
  if (!Store::STATE_IS_OPEN) return;

  if (Store::LOADING) {
    if (UI::Begin(" \\$f39 " + Icons::ShoppingBag + " \\$fff Plugin Store", Store::STATE_IS_OPEN, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoMove | UI::WindowFlags::NoResize)) {
      UI::SetWindowSize(vec2(Draw::GetWidth() * 0.8, Draw::GetHeight() * 0.8));
      UI::SetWindowPos(vec2(Draw::GetWidth() * 0.1, Draw::GetHeight() * 0.1));
      UI::Text("loading...");
      UI::End();
    }
    return;
  }

  manager.Render();
}

// Render Plugin Store menu item to toggle Plugin Store visibility.
void RenderMenu() {
  if (UI::MenuItem("\\$f39" + Icons::ShoppingBag + "\\$z Store", "", Store::STATE_IS_OPEN)) {
    Store::STATE_IS_OPEN = !Store::STATE_IS_OPEN;
  }
}
