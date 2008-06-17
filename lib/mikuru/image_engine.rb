if RUBY_PLATFORM == "java"
	require 'mikuru/image_engines/cli'
	Mikuru::ImageEngine = Mikuru::ImageEngines::CLI
else
	require 'mikuru/image_engines/image_magick'
	Mikuru::ImageEngine = Mikuru::ImageEngines::ImageMagick
end
