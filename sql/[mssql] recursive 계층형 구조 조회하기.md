# [mssql] recursive 계층형 구조 조회하기

erp나 인사시스템 등을 다루게 되면 부서 테이블을 다룰때 계층형 구조로 된 테이블을 자주 접할 것이다.  

테이블로 표현하면 다음과 같다.  
~~~sql
CREATE TABLE DEPT (
    DEPT_CD         VARCHAR(20)  NOT NULL,     -- 부서 코드
    PARENT_DEPT_CD  VARCHAR(20)  DEFAULT NULL,  -- 상위부서코드
    NAME            VARCHAR(30) NOT NULL,     -- 부서명
);

INSERT INTO DEPT
VALUES ('ALL', NULL, '임직원')
    , ('A', 'ALL', '임원')
    , ('B', 'ALL', '경영지원팀')
    , ('C', 'ALL', '솔루션사업본부')
    , ('C01', 'C', '솔루션개발팀')
    , ('C02', 'C', '솔루션사업팀')
    , ('D', 'ALL', '서비스사업본부')
    , ('D01', 'D', '서비스개발팀')
    , ('D0101', 'D01', '재무회계파트');
~~~

이를 계층형으로 조회할 경우 사용할 수 있는 것이 recursive 쿼리이다.  

mssql에서 recursive 쿼리의 문법은 다음과 같다.  

~~~sql 
WITH CTE테이블명(컬럼명1, 컬럼명2, 컬럼명3 ...)
AS
(
    SELECT * FROM TABLE_A -- 앵커멤버
    UNION ALL
    SELECT * FROM TABLE_A JOIN CTE테이블명 -- 재귀멤버
)
SELECT * FROM CTE테이블명;
~~~

처음에 TABLE_A를 조회하고 최초생성된 CTE테이블과 TABLE_A를 조인해서 가져오는 방식이다.

앞에서 예제로 본 부서를 계층형으로 조회하기위해서는 다음과 같은 쿼리문을 작성하면 된다.

## 모든 하위부서 찾기
사실 이렇게 조회하면 그냥 DEPT_CTE를 조회할때랑 다를게 없다.  
~~~sql
WITH DEPT_CTE AS (
  SELECT * 
  FROM DEPT WITH(NOLOCK)
  WHERE DEPT.PARENT_DEPT_CD IS NULL
  
  UNION ALL

  SELECT DEPT.* 
  FROM DEPT WITH(NOLOCK) 
  JOIN DEPT_CTE
    ON DEPT_CTE.DEPT_CD = DEPT.PARENT_DEPT_CD
)
SELECT * FROM DEPT_CTE WITH(NOLOCK);
~~~


## 모든 상위부서 찾기
다음은 재무회계파트(D0101)의 상위부서를 찾는 쿼리문이다.  
~~~sql
WITH DEPT_CTE AS (
  SELECT * 
  FROM DEPT WITH(NOLOCK)
  WHERE DEPT_CD = 'D0101'
  
  UNION ALL

  SELECT DEPT.* 
  FROM DEPT WITH(NOLOCK) 
  JOIN DEPT_CTE
    ON DEPT_CTE.PARENT_DEPT_CD = DEPT.DEPT_CD
)
SELECT * FROM DEPT_CTE WITH(NOLOCK);
~~~

그런데 만약에 재무회계파트(D0101)의 상위부서코드가 휴먼에러로 서비스개발팀(D01)이 아닌 자기자신을 가리키게된다면 해당 쿼리문은 무한반복이 일어날 것이다.  
그렇기때문에 무한루프를 발생하지않도록 방어로직을 더해주는 것이 좋을 것이다.  
기준이 되는 앵커멤버의 조건을 재귀멤버의 조인조건에서 한번 걸러주면 된다.  
~~~sql
WITH DEPT_CTE AS (
  SELECT * 
  FROM DEPT WITH(NOLOCK)
  WHERE DEPT_CD = 'D0101'
  
  UNION ALL

  SELECT DEPT.* 
  FROM DEPT WITH(NOLOCK) 
  JOIN DEPT_CTE
    ON DEPT_CTE.PARENT_DEPT_CD = DEPT.DEPT_CD
        AND DEPT.DEPT_CD != 'D0101'
)
SELECT * FROM DEPT_CTE WITH(NOLOCK);
~~~

