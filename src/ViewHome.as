namespace OpenplanetStore {
  class ViewHome : View {
    ViewHome() {
      super(ViewID::Home, "Home");
    }
    void RenderInterface(Manager@ manager) {
      // Featured plugins
      vec2 titlesize = manager.Assets.GetTexture("title-featured").GetSize();
      float titlescale = UI::GetWindowSize().x / titlesize.x;
      titlesize.x = UI::GetWindowSize().x;
      titlesize.y = titlesize.y * titlescale;
      UI::Image(manager.Assets.GetTexture("title-featured"), titlesize);
    }
  }
}
