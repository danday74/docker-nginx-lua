nginx-lua
=========

![Docker stars](https://img.shields.io/docker/stars/danday74/nginx-lua.png "Docker stars")
&nbsp;
![Docker pulls](https://img.shields.io/docker/pulls/danday74/nginx-lua.png "Docker pulls")

[![Docker repo](https://github.com/danday74/docker-nginx-lua/blob/master/images/docker.png?raw=true "Docker repo")](https://registry.hub.docker.com/u/danday74/nginx-lua)
&nbsp;
[![Github repo](https://github.com/danday74/docker-nginx-lua/blob/master/images/github.png?raw=true "Github repo")](https://github.com/danday74/docker-nginx-lua)

Dockerised Nginx, with Lua module, built from source

The docker image is based on the manual compilation instructions at ...

[http://wiki.nginx.org/HttpLuaModule#Installation](http://wiki.nginx.org/HttpLuaModule#Installation)

Useful for those who want Nginx with Lua but don't want to use OpenResty

Usage
-----

1. Create your own **Dockerfile** ...

    ```
    FROM danday74/nginx-lua
    COPY /your/nginx.conf /nginx/conf/nginx.conf
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

    If you don't have an **nginx.conf** file then use [the conf file](https://raw.githubusercontent.com/danday74/docker-nginx-lua/master/nginx.conf) provided in the github repo
    
    The conf file provided is the default generated conf file with the above location block added

3. Build your docker image

4. Run your docker container - Remember to use **-p YOUR_PORT:80** in your docker run statement

5. Visit http://localhost:YOUR_PORT/hellolua

Automated
---------

The master branch on the github repo is watched by an automated docker build

Which builds docker image **danday74/nginx-lua** on push to master

On success, the docker build triggers the docker repo's webhooks (if any)

License
-------

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)
