class Convox < Formula
  desc "Command-line interface for the Rack PaaS on AWS"
  homepage "https://convox.com/"
  url "https://github.com/convox/rack/archive/20181006001642.tar.gz"
  sha256 "07010999cc09a32e6c1eddfe44fcae12a294002bce1a667c00d1c9e65493b055"

  bottle do
    cellar :any_skip_relocation
    sha256 "8d547bd15b8dee4fb0ef9b369078d9114ee751f010eaa01a218577d9c986bc41" => :mojave
    sha256 "ed99199cb4818398553644cdb70275dca22e502de844b304618b1ff61311f073" => :high_sierra
    sha256 "630ab6c31590a7fd4bebb90324bdd76e0aa3d03cec8d4dcebc9a0c757caf433d" => :sierra
    sha256 "77a0fa37dddaa067b1c865ce44c843b7b890e3eec22136a37d54e07be779aa53" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/convox/rack").install Dir["*"]
    system "go", "build", "-ldflags=-X main.version=#{version}",
           "-o", bin/"convox", "-v", "github.com/convox/rack/cmd/convox"
    prefix.install_metafiles
  end

  test do
    system bin/"convox"
  end
end
