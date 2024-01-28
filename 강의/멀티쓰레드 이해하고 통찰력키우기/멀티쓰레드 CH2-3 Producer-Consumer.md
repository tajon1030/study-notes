# Backend 멀티쓰레드 이해하고 통찰력 키우기  
섹션2 : 멀티스레드 코딩 이런식으로 하더라(코드_c#)  

## Producer-Consumer - 내가 만들게, 너는 가져가
- Concurrent Collection
- Producer Consumer 패턴
- Server Thread Model

### **Concurrent** Collection
- 멀티스레드 환경에서 편하게 사용해도 안전함  
- 망가뜨릴래야 망가뜨릴수가 없는 클래스  
- 이런 Class나 Function을 **Thread Safe**하다 라고함

c#에서는 ConcurrentBag이라는 클래스를 사용한다.  

### Producer Consumer 패턴
- 한쓰레드에서는 데이터를 만들기만하고 다른스레드에서는 소비하기만 하는 패턴을 말한다.  

### Server Thread Model
#### IOCP, EPoll
Windows에는 IOCP 리눅스에는 EPoll이라는것이 있는데,  
OS에서 제공하는 비동기 IO작업을 하기위한 기술이다.  
쉽게설명하자면 내가 IO요청을 하면 비동기로 처리해주고 결과도 비동기로 받게되는 것  

#### Server Thread Model  
네트워크카드가 데이터를읽으면 io쓰레드에서 읽은데이터를 jobqueue로 넘겨주고, jobqueue안에 있는 내용을 worker쓰레드가 처리를 하는것  
네트워크카드 메모리가 작기때문에 io쓰레드에서 워커쓰레드에서 하는일을 같이 하고있을경우에 io쓰레드에서의 실행시간이 오래걸릴것이고 네트워크카드의 작은 메모리안에 데이터들이 꽉차서 더이상 패킷을 못받을수있다.  
그래서 io쓰레드에서는 빠르게 jobqueue에 작업을 넣는 작업만 하고 빠지고 worker쓰레드에서는 io쓰레드보다 비교적 오래걸리는 시간의작업들(jobqueue에 넣어진 작업들)을 실행한다.  
<img src="https://github.com/tajon1030/study-notes/assets/60431816/5f0811f8-b855-4b33-9852-19f0fdfcdcdc" width="500" height="300">  

요약하자면 네트웍카드의 메모리는 크지않기때문에 IO스레드에서 모든것을 다 할수없으며 Worker쓰레드에서 동작할 코드도 빨리 실행되도록 하는것이 좋다.  
IO쓰레드와 Worker쓰레드가 ProducerConsumer패턴과 같다  

### 코드 c#  
[Producer Consumer 패턴](https://github.com/myc0058/multi-thread/blob/master/src/Section6.cs)    


## 참고
https://github.com/myc0058/multi-thread.git  


