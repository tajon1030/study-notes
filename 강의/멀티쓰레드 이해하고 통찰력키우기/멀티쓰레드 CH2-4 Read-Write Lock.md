# Backend 멀티쓰레드 이해하고 통찰력 키우기  
섹션2 : 멀티스레드 코딩 이런식으로 하더라(코드_c#)  

## Read-Write Lock - 다 같이 읽는 건 괜찮지만 읽을 때 쓰면 안돼요
- Interlocked Class
- Read-Write Lock 패턴
- ReaderWriterLock Class

### Interlocked 클래스
원자성을 지원함(가시성과 reordering 방지는 지원안함)

### Read-Write Lock 패턴
Read Lock과 Write Lock을 따로두어 Read할 때에는 다른쓰레드가 Read할수있지만  
Write할때에는 Read, Write 둘다 할 수 없다.  
Read, Write할때 같은 Lock을 거는 것보다 Read성능을 올릴 수 있다.  
c#에서는 ReaderWriterLock Class라는것을 이용한다.  

### 코드 c#  
[Read-Write Lock패턴](https://github.com/myc0058/multi-thread/blob/master/src/Section7.cs)    

### 읽어볼것  
https://parkcheolu.tistory.com/25  

## 참고  
https://github.com/myc0058/multi-thread.git  


