#!/bin/bash

# read run config from "run-config.properties"
readarray -t tmp < <(./parseProperties.sh)
echo "${tmp[0]}"    # path
echo "${tmp[1]}"    # keystore
echo "${tmp[2]}"    # nginx_conf
echo "${tmp[3]}"    # server_name
echo "${tmp[4]}"    # ssl_certificate
echo "${tmp[5]}"    # ssl_certificate_key
echo "${tmp[6]}"    # nginx_root
echo "${tmp[7]}"    # auth_basic_user_file
echo "${tmp[8]}"    # htpasswd_user
echo "${tmp[9]}"    # htpasswd_password

path="${tmp[0]}" 
keystore="${tmp[1]}" 
nginx_conf="${tmp[2]}" 
server_name="${tmp[3]}" 
ssl_certificate="${tmp[4]}" 
ssl_certificate_key="${tmp[5]}" 
nginx_root="${tmp[6]}" 
auth_basic_user_file="${tmp[7]}" 
htpasswd_user="${tmp[8]}" 
htpasswd_password="${tmp[9]}" 

sudo apt install apache2-utils -y

rm -rf keeweb

git clone -b gh-pages https://github.com/keeweb/keeweb.git

cat > default_config.json <<EOF
{
	"settings": {
		"theme": "fb",
		"expandGroups": true,
		"listViewWidth": null,
		"menuViewWidth": null,
		"tagsViewHeight": null,
		"autoUpdate": "install",
		"clipboardSeconds": 0,
		"autoSave": true,
		"autoSaveInterval": 1,
		"rememberKeyFiles": "data",
		"idleMinutes": 5,
		"minimizeOnClose": false,
		"tableView": false,
		"colorfulIcons": true,
		"titlebarStyle": "default",
		"lockOnMinimize": true,
		"lockOnCopy": false,
		"lockOnAutoType": false,
		"lockOnOsLock": false,
		"helpTipCopyShown": false,
		"templateHelpShown": false,
		"skipOpenLocalWarn": false,
		"hideEmptyFields": false,
		"skipHttpsWarning": false,
		"demoOpened": false,
		"fontSize": 2,
		"tableViewColumns": null,
		"generatorPresets": null,
		"cacheConfigSettings": false,
		"canOpen": true,
		"canOpenDemo": true,
		"canOpenSettings": true,
		"canCreate": true,
		"canImportXml": true,
		"canRemoveLatest": true,
		"dropbox": false,
		"webdav": true,
		"gdrive": false,
		"onedrive": false
	},
	"files": [
		{
			"storage": "webdav", 
			"name": "$keystore", 
			"path": "$path"
		}
	]
}
EOF

## and then make keeweb use this default configure file
sed -i 's#<meta name="kw-config" content="(no-config)">#<meta name="kw-config" content="default_config.json">#' keeweb/index.html

cp -r webdav keeweb

echo $(htpasswd -nb $htpasswd_user $htpasswd_password) | sed -e s/\\$/\\$\\$/g > htpasswd/htpasswd_private

echo $PWD

cd $nginx_conf

cat > default.conf <<EOF
server {
        listen 443 ssl;
        server_name $server_name;

        ssl_certificate $ssl_certificate;
        ssl_certificate_key $ssl_certificate_key;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA;
        ssl_session_cache shared:SSL:50m;
        ssl_prefer_server_ciphers on;

        root $nginx_root;
        index  index.html index.htm;

        location /dav/ {
                root      /var/www/webdav/;
                client_body_temp_path /var/www/webdav/dav/temp;
                dav_methods     PUT DELETE MKCOL COPY MOVE;
                #dav_ext_methods   PROPFIND OPTIONS;
                create_full_put_path  on;
                dav_access    user:rw group:rw all:rw;
                #autoindex     on;

                ##maybe some access restrictions
                #limit_except GET PROPFIND OPTIONS{
                #  allow 192.168.0.0/16;
                #  deny  all;
                #}
                auth_basic "Restricted Content";
                auth_basic_user_file $auth_basic_user_file;
        }
}
EOF

cd ../../../

docker build -t keeweb-test .
docker run -p 80:80 -p 443:443 -v $PWD/etc/nginx/conf.d:/etc/nginx/conf.d -v $PWD/htpasswd/htpasswd_private:/htpasswd/htpasswd_private -v $PWD/certs:/certs -v $PWD/keystore.kdbx:/var/www/webdav/keystore.kdbx -v $PWD/default_config.json:/var/www/default_config.json keeweb-test