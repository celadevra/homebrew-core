class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "https://www.zsh.org/"
  url "https://downloads.sourceforge.net/project/zsh/zsh/5.6.2/zsh-5.6.2.tar.xz"
  mirror "https://www.zsh.org/pub/zsh-5.6.2.tar.xz"
  sha256 "a50bd66c0557e8eca3b8fa24e85d0de533e775d7a22df042da90488623752e9e"

  bottle do
    sha256 "443795937f11b04a0bff7047fb183c18f48dabff111d1b9f7f576a9881285f58" => :mojave
    sha256 "b907030adf23a3a218eca94e4a3d25b55167ab5a3b27ee1eaab75955dfc3eb70" => :high_sierra
    sha256 "abbb8bd5136e9d550bab6c6d44e36df3246f7f4027fa716a1237e3d8432ebd95" => :sierra
    sha256 "a5df51c6e413290baa02137530f3834a783f69ce942bf2928d5da77575b524ea" => :el_capitan
    sha256 "8407cde27f3017a31d238b2e64611b737a38932d98b4b309eca64b2df9d91edf" => :x86_64_linux
  end

  head do
    url "https://git.code.sf.net/p/zsh/code.git"
    depends_on "autoconf" => :build
  end

  option "without-etcdir", "Disable the reading of Zsh rc files in /etc"
  option "with-unicode9", "Build with Unicode 9 character width support"

  deprecated_option "disable-etcdir" => "without-etcdir"

  depends_on "gdbm" => :optional
  depends_on "pcre" => :optional
  unless OS.mac?
    depends_on "texinfo"
    depends_on "ncurses"
  end

  resource "htmldoc" do
    url "https://downloads.sourceforge.net/project/zsh/zsh/5.6.2/zsh-5.6.2-doc.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.6.2-doc.tar.xz"
    sha256 "98973267547cbdd8471b52e3a2bbe415be2c2c473246536ed8914f685e260114"
  end

  def install
    system "Util/preconfig" if build.head?

    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{pkgshare}/functions
      --enable-scriptdir=#{pkgshare}/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-runhelpdir=#{pkgshare}/help
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-zsh-secure-free
      --with-tcsetpgrp
      DL_EXT=bundle
    ]

    args << "--disable-gdbm" if build.without? "gdbm"
    args << "--enable-pcre" if build.with? "pcre"
    args << "--enable-unicode9" if build.with? "unicode9"

    if build.without? "etcdir"
      args << "--disable-etcdir"
    else
      args << "--enable-etcdir=/etc"
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    if build.head?
      # disable target install.man, because the required yodl comes neither with macOS nor Homebrew
      # also disable install.runhelp and install.info because they would also fail or have no effect
      system "make", "install.bin", "install.modules", "install.fns"
    else
      system "make", "install"
      system "make", "install.info"

      resource("htmldoc").stage do
        (pkgshare/"htmldoc").install Dir["Doc/*.html"]
      end
    end
  end

  test do
    assert_equal "homebrew", shell_output("#{bin}/zsh -c 'echo homebrew'").chomp
    system bin/"zsh", "-c", "printf -v hello -- '%s'"
  end
end
