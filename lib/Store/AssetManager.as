namespace Store {
  // AssetManager is managing all local and remote resources.
  class AssetManager {
    dictionary res;

    AssetManager() {
      this.LoadTexture("no-thumb", "assets/images/no-thumb.jpg");
      this.LoadTexture("store-banner", "assets/images/store-banner.jpg");
      this.LoadTexture("featured-banner", "assets/images/featured-banner.jpg");
      this.LoadTexture("installed-banner", "assets/images/installed-banner.jpg");
      this.LoadTexture("all-banner", "assets/images/all-banner.jpg");
    }

    // Load texture from path and register loaded texture by given key.
    void LoadTexture(string key, string path) {
      @res[key] = Resources::GetTexture(path);
    }

    // Get Texture by given key or return default texture if key is not found.
    Resources::Texture@ GetTexture(string key) {
      Resources::Texture@ t = cast<Resources::Texture@>(res[key]);
      if (t is null) {
        return cast<Resources::Texture@>(res['no-thumb']);
      }
      return t;
    }
  }
}
