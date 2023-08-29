# [mssql] outer apply, cross apply

사내 진행중인 프로젝트는 MSSQL을 사용하는데 처음보는 문법을 발견하였다.  
`outer apply` 가 바로 그것인데,  
추측상 outer join으로 보이는 해당 문법을 왜 사용하는지  
그리고 `outer apply` 의 역할이 정확하게 무엇인지를 알기위해 조사해보았다.  


## cross apply, outer apply
- cross apply : inner join 과 동일한 결과  
- outer apply : left outer join과 동일한 결과  

cross apply와 outer apply는 테이블 반환 함수를 사용가능한 조인 방법이며  
오른쪽 서브 쿼리(내부 테이블)에 외부 테이블의 컬럼을 인자로 제공할 수 있다.  


## 예시
예제를 위한 테이블2개(TEAM,MEMBER) 와 테이블반환함수(Fn_Team)  
~~~sql
CREATE TABLE TEAM(ID INT, NAME VARCHAR(30));
INSERT INTO TEAM VALUES(1,'기획팀'),(2,'개발팀'),(3,'구매팀'),(4,'인사팀');

CREATE TABLE MEMBER(ID INT, NAME VARCHAR(10), TEAM_ID INT);
INSERT INTO MEMBER VALUES(1,'홍길동',1),(2,'도비',2);

-- 테이블 반환 함수
CREATE FUNCTION FN_GET_TEAM (@id AS INT)
RETURNS TABLE
AS
RETURN
  SELECT * FROM TEAM WHERE ID = @id
~~~

다음 쿼리는 동일한 결과를 출력한다.  
cross apply - inner join  
~~~sql
SELECT * FROM MEMBER M CROSS APPLY ( SELECT * FROM TEAM T WHERE M.TEAM_ID = T.ID ) T;
SELECT * FROM MEMBER M INNER JOIN TEAM T ON M.TEAM_ID = T.ID;
~~~  
outer apply - left outer join  
~~~sql
SELECT * FROM MEMBER M OUTER APPLY ( SELECT * FROM TEAM T WHERE M.TEAM_ID = T.ID ) A
SELECT * FROM MEMBER M LEFT OUTER JOIN TEAM T ON M.TEAM_ID = T.ID
~~~

## 장점
1. JOIN문을 사용하면 다음과 같은 쿼리 사용은 불가능하지만  
APPLY문을 사용하면 가능하다.  
~~~sql
-- 테이블 반환함수에 왼쪽 테이블의 컬럼을 인자로 전달
SELECT M.ID, M.NAME, T.NAME
FROM MEMBER M
CROSS APPLY (SELECT NAME FROM FN_GET_TEAM(M.TEAM_ID) T) T
~~~

2. 특정 상황에서는 JOIN 보다 더 좋은 성능을 발휘할수있기때문에 이용된다.  
(APPLY와 TOP을 함께 사용하는 예시)  
~~~sql
-- 팀원이 없는 팀정보 추출
-- TOP 1을 사용하여 필요한 인덱스키에만 액세스하여 성능향상을 기대할 수 있음
SELECT T.ID, T.NAME
FROM TEAM T
OUTER APPLY (SELECT TOP 1 TEAM_ID FROM MEMBER M WHERE T.ID = M.TEAM_ID) M
WHERE M.TEAM_ID IS NULL;

-- 동일한 결과를 반환하는 LEFT JOIN
-- 인덱스 키에 전체 액세스 하게되어 성능이 떨어질 수 있음
SELECT T.ID, T.NAME
FROM TEAM T
LEFT JOIN MEMBER M ON T.ID = M.TEAM_ID
WHERE M.TEAM_ID IS NULL
~~~


## 주의점
SQL Server 2005 이상에서 사용가능  
조인조건을 주지않으면 Catesian Product로 동작  

## 참고
[[MSSQL]CROSS APPLY 와 OUTER APPLY 그리고 JOIN 의 차이점](https://mozi.tistory.com/311)  
[[MSSQL]CROSS APPLY, OUTER APPLY 활용 및 예제(APPLY 연산자)](https://goldswan.tistory.com/16)