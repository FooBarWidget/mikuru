Introduction
============

Mikuru is an extremely simple and easy to use static image gallery generator. Features:

* Generates static HTML and image files.
* Easy to use and easy to set up.
* No dependencies on PHP, databases or other dynamic software.
* The generated gallery has a simple, to the point, quick and easy to user interface.

I wrote after once having taken several hundred pictures and not feeling like setting up a full blown gallery system such as Gallery.

Installation
------------
Run the following command:

    gem install FooBarWidget-mikuru -s http://gems.github.com

Mikuru requires RMagick.

How does it work?
-----------------
You put a bunch of pictures in a folder, run Mikuru, and it'll generate an 'index.html' as well as a set of thumbnails. There are no other generated files. Simply upload index.html, the thumbnails and the pictures to a web server, and you're ready to go.

Here’s an example usage session:

    $ ls
    DSCN001.JPG   DSCN002.JPG   DSCN003.JPG
    DSCN004.JPG   DSCN005.JPG   DSCN006.JPG
    $ mikuru
    MKDIR      thumbnails
    WRITE      thumbnails/DSCN001.JPG
    WRITE      thumbnails/DSCN002.JPG
    WRITE      thumbnails/DSCN003.JPG
    WRITE      thumbnails/DSCN004.JPG
    WRITE      thumbnails/DSCN005.JPG
    WRITE      thumbnails/DSCN006.JPG
    WRITE      index.html
    $ scp -r * www.somehost.com:public_html/my_gallery/
