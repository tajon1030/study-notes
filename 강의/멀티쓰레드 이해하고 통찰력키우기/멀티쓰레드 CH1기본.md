#  섹션1 : 알건 알고 시작합시다(이론)
## 프로세스와 스레드는 무엇일까
### 프로세스와 스레드
실행파일(exe,dll,etc..)을 실행시키면 하나의 프로세스가 생성  
프로세스안에 스레드가 자동으로 만들어진다.  
이 스레드를 보통 메인스레드라고 부른다.  

### 멀티스레드
한 프로세스안에 메인스레드외에 다른 스레드가 있으면 멀티스레드  
but 스레드 간에 아무런 메모리 공유가 일어나지 않는다면 멀티스레드라고 부르기 애매함 

### 면접질문
Q. 프로세스와 스레드의 차이  
A. 스레드끼리는 메모리공유가 됨  
프로세스끼리는 메모리 공유가 안됨

### 스레드간의 메모리공유
모든 스레드가 하나의 큐를 공유하면 당연히 안괜찮음 -> 이런 문제를 피하는 제어를 배타제어라고 함

### 배타제어 하는 법 1 concurrent
- 처음부터 망가뜨릴수없는 오브젝트를 만듦(concurrent가 prefix로 붙는 클래스를 사용)  
 - concurrent클래스가 어떻게 구현되어있느냐에 따라 성능저하가 발생할 수 있음  
- 일반클래스도 read는 스레드세이프한 경우가 있음(여러스레드가 read를 해도 괜찮다-오브젝트가 망가지지않는다)  
write는 한 스레드에서만 하고 read를 여러 스레드가 하는 경우 유용함(굳이 concurrent 클래스를 쓰지않아도 된다)

### 배타제어 하는 법 2 Lock
- 특정 코드 구간을 반드시 한 스레드만 실행하도록 막음  
- 크리티컬 섹션이라고도 부름
- Lock을 건 코드구간의 실행시간이 길수록 성능저하가 발생함.  
최악의 경우 차라리 싱글 스레드가 낫다.  
- 이러한 이유로 => one 프로세스, one 스레드 아키텍처가 나왔다.

### 배타제어 하는법 3 Lock-Free
- Lock을 사용하지않고 배타제어를 하는데 목적  
- Interlocked, Increment, Atomic Operation, Lock-Free알고리즘, Non-blocking알고리즘, CAS(compare and set)

### 프로세스간의 통신
프로세스끼리는 메모리공유가 안되기때문에 통신을 해야함
HTTP, TCP 편한거 쓰면 된다~
MSA를 지향하는 현대사회에서 프로세스간의 통신은 필수다.


### 왜 멀티프로세스를 해야하는가?
마이크로서비스가 멀티프로세스인데
서버머신 한대의 성능에는 한계가 있어서 스케일아웃이 필수  
하나의 프로세스를 두대의 장비로 돌릴수는 없다.  
서버 아키텍처를 구상하는 입장에서는 프로세스하나가 작은 기능을 담는것이 훨씬 유리하기때문에(나중에 결국 쪼개야해서 처음부터 작게 만드는것이 좋다는거) one프로세스, one 스레드가 설득력을 얻음


### 프로세스간의 통신
프로세스간의 통신을 위해서 프로토콜을 만들고 통신하는 코드를 만들고 하는 작업이 여간 귀찮은일이 아니다.  
서로다른언어를 써서 만든 프로세스기리라면 더더욱 스트레스(패킷보냈는데 한쪽에서 못받았다고하고 이러면 디버깅하는데 스트레스)  
그래서 나온것이 구글 protobuf나 apache avro 

### Json은?
JsonFormat을 사용해도 되지만,  
필드가 하나 추가됐다면 어떻게 상대방에게 알려줄것인지나 오타가 있을경우 디버깅의 어려움등의 문제가 있어서 protobuf를 쓰면 편안~


### 다른방법은?
- Redis의 특정 key에 데이터를 넣고 pub/sub을 이용하는 방법도 있음   
- 빠르게 통신할 필요가 없다면 AWS SQS같은 큐에 넣고 데이터가 추가됐을때 특정 토픽으로 이벤트를 받는 방법도 가능  
- 데이터를 보내려는 서버가 알아서 다른 서버에 보내주는것이 아닌 올려놓고 알아서 가져가라 라는 방식

