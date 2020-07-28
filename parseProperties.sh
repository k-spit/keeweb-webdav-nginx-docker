#/bin/sh

file="./keeweb.properties"

if [ -f "$file" ]
then
#  echo "$file found."

  while IFS='=' read -r key value
  do
    key=$(echo $key | tr '.' '_')
    eval ${key}=\${value}
  done < "$file"

  echo ${path}
  echo ${keystore}
  echo ${nginx_conf}
  echo ${server_name}
  echo ${ssl_certificate}
  echo ${ssl_certificate_key}
  echo ${nginx_root}
  echo ${auth_basic_user_file}
  echo ${htpasswd_user}
  echo ${htpasswd_password}
else
  echo "$file not found."
fi