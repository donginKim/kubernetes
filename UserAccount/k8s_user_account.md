# Kubernetes create user account

---

> 쿠버네티스에서 유저 생성 -> 권한 부여 -> 유저 사용 -> 권한 체크 까지의 방법을 YAML 파일이 아닌 kubectl의 커멘드로만 사용 할 수 있도록 기술 하였습니다.

## 1. Create Service Account

#### 생성

```sh
$ kubectl create serviceaccount (username) 
$ kubectl create sa (username) #serviceaccount를 줄여서 sa라 하여도 무관함
```

#### 실사례 조회

```shell
$ kubectl create serviceaccount foo

$ kubectl get serviceaccount
NAME      SECRETS   AGE
default   1         50d
foo       1         148m #생성된 foo 계정
```



## 2. Create Cluster Role

#### 생성

```shell
$ kubectl create clusterrole (username) --verb=get --verb=list --verb=watch
#앞서 생성한 serviceaccount와 username을 동일하게 해야 혼동하지 않고 연결할 수 있지만, 작명은 자유
```

#### 실사례 조회

```shell
$ kubectl create clusterrole foo --verb=get --verb=list --verb=watch

$ kubectl get clusterrole
NAME                                                                   AGE
admin                                                                  50d
cluster-admin                                                          50d
edit                                                                   50d
foo                                                                    38m  # 생성 확인
kops:dns-controller                                                    50d
kube-dns-autoscaler                                                    50d
system:aggregate-to-admin                                              50d
...
```

```shell
$ kubectl describe clusterrole foo
Name:         foo
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods       []                 []              [get list watch]
```



## 3. Create Cluster Role Binding

#### 생성

```shell
$ kubectl create clusterrolebinding (username) \
  --serviceaccount=(namespace:username) \  #serviceaccount의 기본 namespace는 default
  --clusterrole=(clusterrole-username) #clusterrole과 serviceaccount를 binding
```

실사례 조회

```shell
$ kubectl create clusterrolebinding foo \
  --serviceaccount=default:foo \
  --clusterrole=foo
  
$ kubectl get clusterrolebinding
NAME                                                   AGE
cluster-admin                                          50d
foo                                                    139m # 생성 확인
kops:dns-controller                                    50d
kube-dns-autoscaler                                    50d
kubeadm:node-proxier                                   50d
kubelet-cluster-admin                                  50d
...
```

```shell
$ kubectl describe clusterrolebinding foo
Name:         foo
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  foo
Subjects:
  Kind            Name  Namespace
  ----            ----  ---------
  ServiceAccount  foo   default
```



## 4. Get Token Role

#### 생성

```shell
$ TOKEN=$(kubectl describe secrets "$(kubectl describe serviceaccount (username) | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')
#echo 로 확인해 보면 해당 계정의 TOKEN 값 적용
```

#### 실사례 조회

```shell
$ TOKEN=$(kubectl describe secrets "$(kubectl describe serviceaccount foo | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')

$ echo $TOKEN
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImZvby10b2tlbi1jdGZoeiIsImt1YmVybmV0Z ...
```



## 5. Kubectl Config Set Credentials

#### 생성

```shell
$ kubectl config set-credentials (configname) --token=$TOKEN
#사전에 4. Get Token Role 작업이 수행 된 후 실행이 되어야 함
```

#### 실사례 조회

```shell
$ kubectl config set-credentials podreader --token=$TOKEN
```



## 6. Kubectl Config Set Context

#### 생성

```shell
$ kubectl config set-context podreader --cluster=$(kubectl config current-context) --user=(configname)
#사전에 5. Kubectl Config Set Credentials 이 완료 되어야 함
```

#### 실사례 조회

```shell
$ kubectl config set-context podreader --cluster=$(kubectl config current-context) --user=podreader
```



## 7. Kubectl Config Use Context

#### 생성

```shell
$ kubectl config use-context (configname)
```

#### 실사례 조회

```shell
$ kubectl config use-context podreader
```



## 8.  Check Access Permission

#### 생성

```shell
$ kubectl auth can-i (kubectl command)
# auth can-i 가 질문하는거와 동일하며, kubectl command는 kubectl 을 제외한 나머지 부분을 조회
```

#### 실사례 조회

```shell
$ kubectl auth can-i get pods --all-namespaces
yes
$ kubectl auth can-i create pods
no
$ kubectl auth can-i delete pods
no
```

