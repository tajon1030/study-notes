# 모던 자바 인 액션

## Part 1. 기초
### chapter 3. 람다표현식
#### 3.1 람다란 무엇인가?
**람다표현식** : 메서드로 전달할 수 있는 익명 함수를 단순화한 것  

##### 특징 :  
- 익명  
: 보통의 메서드와 달리 이름이 없음  
- 함수  
: 메서드처럼 특정 클래스에 종속되지않으므로 함수라고 부름  
- 전달  
: 람다표현식을 메서드 인수로 전달하거나 변수로 저장할 수 있다  
- 간결성  
: 익명 클래스처럼 많은 코드를 구현할 필요가 없다.

-> 람다 표현식을 사용하면 동작 파라미터 형식의 코드를 더 쉽게 구현할 수 있다.(코드가 간결하고 유연해진다)

##### 람다의 세 부분
~~~java
(Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());
// 람다 파라미터 : 메서드 파라미터
// 화살표 : 람다의 파라미터 리스트와 바디를 구분
// 람다 바디 : 람다의 반환값에 해당하는 표현식
~~~

##### 유효한 람다 표현식 5가지
~~~java
(String s) -> s.length() // 1
(Apple a) -> a.getWeight() > 150 // 2
(int x, int y) -> {     // 3
    System.out.println("Result:");
    System.out.println(x+y);
}
() -> 42    // 4
(Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());   // 5
~~~  
1. 람다 표현식에는 return 이 함축되어 있으므로 return 문을 명시적으로 사용하지 않아도 된다  
3. 람다표현식은 여러 행의 문장을 포함할 수 있다.

~~~java
//불리언 표현식
(List<String> list) -> list.isEmpty()

// 객체 생성
() -> new Apple(10)

// 객체에서 소비
(Apple a) -> {
    System.out.println(a.getWeight());
}

// 객체에서 선택/추출
(String s) -> s.length()

// 두 값을 조합
(int a, int b) -> a * b

// 두 객체 비교
(Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight())
~~~

#### 3.2 어디에 어떻게 람다를 사용할까?
람다표현식은 함수형 인터페이스라는 문맥에서 사용할 수 있다.

##### 3.2.1 함수형 인터페이스
함수형 인터페이스는 하나의 추상메서드를 지정하는 인터페이스이다.  
자바 API의 함수형 인터페이스로 Comparator, Runnable 등이 있다.  
(많은 디폴트 메서드가 있더라도 추상 메서드가 오직 하나면 함수형 인터페이스다)

함수형 인터페이스의 추상메서드 구현을 람다표현식으로 직접 전달할수있으므로서  
전체 표현식을 함수형 인터페이스의 인스턴스로 취급할 수 있다.

##### 3.2.1 함수 디스크립터
함수형 인터페이스와 추상메서드 시그니처는 람다 표현식의 시그니처를 가리킨다.  
람다 표현식의 시그니처를 서술하는 메서드를 함수 디스크립터라고 부른다.

~~~java
public void process(Runnable r){
    r.run();
}
process(() -> System.out.println("This is awesome!!"));
~~~  
여기에서 ()->System.out.oritnln("This is awesome!!")은 인수가 없으며 void를 반환하는 람다표현식이다.  
이는 Runnable 인터페이스의 run 메서드 시그니처와 같다.

참고로 한개의 void메소드 호출은 중괄호로 감쌀 필요가 없기 때문에 위 코드는 정상적 람다 표현식이다.

~~~java
// 1
execute(()->{});
public void execute(Runnable r){
    r.run();
}

// 2
public Callable<String> fetch() {
    return () -> "Tricky example ;-)";
}

// 3
Predicate<Apple> p = (Apple a) -> a.getWeight();
~~~  
다음중 람다표현식을 올바로 사용한 코드는 1,2 코드이다.  
1에서 람다표현식의 시그니처는 () -> void이며 Runnable의 추상메서드 run의 시그니처와 일치하므로 유효  
2에서도 fetch 메서드의 반환형식은 Callable<String> 이다.  
T를 String으로 대치했을때 Callable<String>메서드의 시그니처는 () -> String으로,  
현재 람다표현식의 시그니처와 일치하여 유효한 람다표현식이다.
3은 람다표현식의 시그니처가 (Apple)->Integer이므로 Predicate<Spple>의 test메서드 시그니처((Apple)-> boolean)와 일치하지않는다.

#### 3.3 람다활용: 실행 어라운드 패턴
자원처리(예를들어 DB파일처리)에 사용하는 순환패턴은 자원을 열고, 처리한 다음, 자원을 닫는 순서로 이루어진다.  
이처럼 실제 자원을 처리하는 코드를, 설정과 정리 두 과정이 둘러싸는 형태의 코드를 **실행어라운드패턴**이라고 부른다.  

