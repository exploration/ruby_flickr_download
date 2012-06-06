Flickr Downloader
=================
When students show up at Explo, we take their photo ID and upload it to a private account at Flickr. We do this so that we can take student photos from any kind of device with a camera and internet connection, and have one central place where all the photos are stored.

At some point, usually moments after we take the photo, we want to download it from Flickr into our student Photo ID database so that we can print the photo ID (from some computer in the back-office) and give it to the student later in the day.

We wrote this utility to solve that need. You set it up with an API key and a shared secret, and it'll download your images into an `images/` folder.



Features
--------
- Download photos from Flickr very quickly and in large batches
- Keeps a `cache.txt` file so that it never downloads an image twice
- Uses `fork` for pretty darned fast download speeds (on UNIXey systems anyhow)



Dependencies
------------
- The [JSON](http://flori.github.com/json/) gem - `gem install json`.
- The [FlickRaw](https://github.com/hanklords/flickraw) gem - `gem install flickraw`



Usage
-----
The image download is performed from the command line. Assuming you installed
the source files in `/usr/phil/flickrPhoto/`

1. Edit the `config.yaml` file to include your [Flickr API Key](http://www.flickr.com/services/api/keys/) and shared secret.
2. Open up [your favorite terminal application](http://www.iterm2.com/)
3. Type `cd /usr/phil/flickrPhoto`
4. Type `ruby flickr_photo.rb`
  - The first time you run the script, you'll be asked to go to a Flickr URL to allow program access. Follow the steps on the screen and your `config.yaml` will be updated with the necessary API tokens so you don't get asked again.
  - (you'll see some messages about how many files are downloaded...)
  - (you'll feel bliss)

Now you've downloaded the photos from Flickr to your computer. You should see an
`images` directory in the `flickrPhoto` directory. Check inside to see what's
in there. You should see a bunch of medium-sized photo files. That is all.



Notes and Caveats
-----------------
We wrote this to solve a very specific need, and are releasing it into the wild because we think others may have similar needs. You'll probably need to modify it slightly to make it work for you.

The script is tested only on OS X 10.7 / Ruby 1.8.7 - your mileage may vary on other systems.

The default file format we use for download is `FlickrID_PhotoTItle.jpg`. Obviously change that if you want the files named something else.

For our purposes, we're using the `:min_upload_date` feature to only download photos that were taken in the summer of the current year.



License
-------
[MIT License](http://www.opensource.org/licenses/MIT)
