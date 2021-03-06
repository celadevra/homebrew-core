require "language/haskell"

class PandocCiteproc < Formula
  include Language::Haskell::Cabal

  desc "Library and executable for using citeproc with pandoc"
  homepage "https://github.com/jgm/pandoc-citeproc"
  url "https://hackage.haskell.org/package/pandoc-citeproc-0.14.5/pandoc-citeproc-0.14.5.tar.gz"
  sha256 "e8d71c016b7949e8ac25dff19773920ec1f52ca4ce1128ca4dc2212b5c892a46"
  head "https://github.com/jgm/pandoc-citeproc.git"

  bottle do
    sha256 "022f0c850cb583f85a5eff6f2aee61c567d5d2cb5602f92b3c4b287e953b0325" => :mojave
    sha256 "584d07ac76131c7948daeaf89bd25da42441f5124a0c2db1dadbf659fe3ae8bf" => :high_sierra
    sha256 "7e49bc059c26c629f1a5237dd5823900f91dbdc4b5f0baa48f41c3e6c9f5abd7" => :sierra
    sha256 "90840071ecdf8a31232db58f5d7e58a6879d7c7b181820ff3ad6f81b949d29db" => :x86_64_linux
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "pandoc"
  depends_on "unzip" => :build unless OS.mac?

  def install
    args = []
    args << "--constraint=cryptonite -support_aesni" if MacOS.version <= :lion
    install_cabal_package *args
  end

  test do
    (testpath/"test.bib").write <<~EOS
      @Book{item1,
      author="John Doe",
      title="First Book",
      year="2005",
      address="Cambridge",
      publisher="Cambridge University Press"
      }
    EOS
    expected = <<~EOS
      ---
      references:
      - id: item1
        type: book
        author:
        - family: Doe
          given: John
        issued:
        - year: 2005
        title: First book
        publisher: Cambridge University Press
        publisher-place: Cambridge
      ...
    EOS
    assert_equal expected, shell_output("#{bin}/pandoc-citeproc -y test.bib")
  end
end