~~~java
public String processFile() throws IOException{
    try(BufferedReader br = new BufferedReader(new FileReader("data.txt"))){
        return br.readLine();
    }
}
~~~

##### 3.3.1 1단계: 동작 파라미터화를 기억하라
위 코드는 한번에 한 줄 만 읽을 수 있는데  
기존의 설정, 정리 과정은 재사용하고 processFile메서드만 다른 동작을 수행하기위해서는  
processFile의 동작을 파라미터화 하면 된다.  

##### 3.3.2 2단계: 함수형 인터페이스를 이용해서 동작 전달
함수형 인터페이스 자리에 람다를 사용할 수 있다.  
따라서 BufferedReader -> String 과 IOException을 던질수있는 시그니처와 일치하는 함수형 인터페이스를 만들어야한다.  
~~~java
@FuntionalInterface
public interface BufferedReaderProcessor {
    String process(BufferedReader b) throws IOException;
}
~~~

정의한 인터페이스를 processFile 메서드의 인수로 전달할 수 있다.  
~~~java
public String processFile(BufferedReaderProcessor p) throws IOException {
...
}
~~~

##### 3.3.3 3단계: 동작 실행
~~~java
public String processFile(BufferedReaderProcessor p) throws IOException{
    try(BufferedReader br = new BufferedReader(new FileReader("data.txt"))){
        return p.process(br);
    }
}
~~~

##### 3.3.4 4단계: 람다 전달
이제 람다를 이용하여 다양한 동작을 processFile메서드로 전달할 수 있다.
~~~java
String oneLine = processFile((BufferedReader br) -> br.readLine());
~~~

#### 3.4 함수형 인터페이스 사용
##### 3.4.1 Predicate
java.util.function.Predicate<T> 인터페이스는 test라는 추상 메서드를 정의하며, test는 제네릭 형식 T의 객체를 인수로 받아 불리언을 반환한다.  
따라서 T형식의 객체를 사용하는 불리언 표현식이 필요한 상황에서 해당 인터페이스를 사용할 수 있다.

##### 3.4.2 Consumer
java.util.function.Consumer<T> 인터페이스는 제네릭 형식 T 객체를 받아서 void를 반환하는 accept 라는 추상 메서드를 정의한다.  
T형식의 객체를 인수로 받아서 어떤 동작을 수행하고 싶을때 해당 인터페이스를 사용할 수 있다.

##### 3.4.3 Function
java.util.function.Function<T, R> 인터페이스는 제네릭 형식 T를 인수로 받아서 제네릭형식 R 객체를 반환하는 추상메서드 apply를 정의한다.  
따라서 입력을 출력으로 매핑하는 람다를 정의할때 Function 인터페이스를 활용할 수 있다.

##### 기본형 특화
특화된 형식의 함수형 인터페이스도 있다.  
우선 자바의 제네릭 파라미터에는 참조형만 사용할 수 있다.  
내부구현때문에 어쩔 수 없는 일이며 자바에서는 박싱(기본형->참조형),언박싱(참조->기본), 오토박싱 기능을 제공한다.  
하지만 이런 변환 과정은 비용이 소모되기때문에 자바 8에서는 기본적으로 입출력을 사용하는 상황에서 오토박싱 동작을 피할 수 있도록 특별한 버전의 함수형 인터페이스를 제공한다.  
ex) IntPredicate, LongPredicate, DoublePredicate, IntConsumer, InteFunction<R> 등...  

참고로 함수형 인터페이스는 예외를 던지는 동작을 허용하지 않는다.  
따라서 예외를 던지는 람다표현식을 만들려면 예외를 선언하는 함수형 인터페이스를 직접 정의하거나,  
람다를 try catch 블록으로 감싸야한다.

#### 3.5 형식 검사, 형식 추론, 제약
##### 3.5.1 형식검사
람다가 사용되는 context를 이용해서 람다의 type을 추론할 수 있다.  
어떤 콘텍스트에서 기대되는 람다 표현식의 형식을 대상형식target type 이라고 부른다.  
형식 확인 과정은 다음과 같이 이루어 진다.  
~~~java
List<Apple> heavierThan150g = filter(inventory, (Apple apple) -> apple.getWeight() > 150);
~~~  
1. 람다가 사용된 콘텍스트가 무엇인지 filter 메서드의 선언을 확인한다.  
2. 위 코드에서 filter메서드는 두번째파라미터로 Predicate<Apple>형식을 기대한다.(대상형식=Predicate<Appple>)  
3. Predicate<Apple>은 test라는 한 개의 추상 메서드를 정의하는 함수형 인터페이스이다.  
4. test메서드의 디스크립터는 Apple -> boolean 이다.  
5. 함수디스크립터는 람다의 디스크립터와 일치하므로 코드 형식 검사가 성공적으로 완료된다.  

