#!/bin/bash

# Friendly reminder:
# If you change this file *after* having run `make`, they will most likely
# won't be taken into account.

set -e

. ./env

cd /

if [[ -z ${VER_NGINX} ]]; then
  echo "cannot run script without importing verions"
  exit 1
fi

echo "About to package as .deb both NGINX and Lua JIT"

fpm -s dir -t deb -n nginx-core -v ${VER_NGINX} \
        --replaces nginx-core \
        -m "$MAINTAINER" \
        --vendor "$MAINTAINER" \
        --description 'Custom build of NGINX with FancyIndex, HTTP/2.0 and LuaJIT' \
        $NGINX_ROOT

fpm -s dir -t deb -n libluajit -v ${VER_LUAJIT} \
       --replaces libluajit \
       /usr/local/bin/luajit \
       /usr/local/bin/luajit-2.0.4 \
       /usr/local/lib/lua \
       /usr/local/include/luajit-2.0 \
       /usr/local/share/man/man1/luajit.1 \
       /usr/local/lib/pkgconfig/luajit.pc \
       /usr/local/share/luajit-2.0.4/ \
       /usr/local/share/lua \
       /usr/local/lib/libluajit-5.1.a \
       /usr/local/lib/libluajit-5.1.so \
       /usr/local/lib/libluajit-5.1.so.2 \
       /usr/local/lib/libluajit-5.1.so.2.0.4

mv *.deb pkg/

