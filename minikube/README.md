# Kubernetes local - Minikube

*MiniKube는 Kubernetes를 로컬에서 쉽게 실행 할 수 있게 해주는 도구로서, Kubernetes를 테스트, 로컬 VM 내부에서 단일 노드 Kubernetes 클러스터를 실행할 수 있음.  이 문서는 Minikube를 설치 하는 절차에서 부터 사용 절차까지 작성.*

## Specification

- OS : Ubuntu:18.04 Bionic Beaver
- virtualBox version : 5.1.38 r122592



## Install virtualBox

### 1) Ubuntu 16.04 Xenial Xerus 

```Ubun
$ sudo apt remove virtualbox virtualbox-5.0 virtualbox-4.*
$ sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" >> /etc/apt/sources.list.d/virtualbox.list'
$ wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
$ sudo apt update
$ sudo apt install virtualbox-5.1
```

### 2) Ubuntu 18.04 Bionic Beaver

```Ubun
$ wget https://download.virtualbox.org/virtualbox/5.1.38/virtualbox-5.1_5.1.38-122592~Ubuntu~bionic_amd64.deb
$ sudo dpkg -i virtualbox-5.1_*.deb
```



## Install kubectl or with snap on Ubuntu

### 1) kubectl

```Ubun
$ sudo apt-get update && sudo apt-get install -y apt-transport-https
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
$ echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
$ sudo apt-get update
$ sudo apt-get install -y kubectl
```

### 2) snap on Ubuntu

```Ubuntu
$ sudo snap install kubectl --classic
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1.13.1", GitCommit:"eec55b9ba98609a46fee712359c7b5b365bdd920", GitTreeState:"clean", BuildDate:"2018-12-13T10:39:04Z", GoVersion:"go1.11.2", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```



## Install Minikube

```Ubun
$ mkdir -p ~/workspace/minikube/
$ cd ~/workspace/minikube/
$ wget https://github.com/kubernetes/minikube/releases/download/v0.31.0/minikube_0.31-0.deb
$ sudo dpkg -i minikube_*.deb
```



## Start Minikube

### Quick start

```Ubun
$ minikube start
Starting local Kubernetes v1.10.0 cluster...
Starting VM...
Downloading Minikube ISO
 178.87 MB / 178.87 MB [============================================] 100.00% 0s
Getting VM IP address...
E1218 09:01:14.491740    6157 start.go:210] Error parsing version semver:  Version string empty
Moving files into cluster...
Downloading kubeadm v1.10.0
Downloading kubelet v1.10.0
Finished Downloading kubelet v1.10.0
Finished Downloading kubeadm v1.10.0
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Stopping extra container runtimes...
Starting cluster components...
Verifying kubelet health ...
Verifying apiserver health ...Kubectl is now configured to use the cluster.
Loading cached images from config file.


Everything looks great. Please enjoy minikube!

# minikube vm 생성 후 시작

$ minikube dashboard
Opening http://127.0.0.1:46217/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ in your default browser...
Opening in existing browser session.

# minikube dashboard 실행 -> 자동으로 웹 페이지 실행
```



## Deploy Application in Kubernetes 

### Kubernetes Deploy Application - 1

```
$ kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.10 --port=8080
deployment.apps/hello-minikube created

# k8s.gcr.io/echoserver:1.10 이미지를 포트 8080에 hello-minikube 라는 이름으로 pod 정의

$ kubectl expose deployment hello-minikube --type=NodePort
service/hello-minikube exposed

# 배포한 hello-minikube를 service로 등록

$ kubectl get service
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP      10.96.0.1     <none>        443/TCP          1h
my-service   LoadBalancer   10.96.76.73   <pending>     8080:30160/TCP   1h

# 현재 떠 있는 서비스 목록을 확인

$ minikube service list
|-------------|----------------------|-----------------------------|
|  NAMESPACE  |         NAME         |             URL             |
|-------------|----------------------|-----------------------------|
| default     | kubernetes           | No node port                |
| default     | my-service           | http://192.168.99.100:30160 |
| kube-system | kube-dns             | No node port                |
| kube-system | kubernetes-dashboard | No node port                |
|-------------|----------------------|-----------------------------|

# Minikube로 서비스 리스트 확인 시
# Minikube 서비스 리스트에서 URL 을 입력 하면 현재 실행 되어 있는 서비스를 확인 할 수 있다.
```



### Kubernetes Deploy Application - 2

1) pod 정의 yaml

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: myshell
  labels:
    name: myshell
spec:
  replicas: 3
  selector:
    name: myshell
  template:
    metadata:
      labels:
        name: myshell
    spec:
      containers:
      - name: myshell
        image: jonbaier/node-express-info:latest
        ports:
        - containerPort: 8080
```

- apiVersion : 단순히 사용하는 스키마 버전을 kubernetes 에게 알려준다.
- kind : 만들려는 리소스의 타입을 kubernetes에게 알려준다. 
- metadata : 리소스 이름 부여 하는 곳이며, 주어진 작업에 리소스를 검색하고 선택하기 위해 사용 할 수 있는 레이블을 지정하는 곳이다. 
- spec : 생성하려는 리소스의 종류나 타입에 따라 다양하다. 현재 이 yaml에 적용 되어 있는 ReplicationController인 경우에는 원하는 수의 파드가 실행되는 것을 보장된다.



2) service 정의 yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myshell
  labels:
    name: myshell
spec:
  type: LoadBalancer
  ports:
  - port: 8080
  selector:
    name: myshell
```

- 여기서는 서비스 타입, 리스닝 포트, 셀렉터를 정의하며, 이는 어떤 pod가 이 서비스에 응답 할 수 있는지 서비스 프록시에게 알려주는 역할을 한다. 이 서비스를 통해 사용자가 배포한 애플리케이션을 확인 할 수 있는 것이다.



3) seccomp 적용 yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myshell
  annotations:
    container.seccomp.security.alpha.kubernetes.io/myshell: localhost/profile.json
spec:
  containers:
    - name: myshell
      image: cloudfoundry/test-app:latest
      ports:
        - containerPort: 8080
```

- custom seccomp를 적용한 pod 선언 yaml 파일이다. 

- metadata의 annotations을 통해 선언 하였다.

- container.seccomp.security.alpha.kubernetes.io/( container-name ) :  localhost/profile.json

  이는 seccomp를 적용할 컨테이너 이름을 기재 후 localhost는 노드, profile.json은 profile를 뜻하고 있다.

  minikube의 기본 위치는 /var/lib/kubelet/seccomp 폴더 안이며, 이 안에 위치한 profile를 읽어 올라간다.


4) yaml로 정의 된 애플리케이션 배포하기

```Ubuntu
$ kubectl create -f myapp.yml
pod/myshell created

$ kubectl create -f myapp-service.yml
service/myshell created
```



## ETC

```Ubutn
$ minikube ssh 
# minikube node ssh 접속 방법

$ minikube ssh
$ sudo journalctl -u kubelet -f
# pod 배포 및 service 배포 시 kubelet log 확인 방법

$ kubectl get pods
# 현재 deploy 된 pod list 확인

$ kubectl get service 
# 현재 실행 중인 service list 확인

$ kubectl describe pod/myshell
# 해당 pod의 세부 정보를 확인
```



