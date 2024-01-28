# Backend 멀티쓰레드 이해하고 통찰력 키우기  
섹션2 : 멀티스레드 코딩 이런식으로 하더라(코드_c#)  

## Balking - 불이 켜지면 일하세요~
- Balking
- Guarded Suspension과 Balking의 차이

### Balking 패턴
내가 해야될 작업이 있는지 주기적으로 확인하는것  
작업이 있으면 하고 없으면 무시  

### Guarded Suspension 코드와 공통점과 차이점
두 패턴 모두 할일이 있을때만 동작하게 하는 코드  
- Guarded Suspension패턴  
: 할일이 없으면 쉬고, 할일이 생기면 깨운다.  
: 해야될 작업이 없을때 CPU자원을 DoClient쓰레드에 집중할당할 수 있다.  
- Balking 패턴  
: 할일이 없으면 무시. 할일이 있으면 한다.  
: DoServer쓰레드에서 할일이 없더라도 뭔가를 할 수도 있음 (로그찍기, 오랫동안 데이터가 없을때 알람보내기 등)  


### 코드 c#  
[GuardedSuspension패턴](https://github.com/myc0058/multi-thread/blob/master/src/Section4.cs)  
[Balking패턴](https://github.com/myc0058/multi-thread/blob/master/src/Section5.cs)  



## 참고
https://github.com/myc0058/multi-thread.git  


