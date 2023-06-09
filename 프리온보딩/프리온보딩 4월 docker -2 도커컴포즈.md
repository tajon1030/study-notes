

# 프리온보딩 백엔드 챌린지 4월 docker

## 커리큘럼
[제 1 강] 컨테이너 기술에 대해서 알아보고, Docker의 기본 개념과 사용법에 대해 알아보자!
[제 2 강] 로컬 환경에서 도커를 활용해보자!
[제 3 강] 도커를 활용하는 클라우드 서비스에 대해 알아보자!
[제 4 강] 도커를 활용하여 나만에 클라우드 백엔드 서버를 만들어 보자!


## [제 2 강] 로컬 환경에서 도커를 활용해보자!

### 1. 도커 컴포즈란 무엇인가?
- 도커 컨테이너를 일괄적으로 정의하고 제어하는 도구
- 설정 파일을 도커 CLI로 번역하는 역할

[도커 컴포즈를 활용한 예제](https://github.com/drum-grammer/docker-pro-wanted/blob/main/local-infra.yml)
```yaml
version: '3.0'

services:
  mariadb10:
    image: mariadb:10
    ports:
     - "3310:3306/tcp"
    environment:
      - MYSQL_ROOT_PASSWORD=my_db_passward
      - MYSQL_USER=docker_pro
      - MYSQL_PASSWORD=docker_pro_pass
      - MYSQL_DATABASE=docker_pro
  redis:
    image: redis
    command: redis-server --port 6379
    restart: always
    ports:
      - 6379:6379
  rabbitmq:
    image: rabbitmq:3-management-alpine
    container_name: 'rabbitmq'
    ports:
        - 5672:5672
        - 15672:15672
    volumes:
        - ~/.docker-conf/rabbitmq/data/:/var/lib/rabbitmq/
        - ~/.docker-conf/rabbitmq/log/:/var/log/rabbitmq
    networks:
        - rabbitmq_go_net

networks:
  rabbitmq_go_net:
    driver: bridge
```
#### 도커 컴포즈 파일 구성
- version 
https://docs.docker.com/compose/compose-file/compose-file-v3/
- services 
	- 실행하려는 컨테이너들을 정의하는 역할
	- 이름, 이미지, 포트 매핑, 환경 변수, 볼륨 등을 포함
	- 해당 정보를 가지고 컨테이너를 생성하고 관리
- network 
- volume 
- config 
- secret


#### 도커 컴포즈 명령어

    docker-comopse -f local-infra.yml up -d 

up: 도커 컴포즈 파일로, 컨테이너를 생성하기
-f: 도커 컴포즈 파일 지정하기
-d: 백그라운드에서 실행하기

### 2. 도커 컴포즈 실습
#### CLI로 여러개 컨테이너 관리하기
도커 네트워크 생성 

    docker network create wordpress_net

도커 이미지 CLI 명령어 실행
```
# mysql db container 생성
docker \
run \
 --name "db" \
 -v "$(pwd)/db_data:/var/lib/mysql" \
 -e "MYSQL_ROOT_PASSWORD=root_pass" \ 
 -e "MYSQL_DATABASE=wordpress" \ 
 -e "MYSQL_USER=docker_pro" \ 
 -e "MYSQL_PASSWORD=docker_pro_pass" \ 
 --network wordpress_net \ 
mysql:latest
```
```
# wordpress container 생성 
docker \
 run \
 --name app \
 -v "$(pwd)/app_data:/var/www/html" \ 
 -e "WORDPRESS_DB_HOST=db" \ 
 -e "WORDPRESS_DB_NAME=wordpress" \ 
 -e "WORDPRESS_DB_USER=docker_pro" \ 
 -e "WORDPRESS_DB_PASSWORD=docker_pro_pass" \ 
 -e "WORDPRESS_DEBUG=1" \ 
 -p 8000:80 \ 
 --network wordpress_net \ 
wordpress:latest
```

#### 도커 컴포즈로 여러개 컨테이너 관리하기
정리된 컴포즈 파일을 up 해주면 끝

    docker-compose -f docker-compose.yml up --build


#### 참고 - 컴포즈 파일 구성
- image: 컨테이너를 생성할 때 쓰일 이미지 지정
- build: 정의된 도커파일에서 이미지를 빌드해 서비스의 컨테이너를 생성하도록 설정
- environment: 환경 변수 설정, docker run 명령어의 --env, -e 옵션과 동일
- command: 컨테이너가 실행될 때 수행할 명령어, docker run 명령어의 마지막에 붙
는 커맨드와 동일
- depends_on: 컨테이너 간의 의존성 주입, 명시된 컨테이너가 먼저 생성되고 실행
- ports: 개방할 포트 지정, docker run 명령어의 -p와 동일 (포트 포워딩)
- expose: 링크로 연계된 컨테이너에게만 공개할 포트 설정
- volumes: 컨테이너에 볼룸을 마운트함
- restart: 컨테이너가 종료될 때 재시작 정책
	- no: 재시작 되지 않음
	- always: 외부에 영향에 의해 종료 되었을 때 항상 재시작 (수동으로 끄기 전까지)
	- on-failure: 오류가 있을 시에 재시작



