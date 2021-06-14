namespace OpenplanetStore {
  class ViewBlank : View {
    ViewBlank() {
      super(ViewID::Blank, "Blank");
      this.ShowInNv = false;
    }
    void RenderInterface(Manager@ manager) {

    }
  }
}
