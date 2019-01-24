# Kubernetes Control Plane

Kubernetes Object를 생성하고 관리하는 Kubernetes의 Control Plane은 Kubernetes가 작동하는데 전반적인 역활을 하고 있다.

Object를 생성하고 어떤 역활을 하고 있는지, Cluster의 종류가 무것이고 어떤 역활을 하는지에 대해 설명하고 있다.



## 1. What is Control Plane

> Kubernetes Control Plane은 사용자가 정의한 spec 과 실제 status를 맞추는 역활을 한다.

Kubernetes의 Object가 생성이 되려면 Kubernetes Control Plane이 Cluster의 현재 상태를 Object spec에 맞춰 생성하기 위한 일을 하게 된다. 

*Kubernetes Control Plane을 통해 Kubernetes가 컨테이너를 시작 혹은 재시작 시키거나, 주어진 어플리케이션의 컨테이너 복제 수를 스케일링하는 등 다양한 작업을 자동으로 수행할 수 있게 되었다.*

Kubernetes Master와 Kubelet 프로세스와 같은 Components는 Kubernetes가 Cluster와 통신을 담당하며, Control Plane은 시스템 내 모든 kubernetes Object를 유지하면서 Object의 상태를 관리하는 제어 루프를 지속적으로 구동시킨다.

제어루프는 Cluster 내에 변경이 발생하면 체크하면서 시스템 내 모든 Object의 status가 사용자가 지정한 상태(yaml를 통한 spec)와 일치시키도록 설정한다.

CloudFoundry의 nsyc와 같은 역할을 하고 있다.

> 예를 들어, Kubernete API를 이용하여 Deployment Object를 만들 때에는, Object spec로 시스템에 신규로 입력해야 한다. Kubernetes Control Plane이 Object 생성을 기록하고, Object spec 대로 필요한 어플리케이션을 시작시키고 Cluster Node에 스케줄링하여 Cluster의 status가 Object spec과 일치한 상태가 된다.



## 2. Kubernetes Control Plane 구성

> Kubernetes의 Cluster는 Master와 Node로 이루어져 있으며, 이 Cluster에 여러개의 프로세스가 실행되어 Control Plane이 이루어진다.

Kubernetes Control Plane이 Object의 생성을 기록하고 어플리케이션을 시작시키기 위해서 이를 실행해 줄 관리 장소가 필요로 한데 이를 Cluster라고 한다.

이 Cluster안에는 여러개의 프로세스가 실행되어 Kubernetes Control Plane이 이루어진다.

*Cluster는 Node라 불리는 VM 혹은 실제 머신의 집합이며, 여러 개의 Worker Node와 1개 이상의 Master로 구성된다.*

Cluster는 아래와 같이 구성되어 있다.

- Kubernetes Master

  Cluster에 대해 상태를 유지하고 관리하는 역활을 하고 있으며, 이런 역활을 하는 프로세스들이 존재한다. 주로 이 프로세스들은 클러스터 내 단일 Node에서 실행되며, 이 Node가 바로 Master이다. Kubernetes Master는 가용성과 중복을 위해서 여러개 혹은 복제되어 생성이 가능하다.

- Kubernetes Node

  Cluster 내 Node는 어플리케이션과 클라우드 워크플로우를 구동시키는 머신(VM, 물리서버)이며, Worker Node라 불리운다. Kubernetes Master가 각 Node를 관리하기 때문에 직접 관여할 일이 없다. Node 내의 프로세스중 Kubelet은 Kubernetes Master와 통신하기 위한 프로세스가 존재한다.

  

Cluster에서 돌아가는 프로세스는 아래와 같이 구성되어 있다.

- Kubernetes Master는 Cluster 내 Master Node로 지정된 Node내에서 구동되는 3개의 프로세스 집합.

  해당 프로세스는 아래와 같다.

  - kube-apiserver
  - kube-controller-manager
  - kube-scheduler

- Cluster 내 Master Node가 아닌 각각의 Node는 다음 두개의 프로세스를 구동시킨다.

  - Kubernetes의 Master Node와 통신하는 kubelet
  - 각 Node의 Kubernetes 네트워킹 서비스를 반영하는 네트워크 프록시인 kube-proxy