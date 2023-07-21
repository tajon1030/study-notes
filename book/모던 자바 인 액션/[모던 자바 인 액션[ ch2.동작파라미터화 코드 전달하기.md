# 모던 자바 인 액션

## Part 1. 기초
### chapter 2. 동작파라미터화 코드 전달하기
동작 파라미터화란 아직은 어떻게 실행할 것인지 결정하지않은 코드블록을 의미한다.  
동작 파라미터화를 이용하면 자주 바뀌는 요구사항에 효과적으로 대응할 수 있다.  

#### 2.1 변화하는 요구사항에 대응하기
리스트에서 녹색 사과만 필터링 하는 기능을 추가한다고 가정하자.

##### 2.1.1 첫번째 시도: 녹색사과 필터링
색상 열거형이 다음과 같이 주어졌을 경우

~~~java  
enum Color {RED, GREEN}
~~~  

코드로 다음과 같이 필터링 기능을 나타낼 수 있다.  

~~~java
public static List<Apple> filterGreenApples(List<Apple> inventory){
    List<Apple> result = new ArrayList<>(); // 사과 누적 리스트
    for(Apple apple: inventory){
        if(GREEN.equals(apple.getColor())){ // 녹색 사과만 선택
            result.add(apple);
        }
    }
    return result;
}
~~~

나중에 더 다양한 색으로 필터링 하는 등의 변화에는 적절히 대응할 수 없다.  
그렇다면 다음과 같은 규칙을 적용할수있다.  
거의 비슷한 코드가 반복 존재한다면 그 코드를 추상화

##### 2.1.2 두번째 시도: 색을 파라미터화
색을 파라미터화 할 수 있도록 메서드에 파라미터를 추가하면 변화하는 요구사항에 좀더 유연하게 대응하는 코드를 만들 수 있다.  
~~~java
public static List<Apple> filterApplesByColor(List<Apple inventory, Color color){
    List<Apple> result = new ArrayList<>();
    for (Apple apple: inventory){
        if(apple.getColor().equals(color)){
            result.add(apple);
        }
    }
    return result;
}

...

List<Apple> greenApples = filterApplesByColor(inventory, GREEN);
List<Apple> redApples = filterApplesByColor(inventory, RED);
~~~  
색 이외에도 앞으로 바뀔 수 있는 다양한 무게에 대응할 수 있도록 무게정보 파라미터도 추가했다.  
~~~java
public static List<Apple> filterApplesByWeight(List<Apple inventory, int weight){
    List<Apple> result = new ArrayList<>();
    for (Apple apple: inventory){
        if(apple.getWeight() > weight){
            result.add(apple);
        }
    }
    return result;
}
~~~  
위 코드는 색 필터링 코드와 대부분 중복된다. 이는 소프트웨어 공학의 DRY(같은것을 반복하지 말 것) 원칙을 어기는 것이다.

##### 2.1.3 세번째 시도 : 가능한 모든 속성으로 필터링
다음은 모든 속성을 메서드 파라미터로 추가한 모습이다.  
~~~java
public static List<Apple> filterApplesByWeight(List<Apple inventory, Color color, int weight, boolean flag){
    List<Apple> result = new ArrayList<>();
    for (Apple apple: inventory){
        if((flag&&apple.getColor.().equals(color)) ||
        (!flag && apple.getWeight() > weight)){
            result.add(apple);
        }
    }
    return result;
}

List<Apple> greenApples = filterApples(inventory, GREEN, 0, true);
~~~  
true와 false가 대체 무엇을 의미하는것인지를 알수가 없고,  
앞으로 요구사항이 바뀌었을때 유연하게 대응할 수도 없다.  

#### 2.2 동작 파라미터화
사과의 어떤 속성에 기초해서 불리언값을 반환하는 방식을 통해 선택 조건을 결정할 수 있다.  
(예를 들어 사과가 녹색인가? 150그램인가?)  
이와같이 참 또는 거짓을 반환하는 함수를 프레디케이트라고한다.  
~~~java
public interface ApplePredicate {
    boolean test (Apple apple);
}
~~~  
위와같이 선택조건을 결정하는 인터페이스를 통해 다양한 선택조건을 대표하는 여러버전의 ApplePredicate을 정의할 수 있다.

~~~java
public class AppleHeavyWeightPredicate implements ApplePredicate {
    public boolean test(Apple apple){
        return apple.getWeight() > 150;
    }
}
~~~  
위 조건에 따라 filter메서드가 다르게 동작할 것이라고 예상할 수 있다. 이를 전략 디자인 패턴 이라고 부른다.  
전략 디자인 패턴은 각 알고리즘(전략)을 캡슐화하는 알고리즘 패밀리를 정의해둔 다음,  
런타임에 알고리즘을 선택하는 기법이다.  
예제에서는 ApplePredicate이 알고리즘 패밀리이며, AppleHeavyWeightPredicate이 전략이다.  

ApplePredicate은 어떻게 다양한 동작을 수행할 수 있을까?  
filterApples에서 ApplePredicate을 받아 애플의 조건을 검사하도록 메서드를 고쳐야한다.  
이렇게 메서드가 다양한동작(전략)을 받아서 내부적으로 다양한 동작을 수행할수있는것이 동작파라미터화이다.  

##### 2.2.1 네번째 시도: 추상적 조건으로 필터링
이제 filterApples메서드가 ApplePredicate객체를 인수로 받도록 고치면,  
filterApples 메서드 내부에서 컬렉션을 반복하는 로직과 컬렉션의 각 요소에 적용할 동작을 분리할 수있다는점에서 엔지니어링적으로 큰 이득을 얻는다.

~~~java
public static List<Apple> filterApples(List<Apple inventory, ApplePredicate p){
    List<Apple> result = new ArrayList<>();
    for(Apple apple: inventory){
        if(p.test(apple)){ // 프레디케이트 객체로 사과 검사조건을 캡슐화 했다.
            result.add(apple);
        }
    }
}
~~~

우리는 filterApples메서드의 동작을 파라미터화 하였다.  
메서드는 객체만 인수로 받으므로 test메서드를 ApplePredicate객체로 감싸서 전달해야한다.  

동작파라미터는 탐색로직과 각 항목에 적용할 동작을 분리할수있다는 점이 장점으로,  
한 메서드가 다른 동작을 수행하도록 재활용할 수 있다.  
따라서 유연한 API를 만들때 동적 파라미터화가 중요한 역할을 한다.

#### 2.3 복잡한 과정 간소화
현재 filterApples메서드로 새로운 동작을 전달하려면  
ApplePredicate인터페이스를 구현하는 여러 클래스를 정의한 다음에 인스턴스화해야한다.  
이는 상당히 번거로운 작업으로 자바는 클래스의 선언과 인스턴스화를 동시에 수행할수있도록 익명클래스를 이용한다.

익명클래스는 이름이 없는 클래스로, 즉석에서 필요한 구현을 만들어서 사용할 수 있다.

##### 2.3.2 다섯번째 시도: 익명 클래스 사용
다음은 익명클래스를 이용하여 ApplePredicate을 구현하는 객체를 만드는 방법으로 다시 구현한 코드이다.  
~~~java
List<Apple> redApples = filterApples(inventory, new ApplePredicate()){
    public boolean test(Apple apple){
        return RED.equals(apple.getColor());
    }
}
~~~  

익명클래스는 그러나 여전히 많은 공간을 차지한다.  
또한, 코드가 장황하다는 단점이 있다.  
따라서 람다표현식을 사용해 동작파라미터를 더 간단하게 표현할수있도록 수정할수있다.

##### 2.3.3 여섯번째 시도: 람다 표현식 사용
~~~java
List<Apple> result = filterApples(invenetory, (Apple apple) -> RED.equals(apple.getColor()));
~~~

##### 2.3.4 일곱번째 시도: 리스트 형식으로 추상화
~~~java
public interface Predicate<T>{
    boolean test(T t);
}

public static <T> List<T> filter(List<T> list, Predicate<T> p){
    List<T> result = new ArrayList<>();
    for(T e: list){
        if(p.test(e)){
            result.add(e);
        }
    }
    return result;
}
~~~

#### 2.4 실전예제
동작 파라미터화는 변화하는 요구사항에 쉽게 적응하는 유용한 패턴이다.  
동작파라미터화 패턴은 동작을 캡슐화한다음, 메서드로 전달해서 메서드의 동작을 파라미터화한다.  
실전에서 사용하는 세가지 예제로서 Comparator 정렬하기, Runnable 코드블록 실행하기, GUI 이벤트 처리하기를 소개한다.  

##### 2.4.1 Comparator로 정렬하기
자바8의 List에는 sort메서드가 포함되어있다.  
다음과 같은 인터페이스를 갖는 Comparator객체를 이용해서 sort동작을 파라미터화 할 수 있다.  
~~~java
// java.util.Comparator
public interface Comparator<T>{
int compare(T o1, T o2);
}

inventory.sort(new Comparator<Apple>(){
    public int compare(Apple a1, Apple a2){
        return a1.getWeight().compareTo(a2.getWeight());
    }
});

// 람다표현식 사용
inventory.sort((Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight()));
~~~

##### 2.4.2 Runnable로 코드블록 실행하기
어떤 코드를 실행할 것인지를 스레드에게 알려주기위해서  
자바8까지는 Thread생성자에 객체만을 전달할수있었으므로  
결과를 반환하지않는 void run 메소드를 포함하는 익명클래스가 Runnable인터페이스를 구현하도록 하였다.

~~~java
//java.lang.Runnable
public interface Runnable{
    void run();
}

Thread t= new Thread(new Runnable(){
    public void run(){
        // 실행코드
        System.out.println("hello");
    }
});

//람다표현식 이용
Thread t= new Thread(()->System.out.println("hello"));
~~~

##### 2.4.3 GUI 이벤트 처리하기
자바5부터 지원하는 ExecutorService 인터페이스는 태스크 제출과 실행과정의 연관성을 끊어준다.  
이를 이용하면 태스크를 스레드 풀로 보내고 결과를 Futer로 저장할수있다.  
당장은 Callable 인터페이스를 이용해 결과를 반환하는 태스크를 만든다는 사실만 알아두자(Runnable의 업그레이드 버전)

~~~java
// java.util.concurrent.Callable
public interface Callable<V> {
    V call();
}

//실행 서비스에 태스크를 제출해서 코드를 활용할 수 있다.
ExecutorService executorService = Executors.newCachedThreadPool();
Future<String> threadName = executorService.submit(new Callable<String(){
    @Override
    public String call() throws Exception{
        return Thread.currentThread().getName();
    }
});

//람다식 이용
Future<String> threadName = executorService.submit(
    ()-> Thread.currentThread().getName()
);
~~~

##### 2.4.4 GUI 이벤트 처리하기
자바FX에서는 setOnAction메서드에 EventHandler를 전달함으로써 이벤트에 어떻게 반응할지 설정할 수 있다.  
즉, EventHandler는 setOnAction메서드의 동작을 파라미터화한다.

~~~java
Button button = new Button("Send");
button.setOnAction(new EventHandler<ActionEvent>(){
    public void handle(ActionEvent event){
        label.setText("Sent!!");
    }
});

// 람다표현식
button.setOnAction((ActionEvent event) -> labe.setText("Sent!!"));
~~~

#### 2.5 마치며
- 동작 파라미터화에서는 메서드 내부적으로 다양한 동작을 수행할 수 있도록 코드를 메서드 인수로 전달한다.
- 동작 파라미터화를 이용하면 변화하는 요구사항에 더 잘 대응할 수 있는 코드를 구현할 수 있으며 나중에 엔지니어링 비용을 줄일 수 있다.
- 코드 전달 기법을 이용하면 동작을 메서드의 인수로 전달할 수 있다. 하지만 자바 8 이전에는 코드를 지저분하게 구현해야 했다. 익명 클래스로도 어느정도 코드를 깔끔하게 만들수 있지만 자바 8에서는 인터페이스를 상속받아 여러클래스를 구현해야하는 수고를 없앨 수 있는 방법을 제공한다.
- 자바 API의 많은 메서드는 정렬, 스레드, GUI 처리 등을 포함한 다양한 동작으로 파라미터화할 수 있다.