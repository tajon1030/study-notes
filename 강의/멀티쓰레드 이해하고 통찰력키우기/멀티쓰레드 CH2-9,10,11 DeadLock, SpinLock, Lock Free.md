# Backend 멀티쓰레드 이해하고 통찰력 키우기  
섹션2 : 멀티스레드 코딩 이런식으로 하더라(코드_c#)  

## Dead Lock - 꽉 막혔어요~~  
서로 Lock 오브젝트가 두개가 있는데, 두개의 스레드가 순서를 달리하여 획득하려했을때 한쓰레드나 혹은 두쓰레드 모두 다 그 락을 획득하지 못하고 블럭킹되어 영원히 스레드가 동작하지않는 형태(교착상태)  
데드락이 발생할수있기때문에 락을 중첩시키면 굉장히 위험하다.  

## Spin Lock - Context Switching 없이 Lock 걸기
루프를 계속 돌면서 락을 획득할수있을때까지 기다렸다가 락을 획득하면 처리  
스레드가 계속 CPU를 점유하고있기때문에 효율을 높일 수 있다.  
많은 시간이 걸리는 작업이 들어가면 CPU낭비  

## Lock Free - 금단의 방법
lockFree > waitFree  
알고만있고 쓰지맙시다.  
코드가 복잡해지면 롤백처리도 힘들고 어렵다.  

### 코드 c#  
[Dead Lock](https://github.com/myc0058/multi-thread/blob/master/src/Section12.cs)    
[Spin Lock](https://github.com/myc0058/multi-thread/blob/master/src/Section13.cs)    
[Spin Lock](https://github.com/myc0058/multi-thread/blob/master/src/Section14.cs)    