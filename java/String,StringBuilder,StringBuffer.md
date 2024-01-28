# String, StringBuilder, StringBuffer
셋 모두 문자열을 처리하기위한 클래스

## String
​조회가 많은 환경에서 성능적으로 유리하다.  
불변 객체immutable이다.  
불변객체이므로 thread safe하기때문에 여러 스레드들이 공유하여 사용할 수 있다.  

### 불변객체
재할당은 가능하지만, 한번 할당하면 내부 데이터를 변경할 수 없는 객체 = 객체 자체는 변경할 수 없지만 객체에 대한 참조는 변경할 수 있다.  
~~~java
String a = "aa";
String b = "bb";

a = a + b;
~~~
위 두 줄 코드가 실행되면 "aa", "bb" 문자열에대해 메모리가 할당되고 a,b 변수가 그 값을 각각 참조하게 된다.  
`a = a + b` 가 실행된 이후에는 String클래스는 immutable하기때문에 a가 참조하고있는 공간의 "aa"대신 "aabb"값으로 바꿔주는 것이 아니라 새로운 String인스턴스를 생성하여 a가 참조하도록 해준다.  
이전에 참조하던 "aa"는 쓰레기가 되어 나중에 GC에의해 처리된다.  
연산을 많이 할 수록 이런 이유로인해 시간과 메모리가 소요되어 성능에 좋지 않다.  


### 생성방식
String에는 두가지 생성방식이 있는데, (new연산자-리터럴)  
new를 통해 String을 생성하면 메모리의 Heap영역에 할당되고  
리터럴을 이용하면 String constant pool이라는 영역에 할당된다.  
따라서 내용이 같더라도 new연산자로 생성한 String과 리터럴방식으로 생성한 String은 Heap 영역에서 할당하는 메모리 번지가 다르기 때문에 == 연산자비교시 false를 리턴하게된다.  
~~~java
// new연산자
String a = new String("Hello");

// 리터럴
String b = "Hello";
String c = "Hello";

a==b; // false(a의 경우 new연산자를 이용하여 새로운 객체를 생성했으므로 주소값참조)
b==c; // true
~~~


## StringBuilder & StringBuffer
StringBuilder와 StringBuffer는 모두 AbstractStringBuilder라는 추상클래스를 상속받아 구현되어있는데,  
해당 클래스의 멤버변수로 문자열값을 저장하는 char배열인 value와  
현재문자열 크기의 값을 가지는 int형 count를 가지고 있다.  
Builder와 Buffer두 클래스는 `+` 연산대신 `append()` 함수를 이용하여 문자열을 추가하며,  
value에 사용되지않고 남아있는 공간에 새로운 문자열이 들어갈수있다면 그대로 삽입하고 그렇지않다면 배열의 크기를 두배로 증가시켜 기존문자열을 복사하고 새로운 문자열을 삽입한다.  

### StringBuilder
동기화를 지원하지 않는다.  
싱글스레드환경에서는 스레드 동기화와 관련된 오버헤드(락 획득/반환과정에서의 오버헤드 등)가 없는 StringBuidler를 사용하는것이 효율적이다.  
~~~java
    @Override
    @IntrinsicCandidate
    public StringBuilder append(String str) {
        super.append(str);
        return this;
    }
~~~

### StringBuffer
동기화를 지원하여 멀티쓰레드환경에서 유리하다.  
~~~java
    @Override
    @IntrinsicCandidate
    public synchronized StringBuffer append(String str) {
        toStringCache = null;
        super.append(str);
        return this;
    }
~~~

## 정리
- String:조회가 많은 환경에서 성능적으로 유리/불변 객체  
- StringBuffer& StringBuilder : 문자열 연산이 자주 발생할때 유리/가변 객체  

=> String클래스가 덧셈연산에서 좋지않은 성능을 보여주는 이유는 연산수행시마다 문자열을 새로운 메모리에 복사하였기때문이나,  
StringBuilder와 Buffer는 가변크기배열을 이용하여 필요한 경우에만 문자열을 복사하기때문에 성능측면에서 유리하다.  

- StringBuilder: 동기화 지원 X -> 동기화가 필요없는 단일스레드환경에서 빠름
- StringBuffer: 동기화 지원 O -> 멀티쓰레드환경에서 유리

​

## 참고  
[StringBuffer, StringBuilder 가 String 보다 성능이 좋은 이유와 원리](https://cjh5414.github.io/why-StringBuffer-and-StringBuilder-are-better-than-String/)  
[[Java] String 생성 방식! 리터럴방식(상수풀) vs new 연산자 방식](https://velog.io/@mooh2jj/%EC%9E%90%EB%B0%94%EC%9D%98-String-%EC%83%9D%EC%84%B1-%EB%B0%A9%EC%8B%9D-%EB%A6%AC%ED%84%B0%EB%9F%B4%EB%B0%A9%EC%8B%9D-vs-new-%EC%97%B0%EC%82%B0%EC%9E%90-%EB%B0%A9%EC%8B%9D)