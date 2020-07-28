keeweb-webdav-nginx-docker
===

# Preparation  
## Create [`keeweb.properties`](keeweb_example.properties) file

## Supply a valid `.kdbx` file to the root of this project. Name it `keystore.kdbx`. This file will be used as webDAV target.

## Supply valid SSL Cert and SSL Key to a folder called `certs` in the root of this project.

# Usage - Docker
`docker build -t keeweb-test .`  
`docker run --name keeweb-webdav-nginx-docker -p 443:443 -v $PWD/certs:/certs -v $PWD/keystore.kdbx:/var/www/webdav/keystore.kdbx keeweb-test`

## References
http://blog.uorz.me/2019/03/15/keeweb.html