## 스레드 흐름을 어떻게 컨트롤하지?
스레드란 흐르는 시냇물위에 놓인 돗단배와 같다.  
물위에 올려놓으면 어디론가 수명을 다할때까지 끊임없이 흘러감  
종이배를 물위에 올려놓는행위(스레드스타트) -> 흘러나감(계속 무언가 원하는 작업들을 계속 진행)  

### 엔트리포인트(진입점)이란?
~~~java
public static void main(String[] args){
...
}
~~~
프로세스가 맨 처음 실행하는 함수  
메인쓰레드에서 실행됨  
위 함수 실행이 종료되면 프로세스도 파괴된다.  

### Thread.Start()
스레드의 start와 join만 알고 넘어가자!
~~~cs
var thread = new Thread(Func); //스레드 객체를 하나 만듦
thread.start(); // 스레드객체에서 스타트 실행
~~~
스레드 생성자에 넣어준 함수를 별도의 스레드에서 실행함

### Thread.Join()
~~~cs
var thread = new Thread(Func);
thread.Start();
// 스레드가 종료될때까지 대기(blocking)함 
thread.Join();
~~~

### blocking vs nonblocking
- 함수를 실행하고 모든 코드가 완료된 후 리턴되면 blocking
- 실행한 함수의 코드가 완료되지않고 리턴되면 non-blocking
- non-blocing 함수를 실행하고 완료됨을 어떻게 알 수 있을까? => 폴링방식 & 이벤트 방식

### Polling
~~~cs
while(true){
	if(isFinish == true}{
		Break;
	}
	sleep(1000);
}
~~~
=> 주기적으로 확인함 ex)HTTP통신  
http는 서버에 request요청을 해야 return을 해주는데 
request를 하고 response를 받고를 반복

### Event
~~~js
// 1초 뒤에 콜백함수를 실행
setTimeout(callback, 1000);

function callback(){
...
}
~~~
Event가 발생했을때 내가 원하는 함수를 호출해줌  
작업이 완료됐을때 이벤트가 발생할 수도 있고 여러개의 작업을 동시에 진행하면 작업이 하나하나 완료될때마다 콜백을 호출해 줄 수도 있음 그래서 생기는 문제가 콜백지옥인데 가독성도 떨어지고 실행순서가 헷갈리게되고

### 면접질문
Q 그럼요즘에는?  
A. async & await 
Q. 장점은?

### async & await
~~~cs
// 함수 선언시 async
public async function Task<String> GetString(){
...
}

// 함수사용시 await
String result = await GetString();
Console.Write(result);
~~~
GetString함수는 Blocking 방식으로 호출되지만 다른 Thread에서 실행됨  
실행은 비동기 방식은 블록킹  
=> 멀티스레드 프로그래밍을 하고있지만 블럭킹방식으로 진행되고있어서 편하고 콜백지옥도 발생하지 않는다

## 스레드 우아하게 종료하기
CPU 캐시, Stale Data(오래된 데이터), ReOrdering(재정렬), Visibility(가시성), Atomicity(원자성), Contet Switching, Thread우아한 종료

### 멀티스레드 프로그래밍을 하면 생기는 문제
CPU가 두개일 경우 각자 사용하는 캐시와 함께 공통으로 사용하는 캐시가 있는데 이 캐시는 램의 메인메모리에서 데이터를 읽을때 캐싱을 한다.  
메모리 접근 속도보다 CPU발전속도가 훨씬 빠르기때문에 그로인한 문제를 메모리월(memory wall)이라고 하고 그래서 CPU에 캐시를 둬서 속도를 개선하는데 이게 멀티쓰레드일때 문제가 생긴다.  


#### 오래된 데이터 Stale Data
DoWorkA함수와 DoWorkB함수가 서로 다른스레드에서 실행되고, 다른CPU에서 실행되고 있다는 시나리오  
~~~cs
bool stop = false; // 1

function DoWorkA(){
	stop = true; // 3
}

function DoWorkB(){
	int count = 0;
	while(stop == false){ //2 // 3 이후 루프를 돌아서 다시 실행
		count++;
	}
}
~~~  
CPUA - Thread A - DoWorkA  
CPUB - Thread B - DoWorkB  

