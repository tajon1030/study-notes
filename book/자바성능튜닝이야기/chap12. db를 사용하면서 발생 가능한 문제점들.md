## db를 사용하면서 발생 가능한 문제점들

### DB Connection, Connection Pool, DataSource
1. 드라이버 로드  
2. connectjon객체 만들기  
3. preparedStatement객체 받기  
4. executeQuery수행하여 처리하고 ResultSet객체 받기  
5. finally를 사용하여 ResultSet, PreparedStatement, Connectionㅡ객체 닫기  
~~~java
try{
    Class.forName("oracle.jdbc.driver.OracleDriver");
    Connection con = DriverManager.getConnection("jdbc:oracle:thin@ServerIP:1521:SID","ID","PW");
    PreparedStatement ps = con.prepareStatement("SELECT ... WHERE ID = ?");
    ps.setString(1,id);
    ResultSet rs = ps.executeQuery();
}catch(ClassNotFoundExcetpion e){
    System.out.println("드라이버 load fail");
    throw e;
}catch(SQLException e){
    System.out.println("Connecton fail");
    throw e;
}finally{
    try{rs.close();}catch(Exception res){}
    try{ps.close();}catch(Exception pse){}
    try{con.close();catch(Exception cone){}
}
~~~

#### Statement 와 PreparedStatement 차이
둘의 차이는 캐시 사용여부가 가장 큰 차이점이다.  
Statement를 사용할때 쿼리문장분석, 컴파일, 실행의 프로세스를 거치게 되는데
PreparedStatement는 동일한 쿼리를 수행할때 처음 한번만 세 단계를 거치고 이후로는 캐시에 담아서 재사용하여 더 적은 부하를 가지게 된다.

#### Statement 관련 메서드
- executeQuery() : select 관련 쿼리 수행하여 결과값을 ResultSet으로 전달  
- executeUpdate() : DML 및 DDL 쿼리를 수행하여 int 결과값 리턴  
- execute() : 쿼리 종류와 상관없이 수행하여 boolean형태로 데이터를 리턴  

#### ResultSet
next() 메서드를 사용하여 데이터의 커서를 다음으로 옮기면서 처리한다.  
first() 메서드나 last() 메서드를 이용하여 가장 처음이나 마지막커서로 이동가능하며,  
getInt(), getLong() 등의 메서드를 사용하여 데이터를 읽어온다.  
(last메서드의 경우 건수가 많을경우 대기시간이 증가하여 속도차이가 나기때문에 전체건수를 구하고싶을경우에는 count 구문을 이용해야하며, 사용을 자제해야한다.)

### DB를 사용할 때 닫아야 하는 것들
ResultSet, Statement, Connection 순으로 닫아야함  
해당 객체들은 모두 GC대상이 되면 자동으로 닫히게 되고,  
ResultSet객체는 관련된 Statement객체의 close메서드가 호출되는 경우 알아서 닫히게 되지만,  
자동으로 호출되기 전 리소스를 해제하면 조금이라도 더 빠르게 닫을수있게되어 DB서버 부담이 적어지게 된다.  
또한 커넥션풀을 사용하여 커넥션이 대부분 관리되기때문에 gc가 될때까지 기다리기에는 conenctionPool이 부족해지는게 시간문제  
따라서 `rs = null ` 과 같이 null 치환 방식은 좋지 않은 방식이며  
try-catch-finally의 흐름을 생각하여 오류 발생시에도 객체가 닫힐수있도록 finally에 close를 선언하거나  
try-with-resources 구문을 사용하도록 한다.  

### AutoClosable 인터페이스 (jdk7)
AutoClosable인터페이스에는 리턴타입이 void인 close 메서드 한개만 선언되어있는데  
이 메서드는 try-with-resources문장으로 관리되는 객체에 대해 자동으로 close처리를 해준다.  

### JDBC를 사용하면서 유의해야할 팁
- setAutoCommit() 메서드는 필요할 때만 사용하자  
- 배치성 작업은 executeBatch() 메서드를 사용하자  
- setFetchSize() 메서드를 사용하여 데이터를 더 빠르게 가져오자  
- 한건만 필요할때에는 한건만 가져오자  


### 참고
https://javacan.tistory.com/entry/78  