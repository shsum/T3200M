# T3200M

This repo is a mirror of https://opensource.actiontec.com/sourcecode/t3200x/bcm963xx_31.164l.10_gpl_consumer_release.tar.gz

You will need 32bit libs if you are running on a 64bit system for example glibc.i686.

You will need to create a symlink in /opt dir pointing to where bcm963xx_router & toolchains is located.

/opt/bcm963xx_router -> /media/compile/next/bcm963xx_router/
/opt/toolchains -> /media/compile/next/toolchains/


cd /media/compile/next/bcm963xx_router/
make --trace PROFILE=963138BGW | tee mkOut


