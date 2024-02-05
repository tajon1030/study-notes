# 예외처리 Checked Exceptionm UnChecked Exception
<img src = "https://github.com/tajon1030/study-notes/assets/60431816/c6836512-4c9b-4ea1-92ca-bf2e3798578a"  height="300"/>

## Error vs Exception
- Error 오류 : 발생 상황이 일관적이지 않으며 수습할수 없는 심각한 문제이기때문에 예측하여 방지할 수 없다.  
java.lang.error  
ex) OutOfMemoryError, IOError  
- Exception 예외 : 개발자가 구현한 로직에서 발생한 실수나 사용자의 영향에 의해 발생한다.  
문제가 발생할 상황을 미리 예상해서 별도의 루틴으로 처리  
java.lang.Exception  
ex) NullPointerException, SqlException  



## ChcekdException vs UnCheckedException
### CheckedException
컴파일 Exception  
에러체크가 가능하여 try-catch를 통해 예외처리를 강제함  

### UnCheckedException
런타임 Exception  
예외처리를 강제하지 않는다.

#### UnCheckedException 예시
1. NPE(NullPointerException)  
null인 객체에 연산을 하거나 null에 사용할수 없는 메소드를 체이닝 걸 경우 발생  
Optional을 이용하거나 if-else문을 이용하여 nullCheck를 한다.​

2. ArrayIndexOutOfBoundsException  
배열 범위 이상을 사용할 경우 발생  

## 예외던지기 throws  
기본적인 예외처리는 try-catch문으로 하는것이 보통  
그러나 자신을 부른 메서드에 Exception문을 넘겨서 처리도 가능하다.  
예를 들어 method1에서 method2를 처리하는데 예외가 발생한다면, 이 예외는 method2에서 처리할수도 있지만, throws로 method1에 예외를 던져줄 수 있다.  
~~~java
    public static void method1(){
        try{
            method2();
        }catch (ClassNotFoundException e){ // 3. 던져진 method2의 Exception을 잡아냄
            e.printStackTrace(); // 에러처리
        }finally {
            System.out.println("finish");
        }
    }

    private static void method2() throws ClassNotFoundException { // 2. ClassNotFoundException이 던져짐
        Class clazz = Class.forName("java.lang.존재하지않는class"); // 1. 예외가 발생한다면
    }
~~~


## 참고
https://catch-me-java.tistory.com/46  
