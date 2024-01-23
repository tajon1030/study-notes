## 목차
Ch1. 반드시 알아야만 하는 개념들
- Git Flow 전략
- Multi Module 프로젝트
- Profile

Ch2. 초보 개발자티 벗어나기
- 비동기 프로그래밍
- Feign Client
- Logback

Ch3. 운영 배포를 해보자
- 배포파일을 운영서버로 전송하는 방법
- 운영배포전 체크리스트

Ch4. 개발을 좀더 수월하게



## Git Flow 전략
### 기본명령어
- commit
- push
- pull

### git flow 전략
branch 관리 전략  

### 주요 branch
- main
- dev : 다음 배포에 나갈 피처 건들을 merge
- feature
- release : dev베이스로 배포 전 release 브랜치 생성
- hotfix : 의도치않은 장애상황

### 시나리오
1. release branch 생성 후 추가작업 필요한 경우  
=> release에 추가작업 merge 하고 main으로 merge / dev는 main의 내역을 merge하여 sync  
2. release branch 생성 후 추가작업 없는 경우  
=> dev -> release생성하고 release에서 main으로 merge / dev는 main의 내역을 merge하여 sync  
3. hotfix가 나가야할 상황  
=> main -> hotfix -> feature/ 최소한의 수정범위를 갖는 브랜치를 hotfix베이스로 생성하여 hotfix에 merge하고 main이 hotfix를 merge하고 dev는 main을 merge  

### 정기배포를 위한 gitflow 전략
main -- dev -- feature/login
		 |__ feature/logout

피처완료후 dev에 merge하고 배포를 위해 release branch 생성  
릴리즈브랜치 생성된 이후부터는 무조건 릴리즈 브랜치를 베이스로 생성해야한다.  
login/logout feature 전부 개발후 merge하고 release브랜치 생성후에 findPW feature가 새로 필요하다면 릴리즈브랜치에 merge  
이후 릴리즈를 main에 merge  
main에 추가된 작업내용을 dev에 main을 merge함으로서 sync를 맞춘다.  
=> sync를 맞추는 이유 : dev는 main을 base로 생성된 branch라는 전제이기때문  