require 'rake/gempackagetask'
spec = eval(File.read('mikuru.gemspec'))
Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_tar_gz = true
end

