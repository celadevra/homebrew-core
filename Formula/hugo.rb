class Hugo < Formula
  desc "Configurable static site generator"
  homepage "https://gohugo.io/"
  url "https://github.com/gohugoio/hugo/archive/v0.49.2.tar.gz"
  sha256 "aa33ec72154e38ac64c9d17b2dcb111cdac58e4d479ac92d1ba7ac54988380ed"
  head "https://github.com/gohugoio/hugo.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "51f5fde7761589e8cefeb2ee7b4a3993a1e56b28a43f628839f21b99d04f90d3" => :mojave
    sha256 "3eb372c2328c91ccd140e6c63556f26f10e5dd12925d2995ab91fc032907bfe1" => :high_sierra
    sha256 "39ceee7ef764a4915d19b4aa65f6a3e0a1bc2bd799a39cd681ea10351d504d63" => :sierra
    sha256 "2a7a7b106e2eff39afcb92eca8c084b72f8ba3d622af4ba1adda56c6b26dbb7b" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = HOMEBREW_CACHE/"go_cache"
    (buildpath/"src/github.com/gohugoio/hugo").install buildpath.children

    cd "src/github.com/gohugoio/hugo" do
      system "go", "build", "-o", bin/"hugo", "-tags", "extended", "main.go"

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
