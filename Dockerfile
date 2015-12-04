FROM ubuntu:14.04

WORKDIR /

ADD build.sh /build.sh
ADD pkg.sh /pkg.sh
ADD env /env

RUN mkdir -p /pkg && chmod +x /build.sh /pkg.sh && . ./env && bash ./build.sh
