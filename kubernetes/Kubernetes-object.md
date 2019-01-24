# Kubernetes Object

Kubernetes를 사용하려면 Kubertnetes API Object로 Cluster에 대해 사용자가 바라는 상태를 기술해야 한다.

*어떤 어플리케이션이나 워크로드를 실행시키려 하는지, 어떤 컨테이너 이미지를 쓰는 지, 어떤 자원을 얼마만큼 쓸 수 있는지 등을 의미한다.*

Kubernetes를 사용하기 위한 중요한 동작 방식에 대해서 설명하고 있다.



## 1. What is Kubernetes Object

> Kubernetes Object는 하나의 "행동 및 의도를 담은 레코드"로 말할 수 있다.

Kubernetes는 시스템 상태를 나타내는 추상적인 개념을 가지고 있다. 컨테이너화 되어 배포 된 어플리케이션 워크 로드, 이에 관련한 네트워크와 디스크 자원, 그 밖에 Cluster가 무엇을 하고 있는지에 대한 정보를 말하고 있다.

이런 개념은 Kubernetes API 내 Object로 표현된다. 자세히 표현하면 아래와 같다.

- 어떤 어플리케이션이 어느 노드에서 실행 중인가.
- 해당 어플리케이션이 이용할 수 있는 리소스.
- 해당 어플리케이션이 어떻게 재구동 정책, 업데이트, 장애 복구 방법에 대한 정책.

Kubernetes Object를 생성하게 되면, Kubernetes System은 오브젝트 생성을 위해 동작하게 되며, Object를 생성함으로써 Cluster의 작동 진행 상황을 어떤 형태로 보이고자 하는지에 대해 효과적으로 Kubernetes System에 전달하게 된다.

*이 활동이 바로 Kubernetes Object을 통해 Cluster에 대한 "의도한 상태"가 되는 과정이며, 이를 통해 Kubernetes의 상태를 나타내는 역할을 Kubernetes의 Object가 한다고 보면 된다.*

즉, CloudFoundry의 Manifest와 같은 역할을 하지만, Kubernetes의 Object는 좀 더 다양하고 세분화 되어 아래와 같이 정리되어 있다.

기초적인 Kubernetes Object에는 아래와 같이 존재한다.

- Pod
- Service
- Volume
- Namespace

추가로, Kubernetes Controller라는 기초 Object 기반으로, 부가 기능 및 편의 기능이 아래와 같이 존재한다.

- ReplicaSet
- Deployment
- StatefulSet
- DaemonSet
- Job

각 Object는 따로 자세히 정리되어 링크를 걸어 둘 예정이다.



> 정리
>
> > Kubernetes의 Object는 Kubernetes의 시스템 상태와 배포할 어플리케이션의 워크로드에 대한 정보를 가지고 있다.



## 2. Kubernetes Object Spec

> Spec은 Object가 가졌으면 하고 *'원하는 Object의 설정 및 특성'*을 기술하고, Status는 *'Object의 실제 상태'*를 기술한다.

Kubernetes에서 Object를 생성 시, Object에 대한 기본적인 정보와 더불어, 어플리케이션의 워크로드의 상태를 기술한 Object Spec을 통해 생성이 진행된다.

*가장 기본적이고, 많이 쓰이는 Kubernetes Object는 'Pod', 'Service', 'Volume', 'Namespace' 가 존재한다.*

아래는 Kubernetes Deployment를 위한 Object spec의 'yaml 파일' 예시이다.

```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

위 예시와 같이 'yaml 파일'을 이용하여 Deployment를 생성하기 위한 하나의 방식으로는 kubectl의 인자값으로 'yaml 파일'을 지정하여 ``` kubectl create ``` 명령을 이용하는 것이다.

```
$ kubectl create -f https://k8s.io/examples/application/deployment.yaml --record

deployment.apps/nginx-deployment created
```

Kubernetes Object에 대한 'yaml 파일'에는 필수로 설정해줘야 하는 필드값들이 존재한다.

- ```apiVersion```  이 Object를 생성하기 위해 사용하고 있는 **Kubernetes API 버전** 이 어떤 것인가
- ```kind``` **어떤 종류의 Object** 를 생성하고자 하는지
- ```metadata``` name, UID, 그리고 Namespace를 포함하여 **Object를 구분**지어 줄 데이터

이 이외에 ```spec``` 필드를 작성해야 하며, ```spec``` 필드는 모든 Kubernetes Object마다 다르며, 자세한 정보는 https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/ 를 통해서 확인 할 수 있다.