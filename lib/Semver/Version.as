// <valid semver> ::= <version core>
//                 | <version core> "-" <pre-release>
//                 | <version core> "+" <build>
//                 | <version core> "-" <pre-release> "+" <build>
namespace Semver {
  class Version {
    string str;

    int major;
    int minor;
    int patch;
    string pre;
    string build;

    Version() {
      this.major = 0;
      this.minor = 0;
      this.patch = 0;
    }

    Version(string str) {
      this.str = str;
      this.parse();
    }

    void parse() {
      array<string>@ p = this.str.Split(".");
      if (p.Length > 0) {
        this.major = Text::ParseInt(p[0]);
      }
      if (p.Length > 1) {
        this.minor = Text::ParseInt(p[1]);
      }
      if (p.Length > 2) {
        this.patch = Text::ParseInt(p[2]);
      }
    }

    // Do version equal
    bool opEquals(const Semver::Version@ other) const {
      return this.String() == other.String();
    }

    int opCmp(const Semver::Version@ other) const {
      // Return 1 without other checks if current major is bigger
      if (this.major > other.major) {
        return 1;
      }

      if (this.major == other.major) {
        if (this.minor > other.minor) {
          return 1;
        } else if (this.minor < other.minor) {
          return -1;
        } else {
          // check patch
          if (this.patch > other.patch) {
            return 1;
          } else if (this.patch < other.patch) {
            return -1;
          } else {
            return 0;
          }
        }
      }

      // return -1 if current major is smaller
      return -1;
    }

    string String() const {
      return this.str;
    }
  }
}
