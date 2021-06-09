namespace Store {
  class AssetManager {
    dictionary res;

    AssetManager() {
      @res['no-thumb'] = Resources::GetTexture("assets/images/no-thumb.jpg");
      @res['store-banner'] = Resources::GetTexture("assets/images/store-banner.jpg");
      @res['featured-banner'] = Resources::GetTexture("assets/images/featured-banner.jpg");
      @res['installed-banner'] = Resources::GetTexture("assets/images/installed-banner.jpg");
      @res['all-banner'] = Resources::GetTexture("assets/images/all-banner.jpg");
    }

    Resources::Texture@ Get(string key) {
      return cast<Resources::Texture@>(res[key]);
    }
  }
}
