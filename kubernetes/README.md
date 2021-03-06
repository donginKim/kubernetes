# Kubernetes - Unit 1



## 0. What is Kubernetes?

*쿠버네티스는 구글에서 2014년에 오픈소스화 한, 컨테이너화 된 워크로드와 서비스를 관리하기 위한 이식성이 있으며, 확장 가능한 플랫폼이다.*

### 1) 쿠버네티스 기능

- 컨테이너 플랫폼
- 마이크로서비스 플랫폼
- 이식성 있는 클라우드 플랫폼 등등 다양한 기능.....

쿠버네티스는 *컨테이너 중심의* 관리 환경을 제공하며, 이 환경은 컴퓨팅, 네트워크 배포 관리를 자동으로 해주는 오케스트레이션 기능, 즉 컨테이너 운영 환경을 제공한다.

- 컨테이너 운영환경?

  작은 수의 컨테이너는 수동으로 VM이나 하드웨어에 직접 배포하면 되겠지만, VM이나 하드웨어의 수가 많아지고 컨테이너 수가 많아지게 된다면 이 모든 컨테이너를 어디에 배포할 것인지, 많은 컨테이너를 어떻게 운영할껀지에 대한 문제점이 발생하게 되는데, 이를 해결해 주는 방안으로 컨테이너를 적절한 서버에 배포해주는 역할인 스케쥴링, 정상 작동 모니터링을 통해 재기동, 삭제 등 컨테이너에 대한 종합적인 관리를 해주는 환경이 컨테이너 운영 환경이라 한다.

  즉, 하드웨어 및 VM 수가 많아지고, 컨테이너 수가 많아도 이를 관리해주고, 배포 스케쥴을 관리하는 환경을 말한다.



### 2) 쿠버네티스의 뜻

쿠버네티스(kubernetes)는 *키잡이*  혹은 *파일럿*을 뜻하는 그리스어에서 유래했다.  쿠버네티스의 또 다른 표기 법인 'K8s' 는 "ubernete" 8글자를 "8"로 대체한 약어다.



## 1. Why Containers?

*쿠버네티스는 컨테이너 중심의 컨테이너 운영환경을 제공하는 플랫폼이다.*

지금까지 어플리케이션을 배포하는 방법은 각 해당 OS의 패키지 관리자를 사용하여 호스트에 설치하였는데, 이 방식은 어플리케이션의 실행 파일, 설정, 라이브러리 서로 간의 라이프사이클이 호스트 OS에 설치, 실행이 되어 아주 무거운 형태로 실행되는 단점이 있으며, 롤백 혹은 롤 아웃을 위하여 VM에 배포 할 수 있지만, VM은 너무 크고 이식을 할 수 없다.

![pic-1](https://d33wubrfki0l68.cloudfront.net/e7b766e0175f30ae37f7e0e349b87cfe2034a1ae/3e391/images/docs/why_containers.svg)

*이러한 단점을 해결하고자 하드웨어 가상화가 아닌 운영체제 수준의 가상화에 기반한 컨테이너를 배포하는 방법이다.*

이러한 컨테이너에 대한 장점을 요약하자면 :

- 쉽고 가벼운 어플리케이션 생성과 배포
  VM 이미지보다 컨테이너 이미지 생성이 보다 쉽고 가벼움

- 지속적인 개발, 통합 및 배포
  이미지의 불변성 때문에 빠르고 쉽게 롤백 할 수 있으며, 안정적이고 주기적으로 컨테이너 이미지를 빌드해서 배포가 가능

- 개발과 운영 환경 분리
  배포 시점이 아닌 빌드와 릴리즈 시점에 컨테이너 이미지를 만들기 때문에 어플리케이션이 인프라 환경에서 분리됨

- 가시성이 뛰어남
  OS 수준의 매트릭 정보 뿐만 아니라 어플리케이션 수준까지의 모니터링이 가능하다.

- 개발, 테스팅 및 운영 환경의 일관성
  개인 PC에서도 클라우와 동일하게 구동이 가능하다.

- 클라우드 및 OS별 뛰어난 이식성
  다양한 OS, 다양한 클라우드 서비스에서도 구동이 가능하다.

- 어플리케이션 중심 관리
  (가상) 하드웨어의 OS에서 어플리케이션을 실행하는 것에서 OS의 자원을 통해 어플리케이션을 단독으로 구동

- 자원 격리
  어플리케이션의 성능을 예측 가능