require 'thread'

module Mikuru
module ImageEngines
class CLI
	BACKGROUND_COLOR = "black"

	def initialize(filename = nil)
		@filename = filename
	end
	
	def width
		identify! if !@width
		@width
	end
	
	def height
		identify! if !@height
		@height
	end
	
	def save(filename)
		File.open(filename, 'w') do |f|
			f.write(@data)
		end
	end
	
	def create_thumbnail(max_width, max_height, with_borders)
		tempfile = "/tmp/mikuru-#{$$}-#{rand 1000000}.tmp.jpg"
		if with_borders
			 args = ["convert", "-size", "#{max_width}x#{max_height}",
				@filename, "-thumbnail", "#{max_width}x#{max_height}>",
				"-gravity", "center", "-crop", "#{max_width}x#{max_height}+0+0\!",
				"-background", BACKGROUND_COLOR, "-flatten",
				tempfile]
		else
			if width > height
				w = max_width
				h = max_width
			else
				w = max_height
				h = max_height
			end
			args = ["convert", @filename, "-thumbnail", "#{w}x#{h}>", tempfile]
		end
		
		# On JRuby, the command may fail with an exit status of 127 (exit code 32512).
		# Not sure why that happens, but it doesn't appear to be fatal. So we retry
		# if that happens.
		done = false
		while !done
			ret = system(*args)
			if ret
				done = true
			elsif $? != 32512
				raise IOError, "Cannot create thumbnail: exit code #{$?.exitstatus}"
			end
		end
		
		thumb = self.class.new
		thumb.instance_variable_set(:'@data', File.read(tempfile))
		thumb.instance_variable_set(:'@width', max_width)
		thumb.instance_variable_set(:'@width', max_height)
		File.unlink(tempfile)
		return thumb
	end
	
	def destroy!
		@data.replace("") if @data
		@data = nil
	end

private
	MUTEX = Mutex.new
	
	def identify!
		# The `...` triggers some kind of weird JRuby bug
		# unless we synchronize it.
		MUTEX.synchronize do
			`identify '#{@filename}'` =~ /(\d+)x(\d+)/
		end
		@width = $1.to_i
		@height = $2.to_i
	end
end
end # module ImageEngines
end # module Mikuru
