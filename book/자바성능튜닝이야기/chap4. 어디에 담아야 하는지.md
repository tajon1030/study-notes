## 어디에 담아야 하는지
개발시 어떤 객체를 써야할지 고민을 하게된다는것이 주내용  
일반적인 웹을 개발할 때는 Collection 성능 차이를 비교하는 것은 큰 의미가 없다는 결론.  
각 클래스에는 사용 목적이 있기 때문에 목적에 부합하는 클래스를 선택해서 사용하는 것이 바람직하다.  
사용하는 목적에는 맞는데 해당 메서드의 성능이 잘 나올지 확실치 않은 경우에는 JMH를 사용하여 직접 성능 측정을 해보자.  


### Collection 및 Map 인터페이스  
#### Collection 인터페이스  
- Collection : 상위 인터페이스  
- Set : 중복을 허용하지 않는 집합을 처리하기 위한 인터페이스  
- SortedSet : 오름차순을 갖는 Set 인터페이스  
- List : 순서가 있는 집합을 처리하기 위한 인터페이스, 중복을 허용하며 인덱스가 있어 위치를 지정하여 값을 찾을 수 있다.  
- Queue : FIFO(First In First Out, 선입선출) 형태로 자료를 관리하는 인터페이스  

#### Map 인터페이스  
- Map : Map은 key와 value의 쌍으로 구성된 객체의 잡합을 처리하기 위한 인터페이스로, 중복되는 키를 허용하지않는다.  
- SortedMap : 키를 오름차순으로 정렬하는 Map 인터페이스  

#### Set 관련 클래스  
Set 인터페이스는 중복이 없는 집합 객체를 만들 때 유용하다.  
Set 인터페이스를 구현한 클래스로는 HashSet, TreeSet, LinkedHashSet 세가지가 있다.  
- HashSet : 데이터를 해쉬 테이블에 담는 클래스로 순서 없이 저장  
- TreeSet : red-black이라는 트리에 데이터를 담는 클래스로 값에 따라서 순서가 정해진다.  
데이터를 담으면서 동시에 정렬하기 때문에 HashSet보다 성능상 느리다.  
- LinkedHashSet : 해쉬 테이블에 데이터를 담는데, 저장된 순서에 따라서 순서가 결정된다.  

=> 데이터를 순서에 따라 탐색하는 작업이 필요할 때에는 TreeSet을 사용하는것이 좋고,  
그럴 필요가 없을 경우에는 HashSet이나 LinkedHashSet 사용 권장  

#### List관련 클래스  
List 인터페이스를 구현한 클래스들은 담을 수 있는 크기가 자동으로 증가되므로, 데이터의 개수를 확실히 모를 때 유용하다.  
- Vector: 객체 생성 시에 크기를 지정할 필요가 없는 배열 클래스  
- ArrayList: Vector와 비슷하지만, 동기화 처리가 되어 있지 않다.  
- LinkedList: ArrayList와 동일하지만, Queue 인터페이스를 구현했기 때문에 FIFO 큐 작업을 수행한다.  

List의 가장 큰 단점은 데이터가 많은 경우 처리 시간이 늘어난다는 점  
가장 앞에 있는 데이터를 지우면 마지막 데이터까지 한 칸씩 옮기는 작업을 수행하야 하므로,  
데이터가 많으면 많을수록 소요되는 시간이 증가한다.  

LinkedList는 Queue 인터페이스를 상속받기 때문에, peek()이나 poll() 메서드를 사용할 수 있다.  
Vector는 synchronized가 선언되어 있어서 성능 저하가 발생할 수 있음.  

#### Queue관련 클래스  
Queue 인터페이스를 구현한 클래스는 두 가지로 나뉜다.  
java.util 패키지에 속하는 LinkedList와 PriorityQueue는 일반적인 목적의 큐 클래스이며,  
java.util.concurrent 패키지에 속하는 클래스들은 ConcurrentQueue 클래스이다.  

- PriorityQueue: 큐에 추가된 순서와 상관없이 먼저 생성된 객체가 먼저 나오도록 되어 있는 Queue  
- LinkedBlockingQueue: 저장할 데이터의 크기를 선택적으로 정할 수도 있는 FIFO 기반의 링크 노드를 사용하는 블로킹 Queue  
- ArrayBlockingQueue: 저장되는 데이터의 크기가 정해져 있는 FIFO 기반의 블로킹 Queue  
- PriorityBlockingQueue: 저장되는 데이터의 크기가 정해져 있지 않고, 객체의 생성순서에 따라서 순서가 저장되는 블로킹 Queue  
- DelayQueue: 큐가 대기하는 시간을 지정하여 처리하도록 되어 있는 Queue  
- SynchronousQueue: 크기가 0인 동기화된 큐로써, put() 메서드를 호출하면, 다른 스레드에서 take() 메서드가 호출될 때까지 대기하도록 되어 있는 Queue.  

참고) Blocking Queue란? 크기가 지정되어 있는 큐에 더 이상 공간이 없을 때, 공간이 생길 때까지 대기하도록 만들어진 큐  

#### Map 관련 클래스
- HashTable: 데이터를 해쉬 테이블에 담는 클래스. 내부에서 관리하는 해쉬 테이블 객체가 동기화되어 있다.
- HashMap: 데이터를 해쉬 테이블에 담는 클래스. null 값을 허용하며 동기화되어 있지 않다.
- TreeMap: red-black 트리에 데이터를 담는다. 키에 의해 순서가 정해진다.
- LinkedHashMap: HashMap과 거의 동일하며 이중 연결 리스트(Doubly-LinkedList)라는 방식을 사용하여 데이터를 담는다는 점만 다르다.

### Collection 관련 클래스 동기화
HashSet, TreeSet, LinkedHashSet, ArrayList, LinkedList, HashMap, TreeMap, LinkedHashMap은 동기화(synchronized)되지 않은 클래스이다.  
- Vector  
- HashTable  
- ConcurrentHashMap: ConcurrentHashMap은 동시성을 지원하는 Map 인터페이스의 구현체로서, 동시에 여러 쓰레드에서 안전하게 읽고 쓸 수 있도록 설계되었습니다. 내부적으로 세분화된 잠금(locks)과 동시성을 지원하는 알고리즘을 사용하여 성능을 향상시켰습니다.  
- Collections.synchronizedXXX() 메서드: Java에서는 동기화된 버전의 Collection을 만들기 위해 Collections 클래스에서 synchronizedXXX() 메서드를 제공합니다. 예를 들어, Collections.synchronizedList(), Collections.synchronizedSet(), Collections.synchronizedMap() 등의 메서드를 사용하여 동기화된 List, Set, Map 등을 생성할 수 있습니다.  