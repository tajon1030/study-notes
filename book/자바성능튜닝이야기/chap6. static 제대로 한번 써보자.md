## static 제대로 한번 써보자

static 변수는 클래스 변수라고도 불림  
하나의 JVM에서 같은 주소에 있는 값을 참조  
~~GC의 대상이 되지 않음~~  
java7 이전에는 GC의 대상이 되지 않았지만  
java1.8이후 static Object가 heap영역에서 관리되어 참조를 잃은 static Object는 GC의 대상이 될 수 있다.  

### 잘 사용하기 위해서
자주 사용하고 절대 변하지 않는 변수, 상수로 사용되는 수 (ex SQL쿼리 등)는 static final 로 선언  
설정 정보들을 static으로 관리하기  

### 주의해야할점 - 메모리 릭
ArrayList와 같은 컬랙션객체를 static으로 선언을 한다면 GC가 되지않기때문에 OOM 에러 발생하므로 주의  
ArrayList에서 크기를 동적으로 가질 수 있는 이유는 내부적으로 capacity에 도달하면 배열을 copy해서 새로운 배열을 할당하기 때문인데  
이러한 방식을 사용할때 static을 이용하게 되면 GC 처리가 되지않아 OOM에러가 발생한다는 의미  
**그.러.나**  
이는 java7에서 (어떻게보면 힙의 일부이지만 GC가 걸리지않을수 있으며-jvm벤더마다다름- 크기가 강제되는 영역인) JVM의 Perm영역(메서드영역)에 static변수가 저장되었기 때문이고,  
java 1.8이후부터 perm영역이 사라지고, metaspace영역이 추가되면서  
기존 Perm 영역에 존재하던 Static Object가 Heap 영역으로 옮겨져 GC의 대상이 최대한 될 수 있게 되었다.  
또한 metaspace영역은 heap영역이 아닌 nativeMemory영역으로 OS가 크기를 조절하여 기존에 비해 큰 메모리 영역을 사용할 수 있기때문에 OOM을 보기 힘들어 졌다.   




### 참고
https://blog.naver.com/PostView.nhn?blogId=2feelus&logNo=220765728530  
https://chan9.tistory.com/168   
