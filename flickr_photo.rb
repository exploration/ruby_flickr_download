#+-------------------------------------------+
#| EXPLO Photo ID Downloader                 |
#| flickr_photo.rb                           |
#| Author: Donald Merand                     |
#+-------------------------------------------+
#| Downloads image files from a              |
#| Flickr account, and stores them in an     |
#| images/ directory                         |
#+-------------------------------------------+
#| REQUIREMENTS:                             |
#| The flickraw and json gems, which you can |
#| Install using `gem install flickraw` and  |
#| `gem install json`                        |
#| see README for details                    |
#+-------------------------------------------+

require 'rubygems'
require 'flickraw'
require 'yaml'


# Load up configuration options
config_file = "config.yaml"
errors = []

if File.exists?(config_file)
  config = YAML::load_file(config_file)
  errors.push "No Flickr API key defined" if config['api_key'].nil?
  errors.push "No Flickr shared secret defined" if config['shared_secret'].nil?
else
  errors.push "No config.yaml found."
end

# Exit if there were blocking errors (no API key info)
unless errors.empty?
  puts "Errors:\n#{errors.join("\n")}"
  exit 1
end


# Identifying information for the program itself
FlickRaw.api_key = config['api_key']
FlickRaw.shared_secret = config['shared_secret']

# User token access for Flickr
if config['access_token'].nil?
  token = flickr.get_request_token
  auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')

  puts "Open this url in your process to complete the authentication process : #{auth_url}"
  puts "Copy here the number given when you complete the process."
  verify = gets.strip

  begin
    flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
    login = flickr.test.login
    puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"

    # Append received tokens to config file
    config_write = File.open(config_file, "a")
    config_write.puts "#local user access keys (auto-generated)"
    config_write.puts "access_token: #{flickr.access_token}"
    config_write.puts "access_secret: #{flickr.access_secret}"
    config_write.close
  rescue FlickRaw::FailedResponse => e
    puts "Authentication failed : #{e.msg}"
    exit 1
  end
else
  flickr.access_token = config['access_token']
  flickr.access_secret = config['access_secret']

  login = flickr.test.login
  puts "You are now authenticated as #{login.username}"
end


#From here you are logged in:


#now we can set up the downloading of files
downloaded_images = Hash.new
image_folder = "images"
cache_file = "cache.txt"
count = 0
#summer_start_date = "#{Time.now.year - 1}-06-01 00:00:00"
                                    # ^^^ LAST YEAR
summer_start_date = "#{Time.now.year}-05-01 00:00:00"



# First we ensure the images directory exists
Dir.mkdir(image_folder) unless File.directory?(image_folder)

# We're iterating through the image cache file to store already-downloaded
# images. We won't re-download if they've already been downloaded.
if File.exists?(cache_file)
  cache_file = File.open(cache_file, "r+")
  cache_file.each do |line|
    #the image file is everything before the first tab
    image_file = /^(.*)\t/.match(line)[1]
    #the id is everything after the first tab
    id = /^.*\t(.*)/.match(line)[1]
    #we'll refer to this later to check whether we should download
    downloaded_images[id] = image_file
    #puts "Cache ID: #{id}"
  end
else
  cache_file = File.new(cache_file, "w+")
end



# Get the 500 most recent photos (500 is the Flickr API max)
# (at some point we should make looping through all photos an option)
list = flickr.people.getPhotos  :user_id => "me",
                                :per_page => 500,
# You can enter a page if for some reason you want to download the full archive
                                #:page => 3,
                                :min_upload_date => summer_start_date

# Now iterate through the list received from Flickr and actually get the photos
list.each do |item|
  id = item.id
  # Check to see if we haven't already downloaded the file  
  unless downloaded_images.has_key?(id)
    secret = item.secret
    title  = item.title
    info   = flickr.photos.getInfo :photo_id => id, :secret => secret

    # Show the contents of the "info" object
    # Puts info.inspect()

    # Get the medium-sized image URL for the db
    image_url = FlickRaw.url_z(info)
    # Get the image extension
    image_extension = image_url.sub(/.*\./, ".")
    # This is the name of the image to be saved
    save_image = "#{id}__#{title}#{image_extension}".gsub(/'/, " ")

    # Write info to the cache file so we don't re-download
    cache_file.puts("#{save_image}\t#{id}")

    # Now actually download the file
    fork {
      # -L means "follow redirects"
      # -o means "download to file instead STDOUT"
      exec("curl -L -o '#{image_folder}/#{save_image}' #{image_url}")
    }

    count += 1
  end
end

# Wait for all mah curls to finish
Process.waitall

cache_file.close
puts "#{count} images downloaded."
