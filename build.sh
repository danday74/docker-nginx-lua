#!/bin/bash

set -e

# This script can be run to build NGINX and also as a workbench
# to build and package using FPM.
#
# It can also be used to build NGINX with your own lua modules
# See NGINX Lua/LuaJIT bytecode support[1]
#
# [1] <https://www.nginx.com/resources/wiki/modules/lua/#lua-luajit-bytecode-support>
#

if [[ -z ${VER_NGINX} ]]; then
  echo "cannot run script without importing verions"
  exit 1
fi

echo "About to build NGINX ${VER_NGINX} with Lua JIT ${VER_LUAJIT}."

apt-get -qq update
apt-get -qq -y install wget

# ***** BUILD DEPENDENCIES *****

# Common dependencies (Nginx and LUAJit)
apt-get -qq -y install make git

# Nginx dependencies
apt-get -qq -y install libpcre3
apt-get -qq -y install libpcre3-dev
apt-get -qq -y install zlib1g-dev
apt-get -qq -y install libssl-dev

# LUAJit dependencies
apt-get -qq -y install gcc

# ***** DOWNLOAD AND UNTAR *****

# Download main packages
wget http://nginx.org/download/nginx-${VER_NGINX}.tar.gz
wget http://luajit.org/download/LuaJIT-${VER_LUAJIT}.tar.gz

# Download extensions
wget https://github.com/simpl/ngx_devel_kit/archive/v${VER_NGINX_DEVEL_KIT}.tar.gz -O ${NGINX_DEVEL_KIT}.tar.gz
wget https://github.com/openresty/lua-nginx-module/archive/v${VER_LUA_NGINX_MODULE}.tar.gz -O ${LUA_NGINX_MODULE}.tar.gz
wget https://github.com/openresty/memc-nginx-module/archive/v0.16.tar.gz -O memc-nginx-module.tar.gz
wget https://github.com/openresty/headers-more-nginx-module/archive/v0.261.tar.gz -O headers-more-nginx-module.tar.gz
wget https://github.com/aperezdc/ngx-fancyindex/archive/v0.3.5.tar.gz -O ngx-fancyindex.tar.gz
wget https://github.com/openresty/echo-nginx-module/archive/v0.58.tar.gz -O echo-nginx-module.tar.gz
wget https://github.com/openresty/set-misc-nginx-module/archive/v0.29.tar.gz -O set-misc-nginx-module.tar.gz

# Unpack main packages
tar -xzvf nginx-${VER_NGINX}.tar.gz && rm nginx-${VER_NGINX}.tar.gz
tar -xzvf LuaJIT-${VER_LUAJIT}.tar.gz && rm LuaJIT-${VER_LUAJIT}.tar.gz

# Unpack extensions
tar -xzvf ${NGINX_DEVEL_KIT}.tar.gz && rm ${NGINX_DEVEL_KIT}.tar.gz
tar -xzvf ${LUA_NGINX_MODULE}.tar.gz && rm ${LUA_NGINX_MODULE}.tar.gz
mkdir memc-nginx-module && tar -xzvf memc-nginx-module.tar.gz --strip-components=1 -C memc-nginx-module
mkdir headers-more-nginx-module && tar -xzvf headers-more-nginx-module.tar.gz --strip-components=1 -C headers-more-nginx-module
mkdir ngx-fancyindex && tar -xzvf ngx-fancyindex.tar.gz --strip-components=1 -C ngx-fancyindex
mkdir echo-nginx-module && tar -xzvf echo-nginx-module.tar.gz --strip-components=1 -C echo-nginx-module
mkdir set-misc-nginx-module && tar -xzvf set-misc-nginx-module.tar.gz --strip-components=1 -C set-misc-nginx-module
git clone https://github.com/kainswor/nginx_md5_filter.git

# ***** BUILD FROM SOURCE *****

# LuaJIT
cd /LuaJIT-${VER_LUAJIT}
make && make install

# Nginx with LuaJIT
cd /nginx-${VER_NGINX}
./configure --prefix=${NGINX_ROOT} \
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
            --without-mail_smtp_module \
    && make -j2 \
    && make install
