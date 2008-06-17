require 'erb'
require 'thread'
require 'mikuru/image'

module Mikuru
class Generator
	THUMBNAIL_MAX_WIDTH = 150
	THUMBNAIL_MAX_HEIGHT = 150
	TEMPLATE_FILE = File.expand_path(File.dirname(__FILE__) + "/../../data/mikuru.erb.html")
	include ERB::Util
	
	def initialize(image_dir)
		@image_dir = image_dir
		@workers = []
		@queue = []
		@mutex = Mutex.new
		@cond = ConditionVariable.new
	end

	def start
		start_workers
		small_thumbnail_dir, medium_thumbnail_dir = create_thumbnail_dirs
		images = each_image(small_thumbnail_dir, medium_thumbnail_dir) do |image|
			if image.missing_a_thumbnail?
				pass_to_worker do
					if !image.small_thumbnail
						image.create_small_thumbnail
						puts "WRITE      #{image.small_thumbnail.filename}"
					end
					if !image.medium_thumbnail && image.should_have_medium_thumbnail?
						image.create_medium_thumbnail
						puts "WRITE      #{image.medium_thumbnail.filename}"
					end
					image.destroy!
				end
			else
				image.destroy!
			end
		end
		wait_for_workers
		create_gallery_page(images)
	end

private
	def each_image(small_thumbnail_dir, medium_thumbnail_dir)
		images = []
		if @image_dir == "."
			image_dir = ""
		else
			image_dir = "#{@image_dir}/"
		end
		Dir["#{image_dir}*.{jpg,JPG}"].sort.each do |filename|
			image = Image.new(filename, small_thumbnail_dir, medium_thumbnail_dir)
			yield image
			images << image
		end
		return images
	end
	
	def number_of_cpus
		return 2
	end
	
	def create_thumbnail_dirs
		folders = []
		if @image_dir == "."
			image_dir = ""
		else
			image_dir = "#{@image_dir}/"
		end
		['small', 'medium'].each do |name|
			thumbnail_folder = "#{image_dir}#{name}_thumbnails"
			if !File.exist?(thumbnail_folder)
				puts "MKDIR      #{thumbnail_folder}"
				Dir.mkdir(thumbnail_folder)
			end
			folders << thumbnail_folder
		end
		return folders
	end
	
	def start_workers
		Thread.abort_on_exception = true
		number_of_cpus.times do
			@workers << Thread.new(&method(:worker_main))
		end
	end
	
	def worker_main
		while true
			item = nil
			@mutex.synchronize do
				while @queue.empty?
					@cond.wait(@mutex)
				end
				item = @queue.shift
				@cond.broadcast
				if item.nil?
					return
				end
			end
			item.call
		end
	end
	
	def pass_to_worker(&block)
		@mutex.synchronize do
			while @queue.size >= number_of_cpus
				@cond.wait(@mutex)
			end
			@queue << block
			@cond.broadcast
		end
	end
	
	def wait_for_workers
		@mutex.synchronize do
			@workers.size.times do
				@queue << nil
			end
			@cond.broadcast
		end
		@workers.each do |worker|
			worker.join
		end
	end
	
	def create_gallery_page(images)
		puts "WRITE      index.html"
		template = nil
		File.open(TEMPLATE_FILE, "r") do |f|
			template = ERB.new(f.read)
		end
		File.open("index.html", "w") do |f|
			f.write(template.result(binding))
		end
	end
end
end # module Mikuru
