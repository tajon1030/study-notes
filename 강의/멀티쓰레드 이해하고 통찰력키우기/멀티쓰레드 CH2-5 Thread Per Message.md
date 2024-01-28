# Backend 멀티쓰레드 이해하고 통찰력 키우기  
섹션2 : 멀티스레드 코딩 이런식으로 하더라(코드_c#)  

## Thread Per Message - Thread 마다 작업을 위임할 수 있어요
- Thread Per Message 패턴
- Task Class

### Thread Per Message 패턴
어떤 작업을 다른 쓰레드에서 실행하도록 위임하는 것  
하나의 작업당 하나의 쓰레드를 만드는 것이다.  
쓰레드 갯수가 너무 많아지면 컨텍스트 스위칭이 일어났을때 성능이 저하될수있으므로 주의해야한다.  

### 코드 c#  
[Thread Per Message 패턴](https://github.com/myc0058/multi-thread/blob/master/src/Section8.cs)    
직접구현하지않고 TaskClass라는 것을 사용하여 구현한다.  

###읽어볼것
https://12bme.tistory.com/379

## 참고  
https://github.com/myc0058/multi-thread.git  