## 깊이정보 더하기
level값이나 부서의 깊이를 '>' 등을 통해 시각적으로 나타낼수있도록 추가정보를 더하여 쿼리를 실행하면 좋을것이다.  
~~~sql
WITH DEPT_CTE AS (
  SELECT DEPT_CD, NAME, PARENT_DEPT_CD
          , 0 AS LEVEL
          , CONVERT(VARCHAR(500), DEPT_CD) AS CD_PATH
          , CONVERT(VARCHAR(500), NAME) AS NM_PATH
  FROM DEPT WITH(NOLOCK)
  WHERE DEPT.PARENT_DEPT_CD IS NULL
  
  UNION ALL

  SELECT DT.DEPT_CD, DT.NAME, DT.PARENT_DEPT_CD
          , DC.LEVEL + 1
          , CONVERT(VARCHAR(500), DC.CD_PATH + '>' + DT.DEPT_CD) AS CD_PATH
          , CONVERT(VARCHAR(500), DC.NM_PATH + '>' + DT.NAME) AS NM_PATH
  FROM DEPT DT WITH(NOLOCK) 
  JOIN DEPT_CTE DC
    ON DC.DEPT_CD = DT.PARENT_DEPT_CD
)
SELECT REPLICATE('		', LEVEL) + NAME AS 부서명
     , * 
INTO #DEPT_CTE -- 임시테이블
FROM DEPT_CTE WITH(NOLOCK)

SELECT * FROM #DEPT_CTE ORDER BY CD_PATH
~~~


## 추가 - 실적 집계해보기
부서 리프노드의 실적만 넣어서 테이블을 만들었다.  
~~~sql
CREATE TABLE DEPT_PERFORMANCE (
    DEPT_CD    VARCHAR(20),
    DEPT_AMT   BIGINT
)

INSERT INTO DEPT_PERFORMANCE 
      VALUES ('A', 10000)
      , ('B', 7000)
      , ('C01', 13000)
      , ('C02', 12000)
      , ('D0101', 18000)
~~~

해당 데이터를 이용하여 전체 실적을 집계해 보는 쿼리를 다음과 같이 작성할 수 있을 것이다.  
~~~sql
SELECT SUM(DEPT_AMT) AS DEPT_AMT, A.부서명, A.DEPT_CD, A.NAME, A.PARENT_DEPT_CD, A.LEVEL, A.CD_PATH, A.NM_PATH
FROM #DEPT_CTE A WITH(NOLOCK)
LEFT JOIN (
    SELECT DEPT_AMT, C.DEPT_CD, C.CD_PATH
    FROM #DEPT_CTE C WITH(NOLOCK)
    LEFT JOIN DEPT_PERFORMANCE B WITH(NOLOCK)
            ON C.DEPT_CD = B.DEPT_CD
) DP
ON DP.CD_PATH LIKE A.CD_PATH+'%' 
GROUP BY A.부서명, A.DEPT_CD, A.NAME, A.PARENT_DEPT_CD, A.LEVEL, A.CD_PATH, A.NM_PATH
ORDER BY A.CD_PATH
~~~

OUTER APPLY를 사용하면 다음처럼 작성 가능하다.  
~~~sql
SELECT DEPT_AMT, A.*
FROM #DEPT_CTE A WITH(NOLOCK)
OUTER APPLY (
    SELECT SUM(DEPT_AMT) DEPT_AMT
    FROM DEPT_PERFORMANCE B WITH(NOLOCK)
    INNER JOIN #DEPT_CTE C WITH(NOLOCK)
            ON C.DEPT_CD = B.DEPT_CD
           AND C.CD_PATH LIKE A.CD_PATH+'%'
) DP
ORDER BY CD_PATH
~~~


## 참고
https://hongik-prsn.tistory.com/m/78