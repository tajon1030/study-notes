# 2-1 GC의 정의와 Java GC알고리즘에 대해 살펴봅니다.

## 1. 가비지 컬렉션의 정의와 가비지 컬렉터가 처리하는 Heap 영역

### Garbage Collection  
: 자동 메모리 관리의 한 형태  
- Garbage: 더이상 참조되지않는 메모리  
개발자의 메모리 할당/해제 등 수동관리 부담을 덜어줌

### GC Tracing Step
Heap영역에 Object할당이 되어있고 Field(GC Root)들이 관련된 객체를 가리키고있다. 힙이 가득 찾을때 RootSet이 가리키고있는(참조되고있는)객체와 연관된 객체들을 다 마킹해주면 아무도 참조를 안하는 부분이 나온다. 그것이 Garbage이고 그 영역을 비우게 된다. 이후 빈 영역을 Compact작업을 통해 붙이면 남겨진부분에 이어서 메모리를 사용한다.

GC Root가 가리키고 서로 참조된 객체들을 마킹하면 나머지들은 GC처리가 이루어짐

- Mark : 참조 객체와 참조되지 않은 객체를 식별하는 프로세스
- Sweep : 마킹되지않은 미사용 객체를 제거하는 프로세스
- Compact : 메모리 단편화를 없애는 프로세스

### GC의 기본동작방식 - Marking
- 사용중인 메모리와 사용하지않는 메모리 식별
- 모든 객체를 스캔하여 시간이 많이걸리는 작업

### GC의 기본동작방식 - Normal Deletion (Sweep)
- 참조되지 않는 객체를 제거

### GC의 기본동작방식 - Compacting
- 메모리 압축작업
- 남아있는 참조객체를 이동하여 메모리 압축 작업을 수행하면 새 메모리 할당이 빨라진다.


### 기본동작방식의 단점
- 모든 객체를 스캔하고 압축하는 작업은 비효율적이고
- 시간이 경과함에 따라 객체가 더 많이 할당되어 작업이 많아진다. -> 작업시간 증가
- 이를 보완하기위해 Generations 방식 도입  
(새로 생성된 객체일수록 오래살아남기 어렵다)  

### JVM Generations
Young/Old(Tenured)/Permanent(Metaspace) Generation
힙을 더 작은 파트로 나누어서 사용
- Young :  
모든 새 객체가 할당되는 영역. Miner GC 발생(자주 GC발생)(마이너 GC는 항상 STW(Stop-the-world : 해당 작업이 완료될때까지 모든 앱 스레드가 중지되는 행위)이다.)  
	- 1개의 Eden과 2개의 Survivors로 나뉨
	- 오래 남은 객체는 Old Generation으로 이동


- Old :  
오랫동안 참조된 객체가 저장되는 영역  
Major GC 발생 (오래걸림. 최대한 GC안걸리게하는게 좋음)

- Permanet Generation (현재 Metaspace) :  
클래스와 메서드 등의 메타데이터가 저장되는 영역(FullGC에 포함)




### Generational GC Process
- 새로 생성된 모든 객체가 Young Generation의 Eden 영역에 할당됨
- Eden 영역이 가득 차게되면 마이너 GC가 참조객체들을 survivor영역으로 이동시키고 미참조 객체들은 Eden영역이 비워질때 제거함
- survivor영역이 가득 차면 두번째 survivor영역으로 이동되어 미참조객체 제거
- 과정을 반복할때마다 교대로 survivor영역을 바꿔가며 이동을 시킨다. 앞선 작업을 계속 반복
- 반복된 마이너 GC이후 오래된 객체들이 임계값을 넘기면 Old Generation으로 이동시킴
- 최종적으로 Old 영역에서 메이저 GC가 일어난다.


### GC 장단점
- 메모리 직접 관리 필요 없음 -> 누수발생 적어짐
- 댕글링 포인터(유효하지않는 객체/타입을 가리키는 포인터) 핸들링으로 인한 오버헤드가 발생하지않음  
but  
- 리소스가 많이 필요함
- 직접 제어하고싶어도 할수없다
- 일부GC는 완벽하지않아 런타임에 중지될 가능성
- 수동보다 비효율적


### GC Roots
- GC 프로세스의 시작점
- GC 루트로부터 직간접적으로 참조되는 객체는 GC 대상에서 제외
- 지역변수, 매개변수, 클래스 로더에 의해 로딩된 클래스, 스태틱필드의 참조들, synchronized블록에서 참조되는 객체 등이 GC Root가 될수있다.


### GC Reference Counting
- 참조 객체의 참조 횟수를 세어 GC를 처리하는 방법
- 순환참조문제를 해결하기 어렵다는 단점
- 현재(JDK17) JVM GC는 참조카운팅 기반 알고리즘은 없다.


## 2. Heap 영역을 제외한 GC 처리영역
문서에는 처리가 된다고 써져있지는 않음  
GC가 아닌 OS또는 JVM이 메모리 관리를 수행하는 영역  
### Metaspace(Permanent)
클래스의 메타데이터에 대한 메모리 관리를 담당. 최대치에 도달하면 참조되지않는 클래스의 수집을 처리한다.