코드를 보면 처음에 stop = false 니까 2에서 stop == false 조건에 맞다.  
그래서 카운터가 실행되는데, 3에서 stop을 true로 해주면 다시 비교를 할때에 true여서 루프를 빠져나가야함  
근데 무한루프가 걸려버림!  
1. 처음 메인메모리에는 stop = false  
2. DoWorkB 동작시 CPUB 캐시에 stop = false 데이터가 들어감  
3. DoWorkA 동작시 CPUA 캐시에 stop = ture 데이터가 들어가고 메인 메모리도 함께 갱신  
4. **DoWorkB 동작시 CPUB 캐시에 이미 stop = false 데이터가 있어서 stop = false라고 읽게 됨** -> 오래된 데이터를 읽음


#### 재정렬
~~~cs
int y = 0;
int x = 0;

function DoWorkA(){
	x = 100;
	y = 50;
}

function DoWorkB(){
	if(y>x){
		// Do Somethig
	}
}
~~~  
순서대로 실행되면 문제없지만 코드 최적화로 인해 y=50먼저 실행되고 DoWorkB가 실행될 수 있음  
그러면 y = 50, b=0이 되어 DoWorkB에 있는 DoSomething이 실행될 수 있다.  
디버그일때는 괜찮지만 release로 빌드하면 문제가 발생할수있어서 테스트할때 멀티스레드 프로그래밍은 릴리즈모드로 빌드하여 확인해야한다.


### 해결방법?
visibilty, atomicity, reordering 방지

#### 가시성 Visibility
앞서 말한대로 각각의 CPU는 캐시를 가지고있어서 서로 다른 스레드는 stale data를 읽을 수 있다.  
가시성이 부여되면 해당 메모리는 반드시 main memory에 갑을 쓰거나 읽어서 항상 최신의 데이터를 가져올 수 있다.  

#### Atomicity 원자성
여러 스레드에서 메모리를 공유하면 원하지 않았던 오작동을 하게된다.  
만약에 i++의 경우 Atomic Operation이 아니라 i를 읽고 1을 추가하고 값을 쓰는 코드인데,  
이를 여러 쓰레드에서 동시에 실행하면 문제가 발생한다.  
반드시 하나의 일관된 동작이 한 스레드에서만 시작하고 종료된다면 atomic operation이라고 한다.  

#### reordering 방지
~~~cs
...
int x= 1; // 1
Volatile.Write(ref y, 2);
int y2 = Volatile.Read(ref y);
int x2 = x; // 2
...
~~~
코드에서 Volatile 전과 후에 있는 코드들(1,2)은 절대로 재정렬될수없다.  
앞에있는 코드끼리, 뒤에있는 코드끼리는 재정렬 가능

#### 관련 키워드
자바는 가시성,재정렬방지,원자성 모두 지원함  
- volatile keyword  
- synchronized keyword (함수가 락이 걸린것처럼 동작을 하게 만듦)  
- lock  
- Atomic Integer( c#에서는 Interlocked.Increment)  
- Memory Barrier  

### Context Switching 이란?
CPU는 내 컴퓨터에 있는 여러 프로세스에 있는 여러 스레드들을 돌아가면서 실행시켜준다.  
프로세스나 스레드가 중단됏다가 다시 실행될때 필요한 정보를 컨텍스트라고 한다.  
현재 실행중인 컨텍스트를 잠시 중단 및 저장하고 새로운 컨텍스트를 롱딩 및 실행하는것을 컨텍스트 스위칭이라고 한다.  

#### ContextSwitching 오버헤드
컨텍스트 스위칭을 하면 이런저런일이 발생하고  
따라서 컨텍스트스위칭을 자주발생하면 성능이 떨어지게 된다.  
이런저런일에서 중요한건 캐시초기화(flush)가 일어난다는것  
(다른 코드를 수행해야하니 캐시를 비우고 새로운 메모리를 읽어서 캐싱을 함)  

#### ContextSwitching 언제 발생하는가
- sleep 함수 호출
- lock 호출
- IO 발생(네트워크IO, 파일 IO, 콘솔찍기 등)
- 단순 read, write, 연산 외에 시스템 api가 호출되면 거의 발생한다.   

## 참고
https://github.com/myc0058/multi-thread.git  


