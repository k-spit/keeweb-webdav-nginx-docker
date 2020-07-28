keeweb-webdav-nginx-docker
===

## nginx
Install nginx-full (for webDAV support)

`apt install nginx-full`

## nginx/webDAV configuration (`/etc/nginx/conf.d/default.conf`)
* server_name
* ssl_certificate
* ssl_certificate_key
* root
* /dav - root
* /dav - client_body_temp_path
* auth_basic_user_file

## Keeweb configuration

Switch to nginx root directory  
`cd /var/www`

Clone keeweb
`git clone -b gh-pages https://github.com/keeweb/keeweb.git`

Edit the following parameters in /var/www/keeweb-conf.sh
* files.storage
* files.name
* files.path

Run script:
`./keeweb-conf.sh`

Create Basic Auth Password Hash
`echo $(htpasswd -nb user password) | sed -e s/\\$/\\$\\$/g`

Paste Basic Auth Password Hash of previous step to a file referenced in `auth_basic_user_file`

## Docker

docker build -t keeweb-test 

docker run -p 80:80 -p 443:443 -v $PWD/etc/nginx/conf.d:/etc/nginx/conf.d -v $PWD/htpasswd/htpasswd_private:/htpasswd/htpasswd_private -v $PWD/certs:/certs -v $PWD/keystore.kdbx:/var/www/webdav/keystore.kdbx -v $PWD/default_config.json:/var/www/default_config.json keeweb-test

## References
http://blog.uorz.me/2019/03/15/keeweb.html