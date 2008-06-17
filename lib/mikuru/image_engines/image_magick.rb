require 'RMagick'
require 'thread'

module Mikuru
module ImageEngines
class ImageMagick
	MUTEX = Mutex.new
	@@destroy_count = 0
	
	def initialize(filename = nil)
		if filename
			@raw_image = Magick::Image.read(filename).first
		end
	end
	
	def width
		return @raw_image.columns
	end
	
	def height
		return @raw_image.rows
	end
	
	def save(filename)
		@raw_image.write(filename)
	end
	
	def create_thumbnail(max_width, max_height)
		if @raw_image.columns > @raw_image.rows
			width = max_width
			height = @raw_image.rows * (max_width / @raw_image.columns.to_f)
		else
			height = max_height
			width = @raw_image.columns * (max_height / @raw_image.rows.to_f)
		end
		
		thumb = @raw_image.thumbnail(width, height)
		final = Magick::Image.new(max_width, max_height)
		final.composite!(thumb, Magick::CenterGravity, Magick::OverCompositeOp)
		thumb.destroy! if thumb.respond_to?(:destroy!)
		
		engine = self.class.new
		engine.instance_variable_set(:'@raw_image', final)
		return engine
	end
	
	def destroy!
		if @raw_image.respond_to?(:destroy!)
			@raw_image.destroy!
			@raw_image = nil
		else
			@raw_image = nil
			MUTEX.synchronize do
				@@destroy_count += 1
				if @@destroy_count == 10
					@@destroy_count = 0
					GC.start
				end
			end
		end
	end
end
end # module ImageEngines
end # module Mikuru