##### 3.5.2 같은 람다, 다른 함수형 인터페이스
대상 형식이라는 특징때문에 같은 람다 표현식이라도 호환되는 추상 메서드를 가진 다른 함수형 인터페이스로 사용될 수 있다.  
참고로 람다의 바디에 일반 표현식이 있으면 void를 반환하는 함수 디스크립터와 호환된다.(파라미터 리스트도 호환되어야함)  
아래코드를 보면 List의 add메서드는 Consumer 콘텍스트(T->void)가 기대하는 void대신 boolean을 반환하지만 유효한 코드다.  
~~~java
Predicate<String> p = s -> list.add(s);
Consumer<String> b = s -> list.add(s);
~~~  
결과적으로 대상 형식을 이용하여 람다 표현식을 특정 콘텍스트에 사용할 수 있는지 확인할 수 있으며,  
대상 형식으로 람다의 파라미터 형식도 추론할 수 있다.

##### 3.5.3 형식추론
자바컴파일러는 람다표현식이 사용된 콘텍스트를 이용해서 람닾현식과 관련된 함수형 인터페이스를 추론한다.  
따라서 컴파일러는 람다의 시그니처도 추론할수있다.  
결과적으로 람다문법에서 람다표현식의 파라미터 형식을 생략할 수 있다.  
자바 컴파일러는 다음처럼 람다 파라미터 형식을 추론할 수 있다.  
~~~java
// 형식을 추론하지 않음
Comparator<Apple> c = (Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());

// 형식을 추론함
Comparator<Apple> c = (a1, a2) -> a1.getWeight().compareTo(a2.getWeight());
~~~  

상황에따라 명시적으로 형식을 포함하지않고 배제하는것이 가독성을 향상시킬수있으므로 상황에 맞게 사용한다.

##### 3.5.4 지역 변수 활용
람다표현식에서는 익명함수가 하는것은 **자유변수**(파라미터로 넘겨진변수가 아닌 외부에서 정의된 변수)를 확용할 수 있다.  
이러한 동작을 **람다캡쳐링**이라고 부른다.  
~~~java
int portNumber = 1337;
Runnable r = () -> System.out.pritnln(portNumber);
~~~  
자유변수에도 약간의 제약이 있는데 지역변수는 명시적으로 final로 선언되어있거나 실질적으로 final로 선언된 변수와 똑같이 사용되어야한다.  
즉, 람다표현식은 한번만 할당할 수 있는 지역변수를 캡처할 수 있다.  

~~~java
int portNumber = 1337;
Runnable r = () -> System.out.pritnln(portNumber);
portNumber = 8000; // 재할당하였으므로 위의 람다표현식은 컴파일할수없다.
~~~  

이러한 제약이 있는 이유는 인스턴스변수는 힙에, 지역변수는 스택에 위치하는데  
람다에서 지역변수에 바로 접근할수있다는 가정하에 람다가 스레드에서 실행된다면  
변수를 할당한 스레드가 사라져서 변수할당이 해제되었는데도 람다실행스레드에서는 해당변수에 접근하려 할 수 있다.  
따라서 자바구현에서는 자유지역변수의 복사본을 제공해야하는데 복사본의 값이 바뀌지않아야하기때문에  
지역변수에는 한번만 값을 할당해야한다는 제약이 생긴것이다.  

참고: 클로저  

#### 3.6 메서드 참조
##### 3.6.1 요약
메서드 참조는 특정 메서드만을 호출하는 람다의 축약형이라고 생각할 수 있다.  
메서드 참조를 이용하면 가독성을 높일수있다는 장점이 있다.  
메서드 참조는 메서드명 앞에 구분자::를 붙이는 방식으로 활용할 수 있다.  

##### 메서드 참조를 만드는 방법
세가지 유형으로 구분할 수 있다.  
1. 정적 메서드 참조  
: Integer의 parseInt 메서드는 Integer::parseInt로 나타낼 수 있다.  
2. 다양한 형식의 인스턴스 메서드 참조  
: (String s) -> s.toUpperCase() 는 String::toUpperCase로 줄여서 표현 가능  
3. 기존 객체의 인스턴스 메서드 참조  
: () -> expensiveTransaction.getValue()를 expensiveTransaction::getValue 라고 표현할 수 있다.  

##### 3.6.2 생성자 참조
ClassName::new 처럼 클래스명과 new키워드를 이용해서 기존 생성자의 참조를 만들 수 있다.  
인수가 세 개인 생성자의 생성자 참조를 사용하려면 생성자 참조와 일치하는 시그니처를 갖는 함수형 인터페이스가 필요하므로 직접 만들어야한다.  

#### 3.7 람다, 메서드 참조 활용하기
앞에서 배운 내용 정리

