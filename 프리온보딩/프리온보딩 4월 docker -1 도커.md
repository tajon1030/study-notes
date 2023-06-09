
# 프리온보딩 백엔드 챌린지 4월 docker

## 사전 미션
1. 컨테이너 기술이란 무엇입니까? (100자 이내로 요약)
애플리케이션을 어느환경에서나 쉽게 실행할수있도록, 앱의 구동환경같은 필요한 모든 요소를 포함하여 패키징하는 기술

2. 도커란 무엇입니까? (100자 이내로 요약)
컨테이너를 사용할 때 컨테이너를 쉽게 내려받거나 공유하고 구동할 수 있도록 해주는 도구가 컨테이너 런타임입니다. 그중 가장 유명한 것이 도커죠.

3. 도커 파일, 도커 이미지, 도커 컨테이너의 개념은 무엇이고, 서로 어떤 관계입니까?
- 도커 파일 : 도커 이미지를 생성하기 위해 작성하는 스크립트 파일
- 도커 이미지: 컨테이너로 올리기 위해 만들어놓은 읽기 전용 템플릿
- 도커 컨테이너: 도커 이미지를 기반으로 실행하여 만들어진 가상화 환경

## 커리큘럼
[제 1 강] 컨테이너 기술에 대해서 알아보고, Docker의 기본 개념과 사용법에 대해 알아보자!
[제 2 강] 로컬 환경에서 도커를 활용해보자!
[제 3 강] 도커를 활용하는 클라우드 서비스에 대해 알아보자!
[제 4 강] 도커를 활용하여 나만에 클라우드 백엔드 서버를 만들어 보자!


## [제 1 강] 컨테이너 기술에 대해서 알아보고, Docker의 기본 개념과 사용법에 대해 알아보자!
### 1. Docker 란 무엇일까?_컨테이너 기술과 가상화 기술에 대하여
- 컨테이너 기반 가상화 도구
- 애플리케이션을 컨테이너라는 단위로 격리하여 실행하고 배포하는 기술

#### Container 란 무엇일까?
- 컨테이너는 가상화 기술 중 하나
- 호스트 운영체제 위에 여러 개의 격리된 환경을 생성
- 각각의 컨테이너 안에서 애플리케이션을 실행

#### 가상화 (Virtualization) 기술이란 무엇일까?
**하나의 물리적인 컴퓨터 자원**(CPU, 메모리, 저장장치 등)을
**가상적으로 분할**하여 여러 개의 **가상 컴퓨터 환경**을 만들어 내는 기술
이를 통해 물리적인 컴퓨터 자원을 더욱 **효율적**으로 사용할 수 있으며, 
서버나 애플리케이션 등을 운영하는데 있어 유연성과 안정성을 제공합니다.

#### 하이퍼바이저? 
- 가상화 기술중의 하나
- 가상 머신(Virtual Machine, VM)을 생성하고 구동하는 소프트웨어
- OS에 자원을 할당 및 조율
- OS들의 요청을 번역하여 하드웨어에 전달

#### Virtual Machine VS Container
- 하이퍼바이저 : OS위에 하이퍼바이저가 존재하고 그 위에 가상머신 이미지마다 게스트OS를 설치하여 App을 구동
- 컨테이너 : OS위에 컨테이너 엔진이 존재하고 그위에 게스트OS 설치 없이 App을 구동

#### 다시 Docker 란 무엇일까?
- 컨테이너 기반 가상화 도구
- 애플리케이션을 컨테이너라는 단위로 격리하여 실행하고 배포하는 기술
- 리눅스 컨테이너 기술인 LXC(Linux Containers) 기반
- 다양한 운영체제에서 사용할 수 있으며, 컨테이너화된 애플리케이션을 손쉽게 빌드, 배포, 관리할 수 있는 다양한 기능을 제공
- 위 기능들을 통해 애플리케이션을 빠르게 개발하고, 효율적으로 배포, 관리할 수 있음


### 2. Docker 란 무엇일까?_Docker의 내부 구조에 대하여
#### Docker Architecture
##### 도커 데몬(Docker daemon = dockerd) 
- 도커 엔진의 핵심 구성 요소
- 도커 호스트에서 컨테이너를 관리하고 실행하는 역할
- 컨테이너를 생성, 시작, 중지, 삭제하는 등의 작업을 수행
- 컨테이너 이미지를 관리하고
- 외부에서 이미지를 다운로드하고 빌드하는 작업을 수행

##### 도커 클라이언트 (Docker Client) 
- Docker와 상호 작용
- docker 명령어(docker run/build/pull)를 사용하면 Docker daemon으로 보내어 실행

##### 도커 오브젝트 (Docker Object) 
- 도커 이미지 (Docker Image) 
: 도커 컨테이너를 만들기 위한 읽기 전용 템플릿
- 도커 컨테이너 (Docker Container) 
: 한 도커 이미지의 실행 가능한 인스턴스
: 애플리케이션을 실행하기 위한 모든 파일과 설정 정보를 포함하는 패키지


##### 도커 레지스트리 (Docker Registries) 
도커 이미지 (Docker Image) 를 관리하고 저장하는 곳
- Docker hub: 디폴트 레지스트리, 누구나 접근 가능한 공개형 저장


### 3. Docker 사용해보자!
#### Docker CLI
- Download an image from a registry 
docker pull [OPTIONS] NAME[:TAG|@DIGEST] 

- List images 
docker images [OPTIONS] [REPOSITORY[:TAG]]

- Create and run a new container from an image 
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]```

- Stop one or more running containers 
docker stop [OPTIONS] CONTAINER [CONTAINER...]

- Fetch the logs of a container 
docker logs [OPTIONS] CONTAINER

- Remove one or more containers 
docker rm [OPTIONS] CONTAINER [CONTAINER...]

- Remove one or more images 
docker rmi [OPTIONS] IMAGE [IMAGE...]

https://github.com/drum-grammer/docker-pro-wanted/blob/main/le




