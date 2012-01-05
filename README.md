Kohana projects starter
=======================

Small bash script which setts the enviroment for Kohana projects.
This script is based on dialog (http://en.wikipedia.org/wiki/Dialog_(software)) so you have nice GUI under terminal.

Assumptions
-----------

* dialog program installed
* `/dev/urandom` available for current user 
* wildcard vhost configured on your dev
* one directory shema, like `/home/USER/www/PROJECTNAME/`
* prepared Kohana sources (tar.gz)
* database root password

Apache vhost configuration
--------------------------

Tip: VirtualDocumentRoot makes vhosts available for all users 

	<VirtualHost *:80>
    	UseCanonicalName off
    	ServerName dev
    	ServerAlias *.*.dev
    	VirtualDocumentRoot /home/%2/www/%1/public_html/
    	<DirectoryMatch />
        	#ble ble
    	</DirectoryMatch>
	</Virtualhost>
 
Kohana tar.gz structure
-----------------------

It is possible to prepare several different configurations. All should have the same structure:

`S_KOHANA_VER="3.2"`

	3.2.tar.gz
		/3.2
			/application
			/modules
			/public_html
			/system
 
`S_KOHANA_VER="3.0.9"`
	
	3.0.9.tar.gz
		/3.0.9
			/application
			/modules
			/public_html
			/system
			
Functionality
=============

* create directory structure
* copy Kohana framework files
* create database
* create database user and grant all premissions to database
* create database.php config file for Kohana

Configuration
=============

Configuration possibility is small, but there is some:

* start directory
* kohana version
* kohana tar link (according to version)
* database credentials (login, password, port)

For change simply edit `newproject.sh`

Usage
=====
Add execute chmod, and start:

	chmod +x newproject.sh
	./newproject.sh

Options screens
---------------

While using script you have some options to choose from:

* project name (be carefull, it will become also dir name, database name, database user name)
* choose options to fire ( Create directories, Create database, Copy Kohana files, Create database config)
* if options are correct you can start script
* current progress is visible on screen
* after all, database user random generated password is shown

Screenshots
===========

![Step1](http://img855.imageshack.us/img855/8290/step1c.jpg "Kohana projects starter | step 1")
![Step2](http://img820.imageshack.us/img820/3184/step2a.jpg "Kohana projects starter | step 2")
![Step3](http://img69.imageshack.us/img69/6803/step3s.jpg "Kohana projects starter | step 3")
![Step4](http://img805.imageshack.us/img805/4725/step4l.jpg "Kohana projects starter | step 4")
![Step5](http://img85.imageshack.us/img85/7507/step5w.jpg "Kohana projects starter | step 5")
![Step6](http://img338.imageshack.us/img338/4338/step6ad.jpg "Kohana projects starter | step 6")
