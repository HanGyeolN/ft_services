# ft_services

## Objective

---

This project consist to clusturing an docker-compose application and deploy it with Kubernetes.

![Untitled](ft_services%200ae3f2beb80a42ddbf2dd76112ad92cc/Untitled.png)

- 요구사항    
  The project consists of setting up an infrastructure of different services. To do this, you must use Kubernetes. You will need to set up a multi-service cluster.

  Each service will have to run in a dedicated container.
  
  Each container must bear the same name as the service concerned and for performance reasons, containers have to be build using Alpine Linux.

  Also, they will need to have a Dockerfile written by you which is called in the [setup.sh](http://setup.sh/).

  You will have to build yourself the images that you will use. It is forbidden to take already build images or use services like DockerHub.
  
  You will also have to set up:
  • The Kubernetes web dashboard. This will help you manage your cluster.

  • The Load Balancer which manages the external access of your services. It will be the only entry point to your cluster. You must keep the ports associated with the service (IP:3000 for Grafana etc). Load Balancer will have a single ip.

  • A WordPress website listening on port 5050, which will work with a MySQL database. Both services have to run in separate containers. The WordPress website will have several users and an administrator. Wordpress needs its own nginx server. The Load Balancer should be able to redirect directly to this service.

  • phpMyAdmin, listening on port 5000 and linked with the MySQL database. PhpMyAdmin needs its own nginx server. The Load Balancer should be able to redirect directly to this service.

  • A container with annginx server listening on ports 80 and 443. Port 80 will be in http and should be a systematic redirection of type 301 to 443, which will be in https.
  
  The page displayed does not matter as long as it is not an http error.
  This container will allow access to a /wordpress route that makes a redirect 307 to IP:WPPORT. It should also allow access to /phpmyadmin with a reverse proxy to IP:PMAPORT.
  
  • A FTPS server listening on port 21.
  
  • A Grafana platform, listening on port 3000, linked with an InfluxDB database. Grafana will be monitoring all your containers. You must create one dashboard per service. InfluxDB and grafana will be in two distincts containers.
  
  • In case of a crash or stop of one of the two database containers, you will have to make shure the data persist.
  
  • You must be able to access the nginx container by logging into SSH.
  
  • All your containers must restart in case of a crash or stop of one of its component parts.
  
  Make sure that each redirection toward a service is done using a load balancer. FTPS,
  Grafana, Wordpress, PhpMyAdmin and nginx’s kind must be "LoadBalancer". Influxdb and MySQL’s kind must be "ClusterIP". Other entries can be present, but none of them can be of kind "NodePort".
  
  Usage of Node Port services, Ingress Controller object or kubectl
  port-forward command is prohibited.
  Your Load Balancer should be the only entry point for the Cluster.
  It’s useless try to use any Load Balancer provided by Cloud Provider.
  you should rather look at MetalLB.
    

# Kubernetes Objects

## 1. Pod / Labels

Object - Pod

1-1) Pod 오브젝트 안에는 여러개의 컨테이너를 만들 수 있다.

```jsx
apiVersion: v1
kind: Pod #Pod 오브젝트
metadata:
 name: pod-1 # 이름
spec: # pod 명세
 containers: # 파드 안에 컨테이너들 정의
 - name: container1
   image: tmkube/p8000
   ports:
   - containerPort: 8000 # 파드 안에서 통신할때 이 컨테이너에 부여할 포트번호
 - name: container2
   image: tmkube/p8080
   ports:
   - containerPort: 8080
```

1-2) Labels

pod에 label을 달아놓아야 서비스의 selector를 통해 연결 할 수 있다.

```bash
# pod 생성
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
  labels:
    type: web
    lo: dev
spec:
  containers:
  - name: container
    image: tmkube/init
---
# Service 생성
apiVersion: v1
kind: Service
metadata:
  name: svc-for-web
spec:
  selector:
    type: web
  ports:
    - port: 8080

# service2
apiVersion: v1
kind: Service
metadata:
  name: svc-2
spec:
  selector:
    lo: production
  ports:
    - port: 8080
```

---

실습2. 

서비스 ip의 9000번 포트로 접속하면 연결된 파드의 8080포트로 연결시켜준다.

여기서 파드가 재생성되어 ip가 변해도 서비스는 그대로이기에 ip가 변하지 않고 파드에 연결된다.

### 2-1) Pod

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
  labels:
     app: pod
spec:
  containers:
  - name: container
    image: kubetm/app
    ports:
    - containerPort: 8080

```

### 2-2) Service

```
apiVersion: v1
kind: Service
metadata:
  name: svc-1
spec:
  selector:
    app: pod
  ports:
  - port: 9000
    targetPort: 8080
```

---

## 2. NodePort

---

![https://kubetm.github.io/img/practice/beginner/Service%20with%20NodePort%20for%20Kubernetes.jpg](https://kubetm.github.io/img/practice/beginner/Service%20with%20NodePort%20for%20Kubernetes.jpg)

모든 노드 컴퓨터에 서비스로 접근할 수 있는 포트가 생긴다.

서비스는 이를 분산해서 노드내 파드로 보낸다. 옵션을 통해서 자기가 접속한 노드 내 파드로만 요청이 보내지도록 할 수 있다.

### Service

```
apiVersion: v1
kind: Service
metadata:
  name: svc-2
spec:
  selector:
    app: pod
  ports:
  - port: 9000
    targetPort: 8080
    nodePort: 30000
  type: NodePort
  externalTrafficPolicy: Local

