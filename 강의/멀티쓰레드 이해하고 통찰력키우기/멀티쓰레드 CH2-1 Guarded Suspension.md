# Backend 멀티쓰레드 이해하고 통찰력 키우기  
섹션2 : 멀티스레드 코딩 이런식으로 하더라(코드_c#)  

## Guarded Suspension - 멈춰!, 일해라 핫산!  
- Write-Through Wirte-Back
- CPU Cache Hit, Miss
- No Allocate, Allocate
- Memory Barrier(or Fence)
- Lock
- Guarded Suspension

### Write-Through, Wirte-Back 
- Write-Through : CPU 캐시에 쓰기 즉시 main memory에도 쓰여짐  
- Wirte-Back(Lazy Write) : main memory 에 지연된 쓰기를 함  

### CPU Cache Hit, Miss  
- Cache Hit : read나 write 하려는 메모리가 캐시에 있으면 Hit됐다고 함  
- Cache Hit : read나 write 하려는 메모리가 캐시에 없으면 캐시Miss가 됐다고함

### Allocation, No Allocation
write를 하려는데 캐시미스가 발생했을때  
- No Allocation : 바로 메모리에 씀
- Allocation : 메인메모리에서 캐시로 데이터를 가져온 뒤 캐시에 씀  
쓰여진 캐시데이터는 캐시버퍼가 메모리에 쓴다.  

### Dirty Flag
캐시버퍼가 캐시에 있는 데이터의 수정여부를 체크하기위해 사용되는 변수/메모리  
CPU 캐시 -> main memory로 write를 할지 말지 결정하게된다.  
캐시서버가 rdb로 영구저장될때도 사용함  


### 코드
~~~cs
// on one thread
counter += 1; //normal int    // 1 4
flag = true; // flag is volatie-항상최신보장  // 2

// on another thread
if(flag){	// 3
	foo(counter); // 5
}
~~~
counter가 0이고 주석숫자순서대로 실행될경우 5에서 counter는 2가 된다.

### Memory Barrier(or Fence)
reordering 방지, 가시성 제공  

- read memory barrier : read만 막는다.  
- write memory barrier : write만 막는다.  
- full memory barrier : read/write 둘다 막음

보통 메모리배리어라함은 full memory barrier을 의미

memory barrier 를 이용하여 멀티스레드 프로그래밍을 하는 것은 어려운일이므로,  
Lock, Monitor, volatile(java), synchronized(java)와 같은 쓰기 쉬운 방법을 쓰자


### Lock
reordering방지, 가시성, 원자성이 있음  
~~~cs
int sharedNum = 0;
object lockObj = new object();

// 여러 쓰레드에서 실행
lock(lockObj){  // lock블럭
	sharedNum++; 
// Atomic Operation이 아니기때문에 문제가 발생하니 
//lock을 걸어서쓰레드마다 어느 한 순간에는 한쓰레드만 실행되도록 만든 것
}
~~~
lock블럭을 크리티컬섹션이라고도 한다.(임계구간)  
락블럭안에서 실행시간이 오래걸리면 성능저하가 발생한다.  

### Guarded Suspension 패턴
할일이 없는 쓰레드는 대기열에 넣고 할일이 생기면 대기열에서 빼서 실행하게 해주는 패턴  
- Monitor.Wait() : 실행을 중지하고 대기열로 감  
- Monitor.PulseAll : 대기열에 있는 모든 쓰레드를 깨움  

위 두 함수는 락 블럭 안에서만 사용해야한다.  


## 참고
https://github.com/myc0058/multi-thread.git  


