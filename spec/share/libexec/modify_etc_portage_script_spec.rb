require 'tmpdir'
require 'fileutils'
require 'spec_helper'

describe "modify-etc-portage" do
  SCRIPT_PATH = File.expand_path("../../../share/libexec/modify-etc-portage", __dir__)
  let(:tmpdir) { Dir.mktmpdir }
  let(:source) { File.join(tmpdir, "source") }
  let(:target) { File.join(tmpdir, "target") }
  let(:cmdline) { [ENV['PYTHON3'] || 'python3', SCRIPT_PATH, source, target] }

  def run_cmd
    system(*cmdline) or raise "cmd fail: #{cmdline.inspect}"
  end

  after do
    if File.exist?(tmpdir)
      FileUtils.remove_entry_secure(tmpdir)
    end
  end

  describe "target is a directory" do
    it "merges existing content ordered by original filename" do
      File.write source, "x 1\n"
      Dir.mkdir(target)
      File.write File.join(target, '2'), "b 1\n"
      File.write File.join(target, '1'), "a 1\n"
      run_cmd
      expect(File.read(target)).to eq "a 1\nb 1\nx 1\n"
    end
  end

  describe "target is a file" do
    it "doesn't write comments out" do
      File.write source, "# comment\nx 1\n"
      File.write target, "# comment2\na 1\n"
      run_cmd
      expect(File.read(target)).to eq "a 1\nx 1\n"

    end

    it "doesn't write lines in the existing content, which exist in the source content" do
      File.write source, "x 1\n"
      File.write target, "a 1\nx x\nb 1\nx y\n"
      run_cmd
      expect(File.read(target)).to eq "a 1\nb 1\nx 1\n"
    end
  end
end
