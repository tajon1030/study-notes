# docker에서 mssql 설치하여 활용하기
DB툴로는 dbeaver를 이용하고 mssql을 도커로 설치하여 이용해보려고 하였다.  

### 1. 이미지 다운받기
도커 컨테이너를 띄우기 위해서는 먼저 mssql 이미지를 pull 받아야한다.  
`docker pull [이미지명]` 을 사용하여 pull 받아올 수 있다.  
mssql 도커 이미지명은 [여기](https://hub.docker.com/_/microsoft-mssql-server)에서 확인  
이미지 버전을 명시하지않아서 기본 버전인 latest 버전을 설치하였다.  
설치 완료 후 `docker images`를 통해 이미지가 땡겨와졌는지 확인한다.  

~~~bash
C:\Users\dj>docker pull mcr.microsoft.com/mssql/server
Using default tag: latest
latest: Pulling from mssql/server
25fa6962a0ca: Pull complete
22fbfac82290: Pull complete
f57446ead6b1: Pull complete
Digest: sha256:136be187bb12c94b150eb3e48fbc26ae62a81d39a2c7c913be2f3d7ebbddfbad
Status: Downloaded newer image for mcr.microsoft.com/mssql/server:latest
mcr.microsoft.com/mssql/server:latest

C:\Users\dj>docker images
REPOSITORY                       TAG       IMAGE ID       CREATED        SIZE
mcr.microsoft.com/mssql/server   latest    ffdd6981a89e   2 months ago   1.58GB
~~~


### 2. 실행하자마자 꺼지는 문제 발생
이미지를 pull받아왔으니까 이제 이를 이용해서 컨테이너를 구동시켜야한다.  
기본적으로 그냥 구동을 하면 실행후에 바로 종료되기때문에 백그라운드에서도 계속 돌아가게하기위해 -d 옵션을 줘서 컨테이너를 실행시켰다.  
명령어를 실행시키고 컨테이너 구동 상황을 확인해보았는데 `docker ps -a`  
컨테이너가 바로 Exited된것을 확인할 수 있었다.  
~~~bash
C:\Users\dj>docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=password' -e 'MSSQL_PID=Express' -d -p 1433:1433 ffd
8c6db57e6eef9515bb08852e8ad8adef78689cd3a4ea4981c99410c55153a834

C:\Users\dj>docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS                      PORTS     NAMES
8c6db57e6eef   ffd       "/opt/mssql/bin/perm…"   6 seconds ago   Exited (255) 1 second ago             gracious_newton
~~~

#### 로그확인 결과
왜이런 상황이 발생한것일까?  
그냥 docker image가 -d옵션을 줬음에도 바로 종료된다는 식으로 검색을 하면 패스워드를 조건에 맞게 지정하지 않았다는 등의 원인해결을 확인할 수 있는데, 이번 경우에는 패스워드를 조건에 맞게 잘 지정하였다.  
이에따라 문제의 원인을 정확하게 파악하기위해 `docker logs [컨테이너명]` 명령어를 사용하여 구동 상황시 어떤 일이 일어났는지 로그를 확인해 보았다.  
~~~bash
C:\Users\dj>docker logs 8c
SQL Server 2022 will run as non-root by default.
This container is running as user mssql.
To learn more visit https://go.microsoft.com/fwlink/?linkid=2099216.
The SQL Server End-User License Agreement (EULA) must be accepted before SQL
Server can start. The license terms for this product can be downloaded from
http://go.microsoft.com/fwlink/?LinkId=746388.

You can accept the EULA by specifying the --accept-eula command line option,
setting the ACCEPT_EULA environment variable, or using the mssql-conf tool.
~~~


#### 검색 결과
해당 오류를 검색해본 결과 [다음과 같은 글](https://stackoverflow.com/questions/64319491/sql-server-2019-in-docker-you-can-accept-the-eula-by-specifying-the-accept-eu)이 나온다.  
원인인 즉슨, 옵션명령어를 날릴때 쌍따옴표를 사용해서 명령어를 실행해야했는데 따옴표를 사용해서 그런것으로  
따옴표를 쌍따옴표로 변경해서 확인해보니 종료되지 않고 잘 실행되고있음을 확인할 수 있었다.  
~~~bash
C:\Users\dj>docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=password" -e "MSSQL_COLLATION=korean_wansung_ci_as" -e "MSSQL_PID=Express" -d -p 1433:1433 ffd
e146f45bea479515bb08852e8ad8adef78689cd3a4ea4981c99410c55153a834

C:\Users\dj>docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                    NAMES
e146f45bea47   ffd       "/opt/mssql/bin/perm…"   8 seconds ago   Up 8 seconds   0.0.0.0:1433->1433/tcp   silly_fermi
~~~

#### 주의해야할점 - 추후 한글이 물음표로 나오는 현상과 관련
사실 처음 명령어를 날려줄때 MSSQL_CLOOATION 옵션을 설정해주지 않고 컨테이너를 구동시켜서 mssql을 사용했는데,  
한글을 insert한다음 조회해봤더니 문자가 ? 로 조회되었다.  
collation이 문자데이터 정렬 방식을 지정하는 명령어라는데,  
sql편집기로 확인해 볼 수 있다.  
~~~sql
select serverproperty('collation')
~~~
Latin1로 나오는 collation을 Korean_Wansung 으로 바꿔주기위하여 처음 설치시 옵션명령어를 추가해준 것이다.  

참고 : https://www.nextstep.co.kr/93  


### 3. credentials
여튼 컨테이너를 구동시켰으니 dbeaver에서 연동을 시켜주면 되는데 username과 password를 어떤것을 입력해야하는지 헷갈렸다.  
이또한 검색을 해보니 [다음과 같은 글](https://stackoverflow.com/questions/68238963/what-are-the-default-sql-server-credentials-created-via-docker)을 확인할 수 있었다.  
컨테이너의 bash셸에 들어가서 username과 password를 설정해줄 수 있고(여기서는 username:admin / password:admin)  
해당 사용자에게 sysadmin의 역할을 부여해주었다.  
~~~bash
C:\Users\dj>docker exec -it e14 "bash"
mssql@e146f45bea47:/$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'password'
1> create login admin with password = 'admin', check_policy = off
2> exec master..sp_addsrvrolemember @loginame = 'admin', @rolename = 'sysadmin'
3> go
~~~




사실 전체적으로 [이걸](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver16&preserve-view=true&pivots=cs1-bash) 보고 따라하면 좋다.(공식문서가 왜 공식문서겠는가..)  
