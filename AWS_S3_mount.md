# AWS S3 mount 하기

*AWS 에서는 S3와 인스턴스간 mount 기능을 정식적으로 지원하지 않음. 그렇기 때문에 오픈소스를 사용하여 인스턴스와 S3 저장소를 연결하여야 한다. 이 문서는 S3 저장소와 인스턴스간 연결할 수 있는 2개의 오픈소스 설치 방법과 사용방법을 소개하고 있다.*



## 1. s3fs

*s3fs는 AWS와 S3 마운트 오픈소스 중 가장 많은 사람이 쓰는 오픈소스이다. 하지만 속도가 매우 느린 단점을 가지고 있다.*

### 1) 설치 전 준비

- AWS user access / secret Key (Amazon S3 Full Access 적용)
- S3 bucket
- 연결할 instance

### 2) s3fs 설치

- git에서 내려받은 후 autogen 실행

```
$ git clone https://github.com/s3fs-fuse/s3fs-fuse.git
$ cd s3fs-fuse/
$ ./autogen.sh

--- Make commit hash file -------
--- Finished commit hash file ---
--- Start autotools -------------
configure.ac:26: installing './config.guess'
configure.ac:26: installing './config.sub'
configure.ac:27: installing './install-sh'
configure.ac:27: installing './missing'
src/Makefile.am: installing './depcomp'
parallel-tests: installing './test-driver'
--- Finished autotools ----------
```

- configure 실행

```
$ ./configure
checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking target system type... x86_64-unknown-linux-gnu
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking for g++... g++
...
```

- make install 실행

```
$ make
make  all-recursive
make[1]: Entering directory `/home/ec2-user/s3fs-fuse'
Making all in src
make[2]: Entering directory `/home/ec2-user/s3fs-fuse/src'
g++ -DHAVE_CONFIG_H -I. -I..  -D_FILE_OFFSET_BITS=64 -I/usr/include/fuse -I/usr/include/libxml2      -g -O2 -Wall -D_FILE_OFFSET_BITS=64 -MT s3fs.o -MD -MP -MF .deps/s3fs.Tpo -c -o s3fs.o s3fs.cpp
mv -f .deps/s3fs.Tpo .deps/s3fs.Po
g++ -DHAVE_CONFIG_H -I. -I..  -D_FILE_OFFSET_BITS=64 -I/usr/include/fuse -I/usr/include/libxml2      -g -O2 -Wall -D_FILE_OFFSET_BITS=64 -MT curl.o -MD -MP -MF .deps/curl.Tpo -c -o curl.o curl.cpp
mv -f .deps/curl.Tpo .deps/curl.Po
g++ -DHAVE_CONFIG_H -I. -I..  -D_FILE_OFFSET_BITS=64 -I/usr/include/fuse -I/usr/include/libxml2      -g -O2 -Wall -D_FILE_OFFSET_BITS=64 -MT cache.o -MD -MP -MF .deps/cache.Tpo -c -o cache.o cache.cpp
mv -f .deps/cache.Tpo .deps/cache.Po
g++ -DHAVE_CONFIG_H -I. -I..  -D_FILE_OFFSET_BITS=64 -I/usr/include/fuse -I/usr/include/libxml2      -g -O2 -Wall -D_FILE_OFFSET_BITS=64 -MT string_util.o -MD -MP -MF .deps/string_util.Tpo -c -o string_util.o string_util.cpp
mv -f .deps/string_util.Tpo .deps/string_util.Po
...
```

### 3) s3fs 설정

- AWS user access Key / secret Key를 설정

```
$ echo 'AWS access Key':'AWS secret Key' > /etc/passwd-s3fs
$ sudo chmod 600 /etc/passwd-s3fs
```

- mount 설정

```
$ mkdir -p /mount
$ /usr/local/bin/s3fs 'S3 name' /mount
```

- mount 설정 확인

```
$ df -h

Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1      7.8G  1.2G  6.6G  15% /
devtmpfs        490M   60K  490M   1% /dev
tmpfs           498M     0  498M   0% /dev/shm
s3fs            256T     0  256T   0% /mount
```



## 2. goofys

*goofys는 앞서 소개한 s3fs보다 속도가 잘나온다고 주장하는 오픈소스.*

### 1) 설치 전 준비

- AWS user access / secret Key (Amazon S3 Full Access 적용)
- S3 bucket
- 연결할 instance

### 2) goofys 설치

- golang 설치

```
$ mkdir local
$ wget https://storage.googleapis.com/golang/go$VERSION.$OS-$ARCH.tar.gz
$ tar -C /home/git/local -xzf go$VERSION.$OS-$ARCH.tar.gz

$ echo 'export GOROOT=$HOME/local/go' >> $HOME/.bashrc
$ echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
$ echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> $HOME/.bashrc
$ source $HOME/.bashrc

$ go version
go version go1.11.2 linux/amd64
```

- go get , install goofys

```
$ go get github.com/kahing/goofys
$ go install github.com/kahing/goofys
```

- S3 access key 설정

```
$ mkdir -p ~/.aws
$ vi ~/.aws/credentials
```

```
# ~/.aws/credentials

[default]
aws_access_key_id = XXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

- mount 실행

```
$ mkdir -p /goofys
$ goofys 'S3 name' /goofys
```

- mount 확인

```
$ df -h

Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1      7.8G  1.6G  6.1G  21% /
devtmpfs        490M   60K  490M   1% /dev
tmpfs           498M     0  498M   0% /dev/shm
goofys          1.0P     0  1.0P   0% /goofys
```

