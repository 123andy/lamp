redcap-docker
=================

A customized LAMP docker image for use with REDCap (https://projectredcap.org).  

This image does not include the REDCap source files which should be obtained from the consortium community page (https://community.projectredcap.org)

Usage
-----

To create a `123andy/redcap-docker` image on your local machine, install docker and then execute the following command while in the redcap-docker folder:

	docker build -t 123andy/redcap-docker .


Running your REDCap instance easier
-----------------------------------
If you just want to run redcap, then it is recommended you don't mess with this docker image and instead us the docker-composer
version that wraps this process is availabe here:  

https://github.com/123andy/redcap-docker-compose


Running your LAMP docker image
------------------------------

I'm first running a mailhog server to handle email as:

    docker run -d -p 81:8025 --name=mailhog mailhog/mailhog

Next, I fire up the redcap lamp server    

	docker run --name=redcap \
	    --link mailhog:mailhog \
	    -v /Users/andy123/Documents/Docker/redcap_www:/redcap_webroot \
	    -v /Users/andy123/Documents/Docker/redcap_mysql:/var/lib/mysql \
	    -v /Users/andy123/Documents/Docker/redcap_log:/var/log/export \
	    --rm \
	    -p 3306:3306 \
	    -p 80:80 \
	    andy123/redcap-docker

Test your deployment:

	http://localhost/


Connecting to the bundled MySQL server from within the container
----------------------------------------------------------------

The bundled MySQL server has a `root` user with no password for local connections.
Simply connect from your PHP code with this user:

	<?php
	$mysql = new mysqli("localhost", "root");
	echo "MySQL Server info: ".$mysql->host_info;
	?>


Connecting to the bundled MySQL server from outside the container
-----------------------------------------------------------------

The first time that you run your container, a new user `admin` with all privileges
will be created in MySQL with a password of `redcap`.  You can also see this by viewing
the docker logs by running:

	docker logs $CONTAINER_ID

You will see an output like the following:

	========================================================================
	You can now connect to this MySQL Server using:

	    mysql -uadmin -predcap -h<host> -P<port>

	Please remember to change the above password as soon as possible!
	MySQL user 'root' has no password but only allows local connections
	========================================================================

In this case, `redcap` is the password allocated to the `admin` user.

You can then connect to MySQL:

	 mysql -uadmin -predcap

Remember that the `root` user does not allow connections from outside the container -
you should use this `admin` user instead!


Setting a specific password for the MySQL server admin account
--------------------------------------------------------------

If you want to use a preset password instead of a random generated one, you can
set the environment variable `MYSQL_PASS` to your specific password when running the container:

	docker run -d -p 80:80 -p 3306:3306 -e MYSQL_PASS="mypass" 123andy/redcap-docker

You can now test your new admin password:

	mysql -uadmin -p"mypass"


Disabling .htaccess
--------------------

`.htaccess` is enabled by default. To disable `.htaccess`, you can remove the following contents from `Dockerfile`

	# config to enable .htaccess
    ADD apache_default /etc/apache2/sites-available/000-default.conf
    RUN a2enmod rewrite


**originally by http://www.tutum.co and modified by 123andy**