```

---

## 3. Load Balancer

---

![https://kubetm.github.io/img/practice/beginner/Service%20with%20LoadBalancer%20for%20Kubernetes.jpg](https://kubetm.github.io/img/practice/beginner/Service%20with%20LoadBalancer%20for%20Kubernetes.jpg)

기본적인건 노드포트와 같고, 노드로 연결되기 전 로드밸런서를 거친다는것만 다르다.

다만 이를 위해서는 외부 아이피 할당을 해줄수 있는 플러그인이 필요하다 (metalLB)

그렇지 않으면 로드밸런서 서비스 생성시 pending상태에서 넘어가지 않는다.

### Service

```
apiVersion: v1
kind: Service
metadata:
  name: svc-3
spec:
  selector:
    app: pod
  ports:
  - port: 9000
    targetPort: 8080
  type: LoadBalancer

```

---

ex03. Volume 실습

## 1. EmptyDir

---

![https://kubetm.github.io/img/practice/beginner/Volume%20with%20emptyDir%20for%20Kubernetes.jpg](https://kubetm.github.io/img/practice/beginner/Volume%20with%20emptyDir%20for%20Kubernetes.jpg)

Pod 내부 컨테이너끼리만 공유하는 볼륨 타입이다.

파드 재생성시 초기화되므로 용도에 맞게 사용해야한다.

### 1-1) Pod

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-volume-1
spec:
  containers:
  - name: container1
    image: kubetm/init
    volumeMounts:
    - name: empty-dir
      mountPath: /mount1
  - name: container2
    image: kubetm/init
    volumeMounts:
    - name: empty-dir
      mountPath: /mount2
  volumes:
  - name : empty-dir
    emptyDir: {}

```

```
mount | grep mount1
echo "file context" >> file.txt

```

---

## 2. HostPath

---