#### 3.8 람다표현식을 조합할 수 있는 유용한 메서드
Comparator, Function, Predicate 같은 함수형 인터페이스는 람다표현식을 조합할 수 있도록 유틸리티 메서드를 제공한다.  
이를이용하면 여러 람다표현식을 조합해서 복잡한 람다표현식을 만들 수 있다.  

##### 3.8.1 Comparator조합
Comparator.comparing을 이용해서 비교에 사용할 키를 추출하는 Function기반의 Comparator를 반환할 수 있다.  
~~~java
Comparator<Apple> c = Comparator.comparing(Apple::getWeight);
~~~

사과를 무게순으로 내림차순하고싶더라도 
인터페이스 자체에서 비교자의 순서를 바꾸는 reverse라는 디폴트 연산자를 제공하기때문에  
새롭게 Comparator 인터페이스를 만들 필요가 없다.  
~~~java
inventory.sort(Comparator.comparing(Apple::getWeight).reversed());
~~~

또한 비교 결과를 더 다듬을 수 있는 두번째 Comparator를 만들어 thenComparing메서드로 두번째 비교자를 만들수 있다.
~~~java
inventory.sort(Comparator.comparing(Apple::getWeight)
        .reversed()
        .thenComparing(Apple::getCountry));
~~~

##### 3.8.2 Predicate조합
Predicate인터페이스는 negate, and, or 세가지 메서드를 제공하여 복잡한 프레디케이트를 만들 수 있다.  
~~~java
// 기존 프레디케이트 객체의 결과를 반전시킨 객체
Predicate<Apple> notRedApple = redApple.negate();

// 두 프레디케이트를 연결해서 새로운 프레디케이트 만들기
Predicate<Apple> redAndHeavyApple = redApple.and(apple->apple.getWeight() > 150); 

// or를 이용해서 여러 조건을 연결
Predicate<Apple> redAndHeavyAppleOrGreen = 
    redApple.and(apple->apple.getWeight() > 150)
    .or(apple -> GREEN.equals(a.getColor())); 
~~~

##### 3.8.3 Function조합
Function인터페이스는 Function인스턴스를 반환하는 andThen, compose 두가지 디폴트 메서드를 제공  

andThen메서드는 주어진 함수를 먼저 적용한 결과를 다른 함수의 입력으로 전달하는 함수를 반환한다.  
~~~java
// f와 g를 조립해서 숫자를 증가시킨 뒤 결과에 2를 곱하는 h라는 함수 만들기
Function<Integer, Integer> f = x -> x + 1;
Function<Integer, Integer> g = x -> x * 2;
Function<Integer, Integer> h = f.andThen(g); // 수학적으로 g(f(x))
int result = h.apply(1); // 4를 반환
~~~  

compose메서드는 인수로 주어진 함수를 먼저 실행한 다음 그 결과를 외부함수의 인수로 제공한다.
~~~java
Function<Integer, Integer> f = x -> x + 1;
Function<Integer, Integer> g = x -> x * 2;
Function<Integer, Integer> h = f.compose(g); // 수학적으로 f(g(x))
int result = h.apply(1); // 3을 반환
~~~  

#### 3.9 비슷한 수학적 개념
적분. PASS

#### 3.10 마치며
- **람다표현식**은 익명함수의 일종이다. 이름은 없지만 파라미터리스트, 바디, 반환형식을 가지며 예외를 던질 수 있다.
- 람다표현식으로 간결한 코드를 구현할 수 있다.
- **함수형 인터페이스**는 하나의 추상메서드만을 정의하는 인터페이스다.
- 함수형 인터페이스를 기대하는 곳에서만 람다표현식을 사용할 수 있다.
- 람다표현식을 이용해서 함수형 인터페이스의 추상메서드를 즉석으로 제공할 수 있으며, **람다표현식 전체가 함수형 인터페이스의 인스터스로 취급된다**
- java.util.function 패키지는 Predicate, Function, Supplier, Consumer, BinaryOperator 등을 포함해서 자주 사용하는 다양한 함수형 인터페이스를 제공한다.
- 자바8은 Predicate와 Function같은 제네릭 함수형 인터페이스와 관련한 박싱 동작을 피할수있는 IntPredicate, IntToLongFunction등과 같은 기본형 특화 인터페이스도 제공한다.
- 실행 어라운드 패턴(예를 들면 자원할당, 자원 정리 등 코드 중간에 실행해야하는 메서드에 꼭 필요한 코드)을 람다와 활용하면 유연성과 재사용성을 추가로 얻을 수 있다.
- 람다표현식의 기대형식(type expected)을 대상형식(target type)이라고 한다.
- 메서드 참조를 이용하면 기존의 메서드 구현을 재사용하고 직접 전달할 수 있다.
- Comparator, Predicate, Function 같은 함수형 인터페이스는 람다표현식을 조합할 수 있는 다양한 디폴트 메서드를 제공한다.