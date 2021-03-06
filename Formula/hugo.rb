class Hugo < Formula
  desc "Configurable static site generator"
  homepage "https://gohugo.io/"
  url "https://github.com/gohugoio/hugo/archive/v0.39.tar.gz"
  sha256 "db8e8e8f51879d8892bc089bc2078bfa83a7d9a4231e39c60220911b2ee9ad30"
  head "https://github.com/gohugoio/hugo.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d96be3c9440dff2fb4a45c31073a70e78a5770363fb224fcf5f2b5d0a6d02cce" => :high_sierra
    sha256 "071b9f57b2157b295bfd467b4b7c8de9271fd5c54edb66591c3787db21981d99" => :sierra
    sha256 "c516db1022f110829ab3f11e578179e1555f321587d3b11dce8c9ee1972433fd" => :el_capitan
    sha256 "501bdcf68d843eaa705ae877ace1b1489bc84d21e34f8c5d61a87fd6a45b972b" => :x86_64_linux
  end

  depends_on "dep" => :build
  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/gohugoio/hugo").install buildpath.children
    cd "src/github.com/gohugoio/hugo" do
      system "dep", "ensure"
      system "go", "build", "-o", bin/"hugo", "main.go"

      # Build bash completion
      system bin/"hugo", "gen", "autocomplete", "--completionfile=hugo.sh"
      bash_completion.install "hugo.sh"

      # Build man pages; target dir man/ is hardcoded :(
      (Pathname.pwd/"man").mkpath
      system bin/"hugo", "gen", "man"
      man1.install Dir["man/*.1"]

      prefix.install_metafiles
    end
  end

  test do
    site = testpath/"hops-yeast-malt-water"
    system "#{bin}/hugo", "new", "site", site
    assert_predicate testpath/"#{site}/config.toml", :exist?
  end
end
