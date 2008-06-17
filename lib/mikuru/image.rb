require 'thread'
require 'mikuru/image_engine'

module Mikuru
class Image
	attr_accessor :filename
	
	def initialize(filename, small_thumbnail_dir = "small_thumbs", medium_thumbnail_dir = "medium_thumbs")
		@mutex = Mutex.new
		@filename = filename
		@small_thumbnail_dir = small_thumbnail_dir
		@medium_thumbnail_dir = medium_thumbnail_dir
	end
	
	def destroy!(recursive = true)
		if @engine.respond_to?(:destroy!)
			@engine.destroy!
		end
		if recursive
			small_thumbnail.destroy!(true) if small_thumbnail
			medium_thumbnail.destroy!(true) if medium_thumbnail
		end
	end
	
	def engine
		@mutex.synchronize do
			@engine ||= ImageEngine.new(@filename)
		end
	end
	
	def engine=(e)
		@mutex.synchronize do
			@engine = e
		end
	end
	
	def width
		@width ||= engine.width
	end
	
	def height
		@width ||= engine.height
	end
	
	def missing_a_thumbnail?
		return !small_thumbnail || (!medium_thumbnail && should_have_medium_thumbnail?)
	end
	
	def small_thumbnail
		if !@small_thumbnail
			filename = "#{@small_thumbnail_dir}/#{File.basename(@filename)}"
			#puts "check #{filename}"
			if File.exist?(filename)
				@small_thumbnail = Image.new(filename)
			end
		end
		return @small_thumbnail
	end
	
	def medium_thumbnail
		if !@medium_thumbnail
			filename = "#{@medium_thumbnail_dir}/#{File.basename(@filename)}"
			if File.exist?(filename)
				@medium_thumbnail = Image.new(filename)
			end
		end
		return @medium_thumbnail
	end
	
	def should_have_medium_thumbnail?
		return width > 600 || height > 800
	end
	
	def create_small_thumbnail
		@small_thumbnail = create_thumbnail(
			"#{@small_thumbnail_dir}/#{File.basename(@filename)}",
			150, 150)
	end
	
	def create_medium_thumbnail
		@medium_thumbnail = create_thumbnail(
			"#{@medium_thumbnail_dir}/#{File.basename(@filename)}",
			600, 800)
	end

private
	def create_thumbnail(filename, max_width, max_height)
		thumb = engine.create_thumbnail(max_width, max_height)
		thumb.save(filename)
		
		image = Image.new(filename)
		image.engine = thumb
		return image
	end
end
end # module Mikuru
