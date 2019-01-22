# Kubernetes - Unit 2



## 2. Kubernetes Components

*쿠버네티스 클러스터에 필요한 다양한 바이너리 컴포넌트들이 있다*

### 1) 마스터 컴포넌트

마스터 컴포넌트는 클러스터의 전번적인 스케줄링을 구성하고, 이벤트를 관리하는 역할을 하고 있다.
*즉 클러스터의 전반적인 이벤트와 스케줄링을 관리한다.*

마스터 컴포넌트의 역할을 하기 위하여 마스터 컴포넌트 내부에서 작동되는 컴포넌트가 있다.

- kube-apiserver
  마스터에서 쿠버네티스 API를 사용할 수 있도록 제공

- etcd
  모든 클러스터의 데이터를 가지고 있는 저장소

- kube-scheduler
  쿠버네티스에 Pod 생성 시 Pod가 배포되어 실행 될 노드를 선택해주는 컴포넌트 

- kube-controller-manager
  마스터 컴포넌트에 존재하는 컨트롤러이며, 컨트롤러는 다음과 같은 기능을 포함하고 있다.

  - Node Controller
    노드가 다운되었을 경우 상태 알람과 해당 노드에 대한 대응을 하는 컨트롤러
  - Replication Controller (곧 Replica Sets로 변한다고 함)
    시스템의 모든 레플리케이션 컨트롤러 오브젝트에 대해 알맞은 수의 파드들을 유지시켜주는 컨트롤러
  - Endpoints Controller
    서비스와 파드를 연결하는 컨트롤러
  - Service Account & Token Controllers
    새로운 Name space에 대한 기본 계정과 API 접근 토근을 생성하는 컨트롤러

- cloud-controller-manager
  쿠버네티스를 클라우드와 연동하는 기능을 제공, 즉 IaaS 기반의 클라우드에 쿠버네티스를 연동하는 기능을 제공하여, IaaS 클라우드의 자원 상황과 쿠버네티스의 자원상황을 맞춰주는 기능을 가지고 있다.

  ![pic-2](https://d33wubrfki0l68.cloudfront.net/518e18713c865fe67a5f23fc64260806d72b38f5/61d75/images/docs/post-ccm-arch.png)

  다음은 cloud-controller-manager의 기능을 포함하고 있다.

  - Node Controller
    노드가 완전히 삭제가 되고 나서 클라우드 상에서 삭제되었는지 확인하는 컨트롤러.
  - Route Controller
    클라우드 인프라에 라우트를 설정하는 컨트롤러.
  - Service Controller
    클라우드의 로드밸런스를 생성, 업데이트 및 삭제하는 등의 로드벨런스 관리하는 컨트롤러.
  - Volume Controller
    IaaS에서 생성되는 볼륨의 생성, 마운트, 삭제를 관리하는 컨트롤러.



### 2) 노드 컴포넌트

노드 컴포넌트는 파드를 유지시키고 쿠버네티스 런타임 환경을 제공하며, 모든 노드에서 동작하는 컴포넌트다.

아래는 노드 컴포넌트에서 주요하게 동작하는 컴포넌트이다.

- kubelet
  클러스터의 각 노드에서 실행되는 에이전트이며, 컨테이너가 pod에서 실행되고 있는지 확인하고, 파드의 spec를 통해 spec에 정의된 컨테이너를 생성, 삭제, 업데이트, 모니터링을 한다.
  kubelet에서 생성하지 않은 컨테이너는 관리하지 않는다.
- kube-proxy
  호스트 상에서 네트워크 규칙을 유지, 포트 포워딩을 수행함으로 쿠버네티스의 서비스가 가능하도록 해준다.
- container runtime
  컨테이너 런타임은 컨테이너의 모든 동작을 관리하며, kubelet이 해당 컨테이너 런타임에 명령을 한다.
  쿠버네티스에서는 Docker, rkt, runc 그리고 OCI runtime-spec을 지원하고 있다.



### 3) Addon

애드온은 클러스터 기능을 실행하는 파드와 서비스이며, 이 파드는  Deployments, ReplicationControllers, 기타 등등에 의하여 관리 될 수 있으며, 네임스페이스를 가지는 애드온 오브젝트는 kube-system 네임스페이스 내에서 생성 되어진다.

아래는 쿠버네티스에서 주로 사용되는 일부 애드온이다.

- DNS
  쿠버네티스 서비스를 위해 DNS 레코드를 제공해주는 DNS 서버이며, 쿠버네티스에 의해 구동되는 컨테이너는 DNS 검색에서 이 DNS 서버를 자동으로 포함시킨다.
- 웹 UI (대시보드)
  대시보드는 쿠버네티스 클러스터에 대한 정보를 보여주는 웹 기반 UI