![https://kubetm.github.io/img/practice/beginner/Volume%20with%20hostPath%20for%20Kubernetes.jpg](https://kubetm.github.io/img/practice/beginner/Volume%20with%20hostPath%20for%20Kubernetes.jpg)

volume생성시 노드셀렉터로 노드를 지정해주고 해당 노드에 실행된 파드와 마운트된다.

데이터는 당연히 다른 파드의 컨테이너들과 해당 노드에서 확인가능함

### 2-1) Pod

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-volume-3
spec:
  nodeSelector:
    kubernetes.io/hostname: k8s-node1
  containers:
  - name: container
    image: kubetm/init
    volumeMounts:
    - name: host-path
      mountPath: /mount1
  volumes:
  - name : host-path
    hostPath:
      path: /node-v
      type: DirectoryOrCreate

```

## 3. PVC / PV

---

![https://kubetm.github.io/img/practice/beginner/Volume%20with%20PersistentVolume%20PersistentVolumeClaim%20for%20Kubernetes.jpg](https://kubetm.github.io/img/practice/beginner/Volume%20with%20PersistentVolume%20PersistentVolumeClaim%20for%20Kubernetes.jpg)

PV를 먼저 만들어 놓고 PVC를 통해 요청

Volume의 종류가 다양하므로 PV의 타입과 그에따른 속성 또한 여러개가 존재함.

POD에선 이미 만들어진 PVC를 이용해서 볼륨 생성

### 3-1) PersistentVolume

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-03
spec:
  capacity:
    storage: 2G
  accessModes:
  - ReadWriteOnce
  local:
    path: /node-v
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - {key: kubernetes.io/hostname, operator: In, values: [k8s-node1]}

```

### 3-2) PersistentVolumeClaim

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-04
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1G
  storageClassName: ""

```

### 3-3) Pod

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-volume-3
spec:
  containers:
  - name: container
    image: kubetm/init
    volumeMounts:
    - name: pvc-pv
      mountPath: /mount3
  volumes:
  - name : pvc-pv
    persistentVolumeClaim:
      claimName: pvc-01

```

---

## PV-PVC를 Label과 Selector를 이용해 연결하는 방법

---

### 3-1) PersistentVolume

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-03
  labels:
    pv: pv-03
spec:
  capacity:
    storage: 2G
  accessModes:
  - ReadWriteOnce
  local:
    path: /node-v
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - {key: kubernetes.io/hostname, operator: In, values: [k8s-node1]}

```

### 3-2) PersistentVolumeClaim

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-04
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1G
  storageClassName: ""
  selector:
    matchLabels:
      pv: pv-03

```

## Tips

---

### **HostPath Type**

- DirectoryOrCreate : 실제 경로가 없다면 생성
- Directory : 실제 경로가 있어야됨
- FileOrCreate : 실제 경로에 파일이 없다면 생성
- File : 실제 파일이 었어야함

---

서비스 구조가 어떻게 되어야하는가?

서비스 5개가 다 로드밸런서 인데 그림에서는 하나만 있음

로드밸런서의 ip가 같으면 말이됨,

로드밸런서의 ip pool을 1개로만 지정함. 

외부 ip로 접속시 3만번대 포트로 접속해야 하는 문제 → 노드 포트를 지정해줌

---

# Install

1. 환경세팅
- 쿠버네티스를 위한 환경을 구축해야합니다. 마스터 노드와 워커 노드 최소 2대의 컴퓨터가 필요하지만 minikube를 쓰면 간단하게 구축할 수 있습니다.
- 2개의 노드를 만들기 위한 두가지 방법이 있는데 첫번째는 가상머신을 이용하는 방법, 두번째는 클라우드 서비스를 이용하는 방법입니다.
- AWS Lightsail에서 2개의 vm을 빌리고 생성합니다.
- 패스워드를 설정합니다. ([https://wordpress-startup.tistory.com/entry/AWS-Lightsail-라이트세일-루트-권한-방법](https://wordpress-startup.tistory.com/entry/AWS-Lightsail-%EB%9D%BC%EC%9D%B4%ED%8A%B8%EC%84%B8%EC%9D%BC-%EB%A3%A8%ED%8A%B8-%EA%B6%8C%ED%95%9C-%EB%B0%A9%EB%B2%95))
- 방화벽에서 쿠버네티스와 도커 관련 포트를 열어줍니다. ([https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/))
- ubuntu 18.04 OS에 도커를 설치합니다 ([https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)) ([https://blog.cosmosfarm.com/archives/248/우분투-18-04-도커-docker-설치-방법/](https://blog.cosmosfarm.com/archives/248/%EC%9A%B0%EB%B6%84%ED%88%AC-18-04-%EB%8F%84%EC%BB%A4-docker-%EC%84%A4%EC%B9%98-%EB%B0%A9%EB%B2%95/))([https://kubetm.github.io/practice/appendix/installation_case5/](https://kubetm.github.io/practice/appendix/installation_case5/))
- kubectl 설치 ([https://kubernetes.io/docs/tasks/tools/install-kubectl/](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
- kubeadm kubelet 설치 ([https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/))
- 마스터와 워커 노드 설정 및 연결, 실행 ([https://kubetm.github.io/practice/appendix/installation_case5/](https://kubetm.github.io/practice/appendix/installation_case5/))
- Calico 설치 ([https://kubetm.github.io/practice/appendix/installation_case5/](https://kubetm.github.io/practice/appendix/installation_case5/))
    
    미설치시 pod간 네트워크 연결이 되지 않고, 노드들이 NOT READY상태로 된다.
    

2. MetalLB 설치, 대시보드 설치

- MetalLB 설치 ([https://metallb.universe.tf/installation/](https://metallb.universe.tf/installation/)) ([https://mvallim.github.io/kubernetes-under-the-hood/documentation/kube-metallb.html](https://mvallim.github.io/kubernetes-under-the-hood/documentation/kube-metallb.html))
- 대시보드 설치 ([https://medium.com/@yunhochung/k8s-대쉬보드-설치-및-외부-접속-기능-추가하기-22ed1cd0999f](https://medium.com/@yunhochung/k8s-%EB%8C%80%EC%89%AC%EB%B3%B4%EB%93%9C-%EC%84%A4%EC%B9%98-%EB%B0%8F-%EC%99%B8%EB%B6%80-%EC%A0%91%EC%86%8D-%EA%B8%B0%EB%8A%A5-%EC%B6%94%EA%B0%80%ED%95%98%EA%B8%B0-22ed1cd0999f))
- rsa 에러 ([https://stackoverflow.com/questions/54565186/openssl-key-result-too-small](https://stackoverflow.com/questions/54565186/openssl-key-result-too-small))
- kubectl get svc kubernetes-dashboard -n kube-system 으로 포트를 확인한다.
- 외부에서 접속할때는 public ip:해당포트로 접속하면 대시보드로 접속할수 있다.
- 대시보드 접속시 토큰 확인([https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard](https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard))

```bash
# Metal LB 설치
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# configMap yaml파일 생성
$ vi layer2-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.56.240-192.168.56.250

# yaml 적용
kubectl apply -f layer2-config.yaml

# dashboard 설치
$ mkdir certs; cd certs
$ openssl genrsa -des3 -passout pass:hnahna -out dashboard.pass.key 2048
Generating RSA private key, 2048 bit long modulus

$ openssl rsa -passin pass:x -in dashboard.pass.key -out dashboard.key
writing RSA key
$ rm dashboard.pass.key
$ openssl req -new -key dashboard.key -out dashboard.csr

...

```

- 대시보드 접속 3초뒤 로그인 페이지로 돌아가는 에러 ([https://github.com/kubernetes-sigs/kubespray/issues/5347](https://github.com/kubernetes-sigs/kubespray/issues/5347))
- 쿠버네티스 공식문서([https://kubernetes.io/ko/docs/tasks/](https://kubernetes.io/ko/docs/tasks/))
- 메탈LB와 캘리코([https://www.benevolent.com/engineering-blog/deploying-metallb-in-production](https://www.benevolent.com/engineering-blog/deploying-metallb-in-production))
- node notready문제와 calico([https://stackoverflow.com/questions/47107117/how-to-debug-when-kubernetes-nodes-are-in-not-ready-state](https://stackoverflow.com/questions/47107117/how-to-debug-when-kubernetes-nodes-are-in-not-ready-state))([https://stackoverflow.com/questions/49112336/container-runtime-network-not-ready-cni-config-uninitialized](https://stackoverflow.com/questions/49112336/container-runtime-network-not-ready-cni-config-uninitialized))
- server not connect 문제 (원인: 서비스 미실행, 노드 미설정, 해결: 공식문서 참고)
- 읽어보기 ([https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/))

---
# Issues
발생했던 문제와 해결 방법들

## 쿠버네티스 대시보드 2.0 설치하기

1. wget [https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml](https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml) 으로 2.0 yaml파일을 받는다
2. [https://medium.com/@yunhochung/k8s-대쉬보드-설치-및-외부-접속-기능-추가하기-22ed1cd0999f](https://medium.com/@yunhochung/k8s-%EB%8C%80%EC%89%AC%EB%B3%B4%EB%93%9C-%EC%84%A4%EC%B9%98-%EB%B0%8F-%EC%99%B8%EB%B6%80-%EC%A0%91%EC%86%8D-%EA%B8%B0%EB%8A%A5-%EC%B6%94%EA%B0%80%ED%95%98%EA%B8%B0-22ed1cd0999f) 에서 ssl과 secret 만드는거 따라하기
3. 대시보드도 서비스 오브젝트중에 하나다. 따라서 서비스 타입에 로드밸런스로 설정을 해야 외부에서 접근이 가능하다. 토큰입력해서 로그인

## 제대로 배포되었는지 확인하기

kubectl get deployment —all-namespaces 명령으로 STATUS 확인


## 알파인 패키지 설치하기 
1. 알파인 버전에서 시작 ([https://hub.docker.com/_/alpine](https://hub.docker.com/_/alpine))
    1. 리눅스 알파인이란? ([https://www.lesstif.com/docker/alpine-linux-35356819.html](https://www.lesstif.com/docker/alpine-linux-35356819.html))
    2. 알파인에서 패키지 설치는 apk update → apk install <패키지이름>

## 도커 레지스트리 사용하기
1. 미니쿠베 없이 로컬이미지 사용해결 [https://stackoverflow.com/questions/42564058/how-to-use-local-docker-images-with-minikube](https://stackoverflow.com/questions/42564058/how-to-use-local-docker-images-with-minikube)
2. 커넥션에러해결 [https://www.44bits.io/ko/post/running-docker-registry-and-using-s3-storage#도커-레지스트리-설치-1](https://www.44bits.io/ko/post/running-docker-registry-and-using-s3-storage#%EB%8F%84%EC%BB%A4-%EB%A0%88%EC%A7%80%EC%8A%A4%ED%8A%B8%EB%A6%AC-%EC%84%A4%EC%B9%98-1)
3. http 에러 해결 [https://github.com/docker/distribution/issues/1874](https://github.com/docker/distribution/issues/1874)

최종 로컬이미지 문제 해결:[https://stackoverflow.com/questions/49441216/kubectl-is-not-looking-for-local-image-on-one-node-but-works-fine-on-other-node](https://stackoverflow.com/questions/49441216/kubectl-is-not-looking-for-local-image-on-one-node-but-works-fine-on-other-node) 

## nginx 80이나 443포트 index 페이지 등 설정하기

Manual: [https://nginx.org/en/docs/beginners_guide.html](https://nginx.org/en/docs/beginners_guide.html)

(참고)[[https://opentutorials.org/module/384/4526](https://opentutorials.org/module/384/4526)]

알파인 nginx 설치[https://wiki.alpinelinux.org/wiki/Nginx](https://wiki.alpinelinux.org/wiki/Nginx)

설정파일은 공식문서에 nginx.conf와 index.html을 참고했다.

## nginx를 포그라운드로 실행시켜서 컨테이너가 계속 켜저있도록 하기

deamon off 옵션을 넣고 실행해도 컨테이너가 계속 재생성 되었다. 직접 알파인 컨테이너에 접속해서 nginx -g "daemon off;"로 실행시켜보니
로그중에 nginx: [emerg] open() "/run/nginx/nginx.pid" failed (2: No such file or directory) 에러가 발생함.

nginx 프로세스를 실행할때 pid를 저장할 공간이 필요한데, 디폴트로 /run/nginx 로 되어있다. 그런데 /run에는 nginx디렉토리가 없어서 발생한 문제였음. 

Dockerfile에 RUN mkdir /run/nginx 추가해서 해결함.

## nginx 443포트가 연결 가능하도록 설정하기

문제: Back-off로 컨테이너가 계속 재생성되서 로그 확인 불가

해결: CMD ["sh", "-c", "tail -f /dev/null"]로 컨테이너가 꺼지지 않도록 함

해결: 인증서를 생성하는 부분 추가, nginx.conf에 443포트 추가

문제: 설정파일 에러 참고 [https://stackoverflow.com/questions/41766195/nginx-emerg-server-directive-is-not-allowed-here/41766811](https://stackoverflow.com/questions/41766195/nginx-emerg-server-directive-is-not-allowed-here/41766811)

443 연결 성공


## phpmyadmin 설치하기

[PhpMyAdmin](https://wiki.alpinelinux.org/wiki/PhpMyAdmin)

공식문서대로 설치 후 phpmyadmin 사이트 접속 했는데 페이지 응답이 없는 문제가 발생

원인: nginx 설정과 phpmyadmin 설정이 제대로 안되어있었음

해결: nginx.conf, config.inc.php 수정

nginx 접속은 됐는데 403 에러

원인: php파일을 해석하는 서버 부분이 없어서 발생한 부분

해결: php-fpm 설치 및 nginx.conf 설정 수정

php 로그인 화면까지는 들어가졌는데, mysqli:real_connect() : No such file or directory 에러 발생

시도: config.inc.php 수정, host에 ip를 직접입력? user, password 입력?

시도: nginx.conf 수정

시도: php 에서 빠트린 패키지가 있나? (재설치)

시도: mysql 계정 추가문제인가?

시도: mysql 재설치

시도: 다른 사람꺼 참고해서 재설치 (안됨)

시도: mysql 컨테이너가 문제인지 phpmyadmin 컨테이너가 문제인지 모르겠음

## export 쉘 스크립트가 동작하지 않는 문제

해결 : [https://stackoverflow.com/questions/10781824/export-not-working-in-my-shell-script](https://stackoverflow.com/questions/10781824/export-not-working-in-my-shell-script) source 기능


## 도커 레지스트리 및 인증서 세팅

도커 레지스트리는 자기가 직접 만든 도커 이미지를 올리고 내려받을 수 있는 개인저장소 같은거다.

먼저 도커 레지스트리 서버가 필요한데 이를 클러스터에 서비스로 올린다.

그러면 모든 노드에서 이 서비스로 접근하면 로컬 이미지 사용이 가능하다.

1. 도커 레지스트리 디플로이먼트 띄우기
    
    이건 apply만 해주면 되서 쉽다. 문제는 ssl
    
2. 도커 레지스트리의 서버와 클라이언트는 https로 통신한다. 그래서 ssl설정이 필수다.
    - 우분투 기준 설명
    
    먼저 레지스트리 서버는 클러스터 내 컨테이너로 실행되므로, 미리 ssl인증서 파일을 만들고 이 파일들이 있는 노드의 certs폴더를 마운트 하는 방식으로 한다.
    
    ```bash
    $ sudo mkdir certs
    $ sudo openssl req -newkey rsa:2048 -x509 -sha256 -days 365 -nodes -out \
    ./certs/registry.crt -keyout ./certs/registry.key -subj \
    "/C=KR/ST=SEOUL/L=GANGNAM/OU=42/CN=docker-registry"
    ```
    
    레지스트리 클라이언트도 마운트된 certs 폴더 내 인증서 파일을 인증서 보관 폴더로 옮기고,
    
    이를 시스템에 반영하고, 도커를 재시작해야한다.
    
    ```bash
    $ sudo cp {cerfileDir}/{cerfileName}.crt /usr/share/ca-certificates/
    
    $ echo {certFileName}.crt >> /etc/ca-certificates.conf
    
    $ update-ca-certificates
    
    $ sudo service docker restart
    ```
    

## 워드프레스 설치 

[https://wiki.alpinelinux.org/wiki/WordPress](https://wiki.alpinelinux.org/wiki/WordPress)

[https://codex.wordpress.org/ko:Installing_WordPress](https://codex.wordpress.org/ko:Installing_WordPress)

워드프레스 css에러

자원문제? → 헬스체크에 오류메세지

[https://wordpress.stackexchange.com/questions/163802/no-css-being-loaded-on-backend](https://wordpress.stackexchange.com/questions/163802/no-css-being-loaded-on-backend)

[Error Some files are not writable by WordPress](https://support.cloudways.com/how-to-resolve-wordpress-asking-for-ftp-credentials-error/)

파일 권한문제였음

[https://stackoverflow.com/questions/57630117/how-to-fix-some-files-are-not-writable-by-wordpress-error-website-cannot-be-c](https://stackoverflow.com/questions/57630117/how-to-fix-some-files-are-not-writable-by-wordpress-error-website-cannot-be-c)

r권한 이해

[https://stackoverflow.com/questions/18352682/correct-file-permissions-for-wordpress](https://stackoverflow.com/questions/18352682/correct-file-permissions-for-wordpress)

## CSS not loading 문제

원인1: ssl mixed-content 

[https://wordpress.stackexchange.com/questions/163802/no-css-being-loaded-on-backend/309277](https://wordpress.stackexchange.com/questions/163802/no-css-being-loaded-on-backend/309277)

 [https://www.growyourgk.com/wordpress/solved-ssl-breaks-wordpress-css-css-not-working-when-redirects-to-https-css-not-loading-after-ssl/](https://www.growyourgk.com/wordpress/solved-ssl-breaks-wordpress-css-css-not-working-when-redirects-to-https-css-not-loading-after-ssl/)

[https://wordpress.stackexchange.com/questions/75921/ssl-breaks-wordpress-css/196220#196220](https://wordpress.stackexchange.com/questions/75921/ssl-breaks-wordpress-css/196220#196220)

원인2: 파일 쓰기권한

윈인3: 메모리

blank page 문제 : [https://www.collectiveray.com/wordpress-blank-page](https://www.collectiveray.com/wordpress-blank-page)

원인4: mysql auto-draft 문제

[https://sigmaplugin.com/blog/what-are-wordpress-auto-drafts-and-how-to-clean-them/#:~:text=WordPress automatically saves your post,visible in your public site](https://sigmaplugin.com/blog/what-are-wordpress-auto-drafts-and-how-to-clean-them/#:~:text=WordPress%20automatically%20saves%20your%20post,visible%20in%20your%20public%20site).

원인5: 캐시 문제

방문기록 삭제

## nginx 301에러

301에러는 보려는 페이지가 이동되었다는것을 의미한다.

https 페이지를 http로 연결했을 경우 이 메세지가 뜨도록 구성한다.

정의: [https://im-first-rate.tistory.com/73](https://im-first-rate.tistory.com/73)

방법: [https://ko.wikipedia.org/wiki/HTTP_301#:~:text=HTTP 응답 상태 코드 301,필드에 지정되어야 한다](https://ko.wikipedia.org/wiki/HTTP_301#:~:text=HTTP%20%EC%9D%91%EB%8B%B5%20%EC%83%81%ED%83%9C%20%EC%BD%94%EB%93%9C%20301,%ED%95%84%EB%93%9C%EC%97%90%20%EC%A7%80%EC%A0%95%EB%90%98%EC%96%B4%EC%95%BC%20%ED%95%9C%EB%8B%A4).

해결: 80포트로 들어오면 [https://IP$request_uri](https://ip$request_uri로) 반환

확인: 네트워크탭에서 확인 가능

## favicon 이란?

[https://webdir.tistory.com/337](https://webdir.tistory.com/337)

## 리버스 프록시란? 

[https://akal.co.kr/?p=1173](https://akal.co.kr/?p=1173)

프록시

[https://milkye.tistory.com/202#:~:text=프록시(Proxy)란 [ 대신,개념이라고 볼 수 있겠습니다](https://milkye.tistory.com/202#:~:text=%ED%94%84%EB%A1%9D%EC%8B%9C(Proxy)%EB%9E%80%20%5B%20%EB%8C%80%EC%8B%A0,%EA%B0%9C%EB%85%90%EC%9D%B4%EB%9D%BC%EA%B3%A0%20%EB%B3%BC%20%EC%88%98%20%EC%9E%88%EA%B2%A0%EC%8A%B5%EB%8B%88%EB%8B%A4).

리디렉션 vs 리버스 프록시 차이점

[https://doublesprogramming.tistory.com/63](https://doublesprogramming.tistory.com/63) 한글

[https://stackoverflow.com/questions/42154249/difference-http-redirect-vs-reverse-proxy-in-nginx#:~:text=1 Answer&text=With a redirect the server,look elsewhere for the resource.&text=A reverse proxy instead forwards,location back to the client](https://stackoverflow.com/questions/42154249/difference-http-redirect-vs-reverse-proxy-in-nginx#:~:text=1%20Answer&text=With%20a%20redirect%20the%20server,look%20elsewhere%20for%20the%20resource.&text=A%20reverse%20proxy%20instead%20forwards,location%20back%20to%20the%20client).

## phpmyadmin 404 문제

[https://serverfault.com/questions/931849/nginx-reverse-proxy-to-phpmyadmin-returns-404](https://serverfault.com/questions/931849/nginx-reverse-proxy-to-phpmyadmin-returns-404)

## phpmyadmin http 문제

[https://www.popit.kr/proxy-뒤에서-docker의-wordpress-https-적용/](https://www.popit.kr/proxy-%EB%92%A4%EC%97%90%EC%84%9C-docker%EC%9D%98-wordpress-https-%EC%A0%81%EC%9A%A9/)

## https 리버스 프록시 연결하기

https 의 리버스 프록시 연결은 설정이 좀더 까다롭다.

[https://docs.nginx.com/nginx/admin-guide/security-controls/securing-http-traffic-upstream/](https://docs.nginx.com/nginx/admin-guide/security-controls/securing-http-traffic-upstream/)

[https://www.popit.kr/커머스-코드-자산화-개발일지-4-출시/](https://www.popit.kr/%EC%BB%A4%EB%A8%B8%EC%8A%A4-%EC%BD%94%EB%93%9C-%EC%9E%90%EC%82%B0%ED%99%94-%EA%B0%9C%EB%B0%9C%EC%9D%BC%EC%A7%80-4-%EC%B6%9C%EC%8B%9C/)

truseted_ca?

[https://serverfault.com/questions/938269/nginx-client-cert-verification-ssl-client-certificate-vs-ssl-trusted-certificat](https://serverfault.com/questions/938269/nginx-client-cert-verification-ssl-client-certificate-vs-ssl-trusted-certificat)

crt to pem

[https://cheapsslsecurity.com/p/convert-a-certificate-to-pem-crt-to-pem-cer-to-pem-der-to-pem/](https://cheapsslsecurity.com/p/convert-a-certificate-to-pem-crt-to-pem-cer-to-pem-der-to-pem/)

해결

/phpmyadmin/ 으로 리턴

nginx 다른 포트로 연결이 안되는문제 (403 forbidden) → aws 포트 오픈을 안해줬었음


## ftps 설치하기

vsftpd

설치:

config 메뉴얼

[http://vsftpd.beasts.org/vsftpd_conf.html](http://vsftpd.beasts.org/vsftpd_conf.html)

500  child died.

[https://serverfault.com/questions/574722/vsftp-error-500-oops-child-die](https://serverfault.com/questions/574722/vsftp-error-500-oops-child-died)

500 Illegal PORT command.

[https://42born2code.slack.com/archives/CMX2R5JSW/p1582114186194200](https://42born2code.slack.com/archives/CMX2R5JSW/p1582114186194200)

ftp 패시브모드 vs 액티브 모드

[https://www.jscape.com/blog/bid/80512/active-v-s-passive-ftp-simplified](https://www.jscape.com/blog/bid/80512/active-v-s-passive-ftp-simplified)

[https://winscp.net/eng/docs/ftp_modes](https://winscp.net/eng/docs/ftp_modes)

ftps 보안연결 파일질라로 체크하기

[https://ostechnix.com/secure-vsftpd-server-with-tlsssl-encryption/](https://ostechnix.com/secure-vsftpd-server-with-tlsssl-encryption/)


## ssl 설정하기

[https://opentutorials.org/course/228/4894](https://opentutorials.org/course/228/4894)

ftps 클라이언트 연결 종료시 파드가 재생성되는 문제

해결: 도커 자체문제? 쉘을 통해 실행시키면 괜찮아짐

ftps pv연결시 파일 전송문제

해결: 폴더의 권한을 ftpuser로 변경

맥에서 ftp 연결시, 클라이언트 설치 문제

해결: lftp 설치

lftp 셀프 사인 인증서 문제

해결: [https://www.librebyte.net/en/ftp/lftp-fatal-error-certificate-verification-not-trusted/](https://www.librebyte.net/en/ftp/lftp-fatal-error-certificate-verification-not-trusted/)

ssl

set ssl:verify-certificate no

## influxdb - grafana - telegraf로 컨테이너 모니터링하기

[https://medium.com/naver-cloud-platform/grafana-influxdb를-활용한-모니터링-서비스-구축하기-62de4b07a505](https://medium.com/naver-cloud-platform/grafana-influxdb%EB%A5%BC-%ED%99%9C%EC%9A%A9%ED%95%9C-%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81-%EC%84%9C%EB%B9%84%EC%8A%A4-%EA%B5%AC%EC%B6%95%ED%95%98%EA%B8%B0-62de4b07a505)

influx 실행 → influxd

[https://docs.influxdata.com/influxdb/v2.0/get-started/](https://docs.influxdata.com/influxdb/v2.0/get-started/)

telegraf란?

telegraf와 쿠버네티스 

[https://www.influxdata.com/blog/kubernetes-monitoring-and-autoscaling-with-telegraf-and-kapacitor/](https://www.influxdata.com/blog/kubernetes-monitoring-and-autoscaling-with-telegraf-and-kapacitor/)

전체과정 참고: [https://devconnected.com/how-to-install-influxdb-telegraf-and-grafana-on-docker/](https://devconnected.com/how-to-install-influxdb-telegraf-and-grafana-on-docker/)

1. influxdb 설치, 연결
2. telegraf 플러그인 설치, 설정 (설치 참고: [https://stackoverflow.com/questions/62218240/how-to-add-a-edge-testing-package-to-alpine-linux](https://stackoverflow.com/questions/62218240/how-to-add-a-edge-testing-package-to-alpine-linux))
3. grafana 설치, 

## 쉘스크립트에서 두개이상 프로그램 실행시키기

해결: [https://stackoverflow.com/questions/3004811/how-do-you-run-multiple-programs-in-parallel-from-a-bash-script](https://stackoverflow.com/questions/3004811/how-do-you-run-multiple-programs-in-parallel-from-a-bash-script)


## Pod 내에서 kubernetes api에 접근하기

해결: Role

## Metrics API not available 문제

해결: 매트릭 서버 on

공식문서

influxdb:[https://docs.influxdata.com/influxdb/v2.0/get-started/](https://docs.influxdata.com/influxdb/v2.0/get-started/) 

telegraf: [https://docs.influxdata.com/telegraf/v1.16/concepts/](https://docs.influxdata.com/telegraf/v1.16/concepts/)

grafana: 

telegraf - prometeus

---

## 쿠버네티스 초기화하기 (자원 모두 삭제)
[https://stackoverflow.com/questions/47128586/how-to-delete-all-resources-from-kubernetes-one-time/47137442#:~:text=If you want to delete,namespace flag to k8s commands](https://stackoverflow.com/questions/47128586/how-to-delete-all-resources-from-kubernetes-one-time/47137442#:~:text=If%20you%20want%20to%20delete,namespace%20flag%20to%20k8s%20commands).

```
    프로비저닝
    <https://grafana.com/docs/grafana/latest/administration/provisioning/>
    
    telegraf kubernetes 플러그인에서 수집하는 데이터
    <https://github.com/influxdata/telegraf/blob/master/plugins/inputs/kubernetes/kubernetes_metrics.go>

    kubernetes 환경 구성
    <https://medium.com/finda-tech/overview-8d169b2a54ff>
    <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/>
    kubeadm
    
    docker-registry
    /etc/hosts
    /etc/docker/daemon.json
    
    metallb 설치
    <https://metallb.universe.tf/installation/>

    dashboard 토큰 조회
    <https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard>
    
    sed <https://hyunkie.tistory.com/51>
    shell script <https://jhnyang.tistory.com/146>
    
    문제: 네임스페이스가 지워지지 않는 문제
    해결: <https://medium.com/@craignewtondev/how-to-fix-kubernetes-namespace-deleting-stuck-in-terminating-state-5ed75792647e>
```

## 실수로 kubernetes 롤바인딩 전체 삭제한 경우 대처하기

→ 재설정 필요

참고

[https://kubetm.github.io/practice/appendix/installation_case2/](https://kubetm.github.io/practice/appendix/installation_case2/)

kubeadm reset

kubeadm init

init시 옵션

[https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/)

kubeadm join

k get nodes 에러

x509 cert 에러

[https://github.com/kubernetes/kubernetes/issues/48378](https://github.com/kubernetes/kubernetes/issues/48378)

registry 에러

마스터노드 taint 설정

kubectl taint node ip-172-26-1-141 [node-role.kubernetes.io/master-](http://node-role.kubernetes.io/master-)

[https://17billion.github.io/kubernetes/2019/04/24/kubernetes_control_plane_working.html](https://17billion.github.io/kubernetes/2019/04/24/kubernetes_control_plane_working.html)

포트범위 추가

[http://www.thinkcode.se/blog/2019/02/20/kubernetes-service-node-port-range](http://www.thinkcode.se/blog/2019/02/20/kubernetes-service-node-port-range)

대시보드에 안뜨는 문제

클러스터 어드민 롤을 삭제해버림

[https://github.com/kubernetes/kubernetes/blob/master/plugin/pkg/auth/authorizer/rbac/bootstrappolicy/testdata/cluster-roles.yaml](https://github.com/kubernetes/kubernetes/blob/master/plugin/pkg/auth/authorizer/rbac/bootstrappolicy/testdata/cluster-roles.yaml) 이거로 재생성

## 네임스페이스 지우는데 terminating 문제

delete namespace stuck

해결방법
1. 오래기다리면 될수도 있음
2. 먼저 서비스어카운트를 제거해야함


---

nginx status 페이지

[https://www.tecmint.com/enable-nginx-status-page/](https://www.tecmint.com/enable-nginx-status-page/)

php-fpm status 페이지

[https://www.tecmint.com/enable-monitor-php-fpm-status-in-nginx/](https://www.tecmint.com/enable-monitor-php-fpm-status-in-nginx/)

curl로 status 페이지 체크

[https://unix.stackexchange.com/questions/451207/how-to-trust-self-signed-certificate-in-curl-command-line](https://unix.stackexchange.com/questions/451207/how-to-trust-self-signed-certificate-in-curl-command-line)

sshd: no hostkeys available -- exiting

[https://www.garron.me/en/linux/sshd-no-hostkeys-available-exiting.html](https://www.garron.me/en/linux/sshd-no-hostkeys-available-exiting.html)

---

nginx 컨테이너 ssh 접속 불가문제

도커파일에서 password 설정이 안되었음

---
# Install

1. 환경세팅
- 쿠버네티스를 위한 환경을 구축해야합니다. 마스터 노드와 워커 노드 최소 2대의 컴퓨터가 필요하지만 minikube를 쓰면 간단하게 구축할 수 있습니다.
- 2개의 노드를 만들기 위한 두가지 방법이 있는데 첫번째는 가상머신을 이용하는 방법, 두번째는 클라우드 서비스를 이용하는 방법입니다.
- AWS Lightsail에서 2개의 vm을 빌리고 생성합니다.
- 패스워드를 설정합니다. ([https://wordpress-startup.tistory.com/entry/AWS-Lightsail-라이트세일-루트-권한-방법](https://wordpress-startup.tistory.com/entry/AWS-Lightsail-%EB%9D%BC%EC%9D%B4%ED%8A%B8%EC%84%B8%EC%9D%BC-%EB%A3%A8%ED%8A%B8-%EA%B6%8C%ED%95%9C-%EB%B0%A9%EB%B2%95))
- 방화벽에서 쿠버네티스와 도커 관련 포트를 열어줍니다. ([https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/))
- ubuntu 18.04 OS에 도커를 설치합니다 ([https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)) ([https://blog.cosmosfarm.com/archives/248/우분투-18-04-도커-docker-설치-방법/](https://blog.cosmosfarm.com/archives/248/%EC%9A%B0%EB%B6%84%ED%88%AC-18-04-%EB%8F%84%EC%BB%A4-docker-%EC%84%A4%EC%B9%98-%EB%B0%A9%EB%B2%95/))([https://kubetm.github.io/practice/appendix/installation_case5/](https://kubetm.github.io/practice/appendix/installation_case5/))
- kubectl 설치 ([https://kubernetes.io/docs/tasks/tools/install-kubectl/](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
- kubeadm kubelet 설치 ([https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/))
- 마스터와 워커 노드 설정 및 연결, 실행 ([https://kubetm.github.io/practice/appendix/installation_case5/](https://kubetm.github.io/practice/appendix/installation_case5/))
- Calico 설치 ([https://kubetm.github.io/practice/appendix/installation_case5/](https://kubetm.github.io/practice/appendix/installation_case5/))
    
    미설치시 pod간 네트워크 연결이 되지 않고, 노드들이 NOT READY상태로 된다.
    

2. MetalLB 설치, 대시보드 설치

- MetalLB 설치 ([https://metallb.universe.tf/installation/](https://metallb.universe.tf/installation/)) ([https://mvallim.github.io/kubernetes-under-the-hood/documentation/kube-metallb.html](https://mvallim.github.io/kubernetes-under-the-hood/documentation/kube-metallb.html))
- 대시보드 설치 ([https://medium.com/@yunhochung/k8s-대쉬보드-설치-및-외부-접속-기능-추가하기-22ed1cd0999f](https://medium.com/@yunhochung/k8s-%EB%8C%80%EC%89%AC%EB%B3%B4%EB%93%9C-%EC%84%A4%EC%B9%98-%EB%B0%8F-%EC%99%B8%EB%B6%80-%EC%A0%91%EC%86%8D-%EA%B8%B0%EB%8A%A5-%EC%B6%94%EA%B0%80%ED%95%98%EA%B8%B0-22ed1cd0999f))
- rsa 에러 ([https://stackoverflow.com/questions/54565186/openssl-key-result-too-small](https://stackoverflow.com/questions/54565186/openssl-key-result-too-small))
- kubectl get svc kubernetes-dashboard -n kube-system 으로 포트를 확인한다.
- 외부에서 접속할때는 public ip:해당포트로 접속하면 대시보드로 접속할수 있다.
- 대시보드 접속시 토큰 확인([https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard](https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard))

```bash
# Metal LB 설치
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# configMap yaml파일 생성
$ vi layer2-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.56.240-192.168.56.250

# yaml 적용
kubectl apply -f layer2-config.yaml

# dashboard 설치
$ mkdir certs; cd certs
$ openssl genrsa -des3 -passout pass:hnahna -out dashboard.pass.key 2048
Generating RSA private key, 2048 bit long modulus

$ openssl rsa -passin pass:x -in dashboard.pass.key -out dashboard.key
writing RSA key
$ rm dashboard.pass.key
$ openssl req -new -key dashboard.key -out dashboard.csr

...

```

- 대시보드 접속 3초뒤 로그인 페이지로 돌아가는 에러 ([https://github.com/kubernetes-sigs/kubespray/issues/5347](https://github.com/kubernetes-sigs/kubespray/issues/5347))
- 쿠버네티스 공식문서([https://kubernetes.io/ko/docs/tasks/](https://kubernetes.io/ko/docs/tasks/))
- 메탈LB와 캘리코([https://www.benevolent.com/engineering-blog/deploying-metallb-in-production](https://www.benevolent.com/engineering-blog/deploying-metallb-in-production))
- node notready문제와 calico([https://stackoverflow.com/questions/47107117/how-to-debug-when-kubernetes-nodes-are-in-not-ready-state](https://stackoverflow.com/questions/47107117/how-to-debug-when-kubernetes-nodes-are-in-not-ready-state))([https://stackoverflow.com/questions/49112336/container-runtime-network-not-ready-cni-config-uninitialized](https://stackoverflow.com/questions/49112336/container-runtime-network-not-ready-cni-config-uninitialized))
- server not connect 문제 (원인: 서비스 미실행, 노드 미설정, 해결: 공식문서 참고)
- 읽어보기 ([https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/))

---
