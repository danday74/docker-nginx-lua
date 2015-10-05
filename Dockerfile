# Based on manual compile instructions at http://wiki.nginx.org/HttpLuaModule#Installation
FROM ubuntu:14.04

ENV VER_NGINX_DEVEL_KIT=0.2.19
ENV VER_LUA_NGINX_MODULE=0.9.16
ENV VER_NGINX=1.9.5
ENV VER_LUAJIT=2.0.4

ENV NGINX_DEVEL_KIT ngx_devel_kit-${VER_NGINX_DEVEL_KIT}
ENV LUA_NGINX_MODULE lua-nginx-module-${VER_LUA_NGINX_MODULE}
ENV NGINX_ROOT=/nginx
ENV WEB_DIR ${NGINX_ROOT}/html

ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.0

RUN apt-get -qq update
RUN apt-get -qq -y install wget

# ***** BUILD DEPENDENCIES *****

# Common dependencies (Nginx and LUAJit)
RUN apt-get -qq -y install make git
# Nginx dependencies
RUN apt-get -qq -y install libpcre3
RUN apt-get -qq -y install libpcre3-dev
RUN apt-get -qq -y install zlib1g-dev
RUN apt-get -qq -y install libssl-dev

# LUAJit dependencies
RUN apt-get -qq -y install gcc

# ***** DOWNLOAD AND UNTAR *****

# Download
RUN wget http://nginx.org/download/nginx-${VER_NGINX}.tar.gz
RUN wget http://luajit.org/download/LuaJIT-${VER_LUAJIT}.tar.gz
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v${VER_NGINX_DEVEL_KIT}.tar.gz -O ${NGINX_DEVEL_KIT}.tar.gz
RUN wget https://github.com/openresty/lua-nginx-module/archive/v${VER_LUA_NGINX_MODULE}.tar.gz -O ${LUA_NGINX_MODULE}.tar.gz
RUN wget https://github.com/openresty/memc-nginx-module/archive/v0.16.tar.gz -O memc-nginx-module.tar.gz
RUN wget https://github.com/openresty/headers-more-nginx-module/archive/v0.261.tar.gz -O headers-more-nginx-module.tar.gz
RUN wget https://github.com/aperezdc/ngx-fancyindex/archive/v0.3.5.tar.gz -O ngx-fancyindex.tar.gz
RUN wget https://github.com/openresty/echo-nginx-module/archive/v0.58.tar.gz -O echo-nginx-module.tar.gz
RUN wget https://github.com/openresty/set-misc-nginx-module/archive/v0.29.tar.gz -O set-misc-nginx-module.tar.gz

# Untar
RUN tar -xzvf nginx-${VER_NGINX}.tar.gz && rm nginx-${VER_NGINX}.tar.gz
RUN tar -xzvf LuaJIT-${VER_LUAJIT}.tar.gz && rm LuaJIT-${VER_LUAJIT}.tar.gz
RUN tar -xzvf ${NGINX_DEVEL_KIT}.tar.gz && rm ${NGINX_DEVEL_KIT}.tar.gz
RUN tar -xzvf ${LUA_NGINX_MODULE}.tar.gz && rm ${LUA_NGINX_MODULE}.tar.gz
RUN mkdir memc-nginx-module && tar -xzvf memc-nginx-module.tar.gz --strip-components=1 -C memc-nginx-module
RUN mkdir headers-more-nginx-module && tar -xzvf headers-more-nginx-module.tar.gz --strip-components=1 -C headers-more-nginx-module
RUN mkdir ngx-fancyindex && tar -xzvf ngx-fancyindex.tar.gz --strip-components=1 -C ngx-fancyindex
RUN mkdir echo-nginx-module && tar -xzvf echo-nginx-module.tar.gz --strip-components=1 -C echo-nginx-module
RUN mkdir set-misc-nginx-module && tar -xzvf set-misc-nginx-module.tar.gz --strip-components=1 -C set-misc-nginx-module
RUN git clone https://github.com/kainswor/nginx_md5_filter.git

# ***** BUILD FROM SOURCE *****

# LuaJIT
WORKDIR /LuaJIT-${VER_LUAJIT}
RUN make
RUN make install
# Nginx with LuaJIT
WORKDIR /nginx-${VER_NGINX}

RUN ./configure --prefix=${NGINX_ROOT} \
                --with-ld-opt="-Wl,-rpath,${LUAJIT_LIB}" \
                --with-cc-opt="-DNGX_LUA_USE_ASSERT -DNGX_LUA_ABORT_AT_PANIC" \
                --with-pcre-jit \
                --add-module=/${NGINX_DEVEL_KIT} \
                --add-module=/${LUA_NGINX_MODULE} \
                --with-ipv6 \
                --with-http_ssl_module \
                --with-http_v2_module \
                --with-http_realip_module \
                --with-http_gunzip_module \
                --with-http_gzip_static_module \
                --with-http_auth_request_module \
                --add-module=../memc-nginx-module \
                --add-module=../headers-more-nginx-module \
                --add-module=../ngx-fancyindex \
                --add-module=../echo-nginx-module \
                --add-module=../set-misc-nginx-module \
                --add-module=../nginx_md5_filter \
                --without-mail_pop3_module \
                --without-mail_pop3_module \
                --without-mail_imap_module \
                --without-mail_smtp_module

RUN    make -j2 \
    && make install \
    && ln -s ${NGINX_ROOT}/sbin/nginx /usr/local/sbin/nginx
