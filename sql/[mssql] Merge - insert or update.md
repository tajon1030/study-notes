# [mssql] Merge - insert or update

업무중 특정 테이블에 기존에 저장한 레코드가 있으면 UPDATE를 하고, 없으면 INSERT를 해야하는 상황이 발생하였다.  

해당 상황을 예를 들어 설명하면 다음과 같다.  
우리가 어플을 사용해서 배달음식을 주문할때 요청사항을 작성하게 되는데,  
요청사항을 주문과는 별개로 ORDER_REQUEST라는 테이블로 따로 관리를 한다고 가정해보자.  
요청사항이 없다면 레코드를 저장할 필요가 없으며, 요청사항을 작성한다면 레코드를 저장하는 로직을 거칠 것이다.  
그런데 만약 주문을 완료한 이후에 요청사항을 수정할 경우, 혹은 작성하지않았던 요청사항을 추가할 경우에는 어떻게 처리를 하면 좋을까?  

해당 테이블을 SELECT 하여 값의 존재여부를 파악한후 INSERT를 하거나 UPDATE를 하도록 분기를 나눠서 로직을 구현할수도 있으나,  
그러한 방식은 쿼리문을 두번 수행하고, 나눠지는 분기를 위해 세개의 쿼리를 작성해야하기때문에 비효율적이라고 느껴서 다른 방식을 찾아보았다.  
검색결과 MYSQL의 경우 `ON DUPLICATRE KEY UPDATE`라는 구문을 붙이면 된다고 하였으나,  
회사에서 사용하는 DB는 MSSQL이기때문에 `MERGE` 구문을 사용하게 되었다.  


## MERGE
기본적인 문법은 다음과 같다.  
~~~sql
MERGE INTO 변경할 테이블  -- TARGET 테이블
USING 비교할테이블|서브쿼리 AS 별칭  -- SOURCE 테이블
ON 조건문
WHEN MATCHED 추가 조건 THEN
-- 조건을 만족할경우
    UPDATE SET 컬럼 = '값'
    DELETE
WHEN NOT MATCHED 추가 조건 THEN
-- 조건을 만족하지 않을 경우
    INSERT (컬럼) VALUES ('값')
~~~


### 단일 테이블을 사용할 경우
Oracle의 경우 DUAL을 `USING` 절에 사용하면 되지만,  
MSSQL의 경우에는 해당 문법이 없기때문에 dummy 서브쿼리를 사용한다.  
~~~sql
DECLARE @orderid INT = 25
DECLARE @content NVARCHAR(50) = '문앞에두고 문자주세요'

MERGE INTO ORDER_REQUEST AS o
USING (SELECT 1 AS dual) AS d
ON (o.orderid = @orderid)
WHEN MATCHED THEN
    UPDATE SET o.content = @content, o.modified_date = GETDATE()
WHEN NOT MATCHED THEN
    INSERT(orderid, content, regdate) VALUES(@orderid, @content, GETDATE());
~~~


### 기타
`NOT MATCHED`의 경우 `BY TARGET` 혹은 `BY SOURCE`라는 구문을 붙여서 사용할 수 있는데,  
`NOT MATCHED BY TARGET`은 `NOT MATCED`와 동일하여, 데이터가 TARGET 테이블에 없는 경우 TARGET 테이블에 INSERT함을 의미하고,  
`NOT MATCHED BY SOURCE`는 데이터가 SOURCE 테이블에는 없고 TARGET 테이블에만 존재한다면 TARGET 테이블에서 DELETE함을 의미한다.



### 참고
[젠트의 프로그래밍 세상](https://gent.tistory.com/371)
[microsoft-MERGE(Transact-SQL)](https://learn.microsoft.com/ko-kr/sql/t-sql/statements/merge-transact-sql?view=sql-server-ver16)