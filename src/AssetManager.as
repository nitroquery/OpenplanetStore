namespace OpenplanetStore {
  // AssetManager is managing all local and remote resources.
  class AssetManager {
    dictionary res;

    AssetManager() {
      this.LoadTexture("no-thumb", "assets/images/no-thumb.jpg");
      this.LoadTexture("store-banner", "assets/images/store-banner.png");
      this.LoadTexture("store-loading", "assets/images/store-loading.png");
      this.LoadTexture("title-featured", "assets/images/title-featured.png");
      this.LoadTexture("title-plugins", "assets/images/title-plugins.png");
    }

    // Load texture from path and register loaded texture by given key.
    void LoadTexture(string key, string path) {
      @res[key] = Resources::GetTexture(path);
    }

    // Get Texture by given key or return default texture if key is not found.
    Resources::Texture@ GetTexture(string key) {
      if (res.Exists(key)) {
        return cast<Resources::Texture@>(res[key]);
      } else {
        return cast<Resources::Texture@>(res['no-thumb']);
      }
    }
  }
}
