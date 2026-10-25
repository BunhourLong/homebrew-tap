class Coverwall < Formula
  desc "Album-cover grid screen saver for macOS, controlled from the terminal"
  homepage "https://github.com/BunhourLong/Coverwall"
  url "https://github.com/BunhourLong/Coverwall/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "1f572949783572694d66819593c12267999e4440186f231c9fd5ed1aaf0a0364"
  license "MIT"

  # Command Line Tools are enough (SPIKE_NOTES Q5): no `depends_on xcode:`.
  depends_on macos: :sonoma

  def install
    # SwiftPM's own sandbox can't nest inside Homebrew's.
    system "swift", "build", "--disable-sandbox", "-c", "release"
    system "make", "build/Coverwall.saver"
    bin.install ".build/release/coverwall"
    # `coverwall install` looks for the bundle at <bin>/../share/coverwall (Installer.bundledSaver).
    pkgshare.install "build/Coverwall.saver"
  end

  def caveats
    <<~EOS
      Homebrew can't write to ~/Library, so finish with:
        coverwall install
      then pick Coverwall in System Settings (`coverwall settings`).
      Run `coverwall install` again after every `brew upgrade coverwall`,
      and `coverwall uninstall` before `brew uninstall coverwall`.
    EOS
  end

  test do
    assert_path_exists pkgshare/"Coverwall.saver/Contents/MacOS/Coverwall"
    system "codesign", "--verify", pkgshare/"Coverwall.saver"
    ENV["COVERWALL_DATA_DIR"] = testpath/"data"
    assert_match "no profiles", shell_output("#{bin}/coverwall list").downcase
  end
end
