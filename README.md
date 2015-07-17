docker-nginx-lua
================

![Docker pulls](https://img.shields.io/docker/pulls/danday74/nginx-lua.png "Docker pulls")
![Docker stars](https://img.shields.io/docker/stars/danday74/nginx-lua.png "Docker stars")

Dockerised Nginx, with Lua module, built from source

The docker image is based on the manual compilation instructions at ...

http://wiki.nginx.org/HttpLuaModule#Installation

Useful for those who want Nginx with Lua but don't want to use OpenResty

Automated
---------

The master branch on this repo is watched by an automated docker build

Which builds the docker image **danday74/nginx-lua** on a push to master

Usage
-----

1. Create your own Dockerfile ...

    ```
    FROM: danday74/nginx-lua
    COPY: /your/nginx.conf /nginx/conf/nginx.conf
    ```

2. Add this location block to your **nginx.conf** file

    ```
    location /hellolua {
      content_by_lua '
        ngx.header["Content-Type"] = "text/plain";
        ngx.say("hello world");
      ';
    }
    ```

    If you don't have an **nginx.conf** file then use the one provided in the github repo

3. Build your docker image
4. Run your docker container - Remember to use **-p YOUR_PORT:80** in your docker run statement
5. Visit http://your-docker-container:YOUR_PORT/hellolua
