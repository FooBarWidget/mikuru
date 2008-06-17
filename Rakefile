require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
	s.platform = Gem::Platform::RUBY
	s.summary = "Mikuru static image gallery generator"
	s.name = "mikuru"
	s.version = "1.1.0"
	s.author = "Hongli Lai"
	s.email = "hongli@plan99.net"
	s.require_path = ["lib"]
	s.files = FileList[
		'Readme.txt',
		'License.txt',
		'Rakefile',
		'bin/*',
		'data/*',
		'lib/**/*'
	]
	s.executables = [
		'mikuru'
	]
	s.has_rdoc = false
	s.description = "Mikuru is a static image gallery generator."
end

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_tar_gz = true
end

