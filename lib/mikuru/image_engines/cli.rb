module Mikuru
module ImageEngines
class CLI
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
	
	def create_thumbnail(max_width, max_height)
		tempfile = "/tmp/mikuru-#{$$}-#{rand 1000000}.tmp.jpg"
		if !system("convert", "-size", "#{max_width}x#{max_height}", @filename,
		   "-thumbnail", "#{max_width}x#{max_height}>", "pattern:gray100",
		   "+swap", "-gravity", "center", "-composite",
		   tempfile)
			raise IOError, "Cannot create thumbnail."
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
	def identify!
		`identify '#{@filename}'` =~ /(\d+)x(\d+)/
		@width = $1.to_i
		@height = $2.to_i
	end
end
end # module ImageEngines
end # module Mikuru