### CodeCache


## 3. Java에서 지원하는 GC 알고리즘
- Serial GC
- Parallel GC (JDK7)
- CMS GC -> Remove JDK 14
- G1 GC (JDK 9)
- Shenandoah GC (OpenJDK에만)
- ZGC
- Epsilon GC

### 용어
- parallel phase : 멀티스레드(병렬)실행 가능
- concurrent phase : 백그라운드에서 앱과 동시 실행
- serial phase : 싱글스레드로 실행가능
- stop-the-world phase : 앱이 멈추고 실행
- incremental phase : 작업완료전 종료하고 나중에 이어서 작업가능

### Serial GC
- 싱글 스레드로 동작하는 가장 간단한 GC
- 실행시 모든 스레드의 STW -> 서버환경의 적합하지않다.

### parallel GC
- 멀티스레드 활용 GC(GC수행시에는 똑같이 다른앱스레드도 정지 STW)

### Concurrent Mark-Sweep GC (CMS GC)
- 14버전에서 제거된 GC알고리즘
- 앱과 동시에 실행가능

### CMS GC 단계
- STW를 줄이기 위해 단계를 나눠서 실행
- STW가 두곳에서 발생
- Old Generation 점유율이 기준치에 도달하면 CMS가 시작됨
- 컴팩션 작업은 따로 없다.
- 메모리 단편화 문제가 발생하여 극복하기위해 G1 GC가 등장했다.

1. Initial Marking (STW발생)  
: rootset을 기준으로 직접참조를 가지고있는것들을 마크  
2. Concurrent Marking (STW풀림-앱실행)  
: 앱 실행되는동안 Initial Marking된 객체들에 그래프를 통해 추적  
3. Remarking (STW 발생)  
: 누락된 마킹 찾는 작업  
4. Concurrent Sweep  
5. Resetting  


### G1 GC
- CMS GC개선
- 힙을 Region이라는 개념으로 약 2000개 영역으로 나눠서 본다.(해당 영역들은 가상메모리의 연속범위)
1. Initial Mark(STW)  
2. Root Region Scanning  
3. Concurrent Marking  
4. Remark(STW)  
5. Cleanup(STW & Concurrent)  


### Shenandoah GC 세난도아
- G1 GC와 유사  
- OpenJDK에서만 존재  
- 브룩스 포인터로 참조 재배치 매커니즘을 다룬다.  
- 힙을 제너레이션으로 나누지 않는다.
1. Initial Mark(STW)  
2. Concurrent Marking  
3. Final Mark 다시스캔해서 누락된 마킹처리  
비워져야할 리전 파악  
4. Concurrent Cleanup : Live객체 없는 리전 회수  
5. Concurrent Evacuation : 컬렉션셋을 다른 리전으로 동시에 이동하는 단계  
6. Init Update Refs  
7. Concurrent Update References : 다른 GC와 주요 차이점. Concurrent Evacuation 작업중 이동된 객체에 대한 참조를 업데이트 하는 단계  
8. Final Update Refs  
9. Concurrent Cleanup  

### ZGC
- 힙크기에 따라 성능이 달라지지 않는다.  
1. marking  
2. reference color  
3. relocation  
: 힙이 클수록 메모리 재배치가 느리고 앱 실행과 동시 실행해도 문제가 발생하기때문에 이를 해결하기위해 로드배리어를 활용한다.  
4. remaping & load barriers  

### Epsilon GC
- 메모리를 할당하지만 실제로 회수하지 않는 GC  
사용 가능한 메모리를 모두 사용하면 프로그램이 종료됨
- JVM에 수동 메모리 관리 등은 이 GC의 의도와 맞지 않음


### Choose GC - Serial GC
- 싱글 코어(스레드)에서 추천되는 GC

### Choose GC - Parallel(Throughput) GC
- 배치 또는 오프라인 작업이나 비 대화형 웹 서버같은 경우에 적합
- 멀티 프로세스 하드웨어 활용 가능
- Serial GC보다 더 큰 데이터셋 핸들링에 효율적
- STW가 비교적 긺

### Choose GC - G1 GC
- 거래 플랫폼이나 대화형 GUI 등과 같이 실시간 앱에 적합함  
일시 중지 시간이 중요하고 전체 처리량이 적당한 수준인 경우
- 기가 규모 데이터 셋에 매우 효율적
- 일시 중지 시간을 줄이는 데 가장 효율적  
but  
- 목표한 처리량이 굉장히 중요할 때는 최선의 GC가 아닐 수 있음
- 동시 수집되는 동안 앱이 GC와 리소스(CPU, 메모리 등)를 공유해야 함

### Choose GC - ZGC
- 확장 가능하며 낮은 지연시간을 가진 GC
- 일반적으로 큰 힙을 사용하고 응답시간이 빨라야 하는 서버 앱의 적합함
