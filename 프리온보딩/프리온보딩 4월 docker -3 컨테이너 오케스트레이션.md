

# 프리온보딩 백엔드 챌린지 4월 docker

## 커리큘럼
[제 1 강] 컨테이너 기술에 대해서 알아보고, Docker의 기본 개념과 사용법에 대해 알아보자!
[제 2 강] 로컬 환경에서 도커를 활용해보자!
[제 3 강] 도커를 활용하는 클라우드 서비스에 대해 알아보자!
[제 4 강] 도커를 활용하여 나만에 클라우드 백엔드 서버를 만들어 보자!


## [제 3 강] 도커를 활용하는 클라우드 서비스에 대해 알아보자!

### 컨테이너 오케스트레이션?
컨테이너의 배포, 관리, 확장, 네트워킹을 자동화 하는 기술을 말한다.

### 컨테이너 오케스트레이션 툴
- 도커 스웜
- Kubernetes
- GCP 
	- GKE (Google Kubernetes Engine) 
-  AWS 
	- EKS (Elastic Kubernetes Service) 
	- ECS (Elastic Container Service)


### ECS (Amazon Elastic Container Service) 
[공식 문서](https://docs.aws.amazon.com/ko_kr/ecs/index.htm)
#### 종류
**1. EC2** 
 - 컨테이너가 운영되는 자원이 AWS EC2
 - 용량공급자(Capacity Providers)를 통해 EC2
   Auto-ScalingGroup을 연결
 - ECS에서 제공하는 관리형 지표
   "CapacityProviderReservation"에 따라 EC2를 용량을 추가/제거 할 수 있으며, 컨테이너의 숫자의
   증가/축소에 따라 EC2도 함께 증가/축소하게 됩니다.
  - EC2 유형 비용: 호스트로 사용하는 EC2 요금만 과금

 **2. Fargate**
- 서버리스 유형으로, EC2를 배포하거나 관리할 필요 없이 그냥 서비스만 운영
- 컨테이너가 어디서 운영되는지 관리할 필요 없음
- *Fargate 유형 비용: 시간당 vCPU, Storage 용량 비용이 부과

**3. External**
- AWS 인프라가 아닌 호스트에서 ECS에서 정의한 서비스
- 호스트&컨테이너 등 실제 서비스는 물리적으로 AWS 밖에서 동작
- AWS 콘솔에서 관리
