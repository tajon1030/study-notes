# equals 와 hashCode
## equals()
동등성 비교  
두 객체의 내용이 같은지 확인하는 method  
equals() 메소드는 두 객체를 비교해서 논리적으로 동등하면 true를 리턴하고 그렇지 않으면 false를 리턴한다.  
(논리적으로 동등하다는것은 둘의 참조값이 다르더라도 객체 내부 value는 같다는것을 의미)  
Object클래스의 equals() 메소드는 객체의 참조값이 같은지를 비교하기때문에 equals메서드를 오버라이딩해서 내용이 같은지 재정의해줘야 올바르게 작동한다.  

~~~java  
class MemberVO{
	public String id;

    @Override
	public boolean equals(Object obj) {
		if(obj instanceof MemberVO){
			MemberVO memberVO = (MemberVO) obj;
			if(id.equals(memberVO.id)){
				return true;
			}
		}
		return false;
	}
}
~~~

### equals의 규약  
Object 클래스의 equals메서드 명세를 보면 다음과 같은 규약이 있다.  
- 반사성(reflexivity) : null이 아닌 모든 참조 값 x에 대해, x.equals(x)는 true다.  
- 대치성(symmetry) : null이 아닌 모든 참조 값 x,y에 대해, x.equals(y)가 true면 y.equals(x)도 true다.  
- 추이성(transitivity) : null이 아닌 모든 참조 값 x, y, z에 대해, x.equals(y)가 true고 y.equals(z)도 true면 x.equals(z)도 true다.  
- 일관성(consistency) : null이 아닌 모든 참조 값 x,y에 대해 x.equals(y)를 반복해서 호출하면 항상 true를 반환하거나 항상 false를 반환한다.  
- Non-Null : null이 아닌 모든 참조 값 x에 대해, x.equals(null)은 항상 false 이다.  



## hashCode()
객체를 구분하기위한 정수값(해시코드)을 리턴하는 함수이다.  
Object의 hashCode() 메소드는 객체의 메모리 번지를 이용해서 해시코드를 만들어 리턴하기 때문에 객체 마다 다른 값을 가지고 있다.   
hashcode는 컬렉션 프레임워크에서 key값으로 이용할경우 중복값인지를 확인하는데 사용되기때문에(해시코드 값이 다르면 다른 객체로 판단)  
객체의 동등 비교를 위해서 equals() 메소드뿐 아니라 hashCode() 메소드도 함께 재정의하여 논리적 동등 객체일 경우 동일한 해시 코드가 리턴 되도록 해야 한다.  

~~~java
class MemberVO{
	public String id;

	@Override	
	public boolean equals(Object obj) {
		if(obj instanceof MemberVO){
			MemberVO memberVO = (MemberVO) obj;
			if(id.equals(memberVO.id)){
				return true;
			}
		}
		return false;
	}

	@Override
	public int hashCode(){
		return id.hasnCode(); //id가 동일한 문자열인 경우 같은 해시 코드를 리턴
	}
}
~~~


### 해시충돌
해싱 알고리즘상 서로다른 두 주소값을 가지고 있는 객체는 같은 해시코드를 가질 수 없으나  
hashCode가 int형 정수를 반환하기때문에 64비트 컴퓨터일 경우에 8바이트(64bit) 주소값을 반환할경우 4바이트로(32bit) 강제캐스팅(long -> int) 되어 해시충돌이 일어날 수도 있다.  
그러나 Collection(HashSet,HashMap...)의 key값을 구분할때  
hashCode로 우선적으로 구분하여 hashCode값이 일치하지않을경우에는 다른객체라고 판단하고,  
일치할 경우에는 equals를 통해 다시 비교하여 다른객체인지 구분하는 과정을 거치기때문에  
동일객체임을 확인하는데에는 문제가 없다.  
다만 해시충돌이 많이 발생하면 성능상 좋지 않다.  


### hashCode의 규약  
- equals 비교에 사용되는 정보가 변경되지 않았다면, hashCode 메서드는 일관되게 항상 같은 값을 반환해야 한다.  
단, 애플리케이션을 다시 실행한다면 이 값이 달라져도 상관없다.  
- equals(Object)가 두 객체를 같다고 판단했다면, hashCode도 같은 값을 반환해야 한다.  
- equals(Object)가 두 객체를 다르다고 판단했더라도, 두 객체의 hashCode가 서로 다른 값을 반환할 필요는 없다.  
단, 다른 객체에 대해서는 다른 값을 반환해야 해시테이블의 성능이 좋아진다.



## 롬복을 통한 구현
롬복을 이용할 경우 다음과 같이 나타낼 수 있다.  
~~~java
@EqualsAndHashCode(of = "orderId") // orderId를 이용하여 동등성비교
public class OrderQueryDto {
...
}
~~~


## 참고  
[객체의 hashCode는 고유하지않다](
https://inpa.tistory.com/entry/JAVA-%E2%98%95-%EA%B0%9D%EC%B2%B4%EC%9D%98-hashCode%EB%8A%94-%EA%B3%A0%EC%9C%A0%ED%95%98%EC%A7%80-%EC%95%8A%EB%8B%A4-%E2%9D%8C)  
[euqls를 재정의하려거든 hashCode도 재정의하라](https://be-study-record.tistory.com/53#article-1--hashcode?)