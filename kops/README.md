# Kops Kubernetes Deployment

*kops는 AWS에 클러스터를 쉽게 구축하도록 도와주는 배포 툴로, 공식 가이드에도 kops로 AWS에 클러스터를 생성하는 방법이 소개되어 있다.*

## 1. 설치 선행 단계

### 1) Kops cli install

```ubuntu
$ wget https://github.com/kubernetes/kops/releases/download/1.9.1/kops-linux-amd64
$ chmod +x kops-linux-amd64
$ sudo mv kops-linux-amd64 /usr/local/bin/kops
```

- check kops version

```
$ kops version
Version 1.9.1 (git-ba77c9ca2)
```

### 2) Kubectl cli install

```
$ sudo apt-get update && sudo apt-get install -y apt-transport-https
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
$ echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
$ sudo apt-get update && sudo apt-get install -y kubectl
```

- check kubectl version

```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1 ...
```

### 3) AWS cli install

```
$ sudo apt-get update && sudo apt-get upgrade -y 
$ sudo apt-get install awscli
```

- check awscli version

```
$ aws --version
```



## 2. AWS 준비

### 1) AWS setting

```
$ aws configure

AWS Access Key ID []: Put in your AWS Access Key ID
AWS Secret Access Key []: Put in your AWS Secret Access Key
Default region name []: Put in your Region AZ (ex : ap-northeast-2)
Default output format []: 
```

### 2) AWS S3 bucket 생성

```
$ aws s3api create-bucket --bucket bucketname --region region --create-bucket-configuration LocationConstraint=region

$ export KOPS_STATE_STORE=s3://bucketname
```

- example

```
$ aws s3api create-bucket -bucket donginbucket --region ap-northeast-2 --create-bucket-configuration LocationConstraint=ap-northeast-2

{
    "Location": "http://donginbucket.s3.amazonaws.com/"
}

$ export KOPS_STATE_STORE=s3://donginbucket
```

### 3) AWS 도메인 설정 생성 (Route 53)

```
$ ssh-keygen -f ~/.ssh/id_rsa

$ aws route53 create-hosted-zone --name bucket domain url --caller-reference 3

$ dig NS bucket domain url
```

- example

```
$ ssh-keygen -f ~/.ssh/id_rsa
Generating public/private rsa key pair.
...

$ aws route53 create-hosted-zone --name donginbucket.xxxx.xxxx --caller-reference 3
{
    "HostedZone": {
        "ResourceRecordSetCount": 2,
...

$ dig NS donginbucket.xxxx.xxxx

; <<>> DiG 9.11.3-1ubuntu1.3-Ubuntu <<>> NS donginbucket.xxxx.xxxx
;; global options: +cmd
...

$ export KOPS_STATE_STORE=s3://donginbucket
```



## 3. kops Kubernetes 배포

### 1) Image path 확인

```
$ aws ec2 describe-images --image-id “aws region ubuntu id”
```

- aws region ubuntu id 확인 방법

  AWS EC2 > INSTANCES > Launch Instance

  ![pic-1](pic-1)

  이미지 이름 옆에 ami-xxxxx로 표기 된 것이 각 이미지의 고유 ID

- example

```
$ aws ec2 describe-images --image-id ami-xxxx(ubuntu:16.04)
{
    "Images": [
        {
            "VirtualizationType": "hvm", 
            "Description": "Canonical, Ubuntu, 16.04 LTS, amd64 xenial image build on 2018-09-12", 
            "Hypervisor": "xen", 
            "EnaSupport": true,
		...
		], 
            "Architecture": "x86_64", 
            "ImageLocation": "xxxxxx/ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180912",
...
		
```



### 2) kubernetes 클러스터 생성

```
$ kops create cluster \
--name= bucket domain url \
--master-count= master vm 갯수 \
--master-size= master vm 크기 \
--node-count= woker vm 갯수 \
--node-size= woker vm 크기 \
--zones vm 배포할 region \
--image vm 설치 시 사용될 이미지 ImageLocation \
--dns-zone= bucket domain url \
--yes
```

- example

```
$ kops create cluster \
--name=donginbucket.xxxx.xxxx \
--master-count=1 \
--master-size=t2.medium \
--node-count=2 \
--node-size=t2.medium \
--zones ap-northeast-2 \
--image xxxxxx/ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180912 \
--dns-zone=donginbucket.xxxx.xxxx \
--yes

[I0614 16:33:54. 723231      2947 create_cluster.go:1318] Using SSH public key: /Users/ubuntu/.ssh/id_rsa.pub
...
```



### 3) Kubernetes 클러스터 확인

```
$ kops validate cluster

Using cluster from kubectl context: donginbucket.xxxx.xxxx

Validating cluster donginbucket.xxxx.xxxx

INSTANCE GROUPS
NAME			ROLE	MACHINETYPE	MIN	MAX	SUBNETS
master-ap-northeast-2a	Master	t2.medium	1	1	ap-northeast-2a
nodes			Node	t2.medium	2	2	ap-northeast-2a

...
```



### 4) Kubernetes Dashboard 배포

- kubernetes dashboard 배포 yaml

```yaml
# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ------------------- Dashboard Secret ------------------- #

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-certs
  namespace: kube-system
...
```

- kubernetes dashboard 배포

```
$ kubectl apply -f kubernetes-dashboard.yml
```

- kubernetes 클러스터 정보 확인

```
$ kubectl cluster-info
Kubernetes master is running at https://api-xxxx.ap-xxxx-2.elb.xxxx.com
KubeDNS is running at https://api-xxxx.ap-xxxx-2.elb.xxxx.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```



### 5) Kubernetes Dashboard 접속

- kubernetes dashboard 접근 비밀번호

```
$ kops get secrets kube --type secret -oplaintext
Using cluster from kubectl context: donginbucket.xxxx.xxxx

kubernetes Dashboard 접근 비밀번호
```

- kubernetes dashboard 접근 토큰

```
$ kops get secrets admin --type secret -oplaintext
Using cluster from kubectl context: donginbucket.xxxx.xxxx

kubernetes dashboard 접근 토큰
```

- kubernetes dashboard 접속

```
https://api-xxxx-xxxx.ap-xxxx-2.elb.amazonaws.com/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login
```

```
username : admin
password : kubernetes Dashboard 접근 비밀번호
```

![pic-2](pic-2)

- kubetnetes dashboard 로그인

  Token 선택 > kubernetes dashboard 접근 토큰 입력 > 로그인

![pic-3](pic-3)