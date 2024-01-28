# Backend 멀티쓰레드 이해하고 통찰력 키우기  
섹션2 : 멀티스레드 코딩 이런식으로 하더라(코드_c#)  

## Worker Thread - 일이 생기면 일하세요~
### 코드 c#  
[Worker Thread 패턴](https://github.com/myc0058/multi-thread/blob/master/src/Section9.cs)    
이미구현되어있는 Channels를 사용하면된다.  

## Future - 대신 처리해 줄게요. 예약하세요~
### 코드 c#  
[Future](https://github.com/myc0058/multi-thread/blob/master/src/Section10.cs)    
이미구현되어있는 Task클래스를 사용하면된다.  

## Thread-Specific Storage - Thread마다 하나씩 가질 수 있어요
쓰레드로컬을 사용하는 패턴  
### CPU Cache Line
메모리는 순서대로 나열되어있고 메모리주소는 연속된다.  
CPU의 캐시라인은 64바이트이고 일부만 쓸수없어서 64바이트를 통째로 가지고가서 라인에 적는다.  

### 캐시 적중률
CPU 적중률을 높이기위해서 시간적 지역성과 공간적 지역성이라는 말이 나온다.  
시간적지역성은 시간적으로 어떤코드가 특정시간에 수행이 되면 그 시간대에 수행되는 코드들은 특정 영역에 있는 데이터를 접근할 가능성이 많아진다는 것  
공간적지역성은 비슷한위치에 선언되어있는변수들은 비슷한 시간대에 접근할 가능성이 많다는 것  

 ### 코드 c#  
[Thread-Specific Storage 패턴](https://github.com/myc0058/multi-thread/blob/master/src/Section11.cs)    