# docker-nginx-lua

Dockerised Nginx with Lua module built from source - see http://wiki.nginx.org/HttpLuaModule#Installation

Useful for those who want Nginx with Lua but don't want to use OpenResty

# Automated

This repo is watched by a docker automated build that builds the docker image <b>danday74/nginx-lua</b>

# USAGE

(1) Create your own dockerfile ...

FROM: danday74/nginx-lua
COPY: /your/nginx.conf /nginx/conf/nginx.conf

(2) Add this location block to your nginx.conf file

location /hellolua {
  content_by_lua '
    ngx.header["Content-Type"] = "text/plain";
    ngx.say("hello world");
  ';
}

INFO: If you don't have an nginx.conf file then use the one in this repo

(3) Build your docker image
(4) Run your docker container
(5) Visit http://your-docker-container/hellolua
