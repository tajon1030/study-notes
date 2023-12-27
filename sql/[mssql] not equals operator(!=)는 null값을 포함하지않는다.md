# [mssql] not equals operator(!=)는 null값을 포함하지 않는다.

쿼리문을 작성할때 null값을 제대로 이해하고있어야 원하는 결과값을 출력할수있습니다.  
실례로 사내에서 프로젝트를 진행하며 조건문에 != 연산자를 이용한 쿼리문을 작성했는데, null값을 포함하지않아 예상했던 결과값을 반환하지않는 상황을 겪었습니다.  
따라서 이번기회에 null값의 처리에 대해 정리해보고자 합니다.  

1. null을 조건으로 사용할 때에는 = 비교연산자가 아닌 **IS NULL** 혹은 **IS NOT NULL**을 사용해야 합니다.  
2. **!=** 비교연산자는 **NULL값을 포함하지 않습니다**  
3. **ORACLE**에서는 **빈문자열''을 NULL**로 인식합니다.  
따라서 oracle의 빈문자열은 = 비교연산자를 이용할수없으며(빈문자열이 있어도 조회하지못하기때문)  
IS NULL로 NULL값과 공백을 다 처리할 수 있습니다.  
~~~sql
INSERT INTO TEST_TB (id, name) VALUES (1, NULL); 
INSERT INTO TEST_TB (id, name) VALUES (2, '');
INSERT INTO TEST_TB (id, name) VALUES (3, 'JAKE'); 
--oracle
SELECT name FROM TEST_TB WHERE name IS NOT NULL -- JAKE
SELECT name FROM TEST_TB WHERE name = '' -- 0건 조회
SELECT name FROM TEST_TB WHERE name != 'JAKE' -- 0건 조회
~~~

4. **MSSQL**에서는 빈문자열은''을 NULL값과는 **다른것**으로 인식합니다.  
~~~sql
INSERT INTO TEST_TB (id, name) VALUES (1, NULL); 
INSERT INTO TEST_TB (id, name) VALUES (2, '');
INSERT INTO TEST_TB (id, name) VALUES (3, 'JAKE'); 
--mssql
SELECT name FROM TEST_TB WHERE name IS NOT NULL -- 2건 조회 JAKE, ''
SELECT name FROM TEST_TB WHERE name = '' -- 1건 조회 ''
SELECT name FROM TEST_TB WHERE name != 'JAKE' -- 1건 조회 ''
~~~  

5. null을 **사칙연산하면 결과값은 null**이 되므로 **ISNULL(null,0)**과 같이 NULL값을 치환하여 사용해야합니다.  
(MSSQL기준 ISNULL, MySQL기준 IFNULL, Oracle기준 NVL)  

6. 컬럼을 **직접 count**하거나 **group by** 하는 경우 **null은 제외**됩니다.  
~~~sql
SELECT COUNT(*) FROM 테이블명 -- 결과: 100
SELECT COUNT(컬럼명) FROM 테이블명 WHERE 컬럼명 IS NOT NULL -- 결과: 80
SELECT COUNT(컬럼명) FROM 테이블명 WHERE 컬럼명 IS NULL -- 결과: 0
SELECT 컬럼명, COUNT(컬럼명) FROM 테이블명 GROUP BY 컬럼명 
-- 결과:
-- NULL 0
-- 값1 50
-- 값2 30
~~~  
만약 NULL값을 포함하는 결과값을 원한다면 다음과 같이 **ISNULL**(mssql) 혹은 **CASE WHEN THEN ELSE END**구문 등을 이용하여 NULL값에 대한 처리를 추가로 해주어야 합니다.  
~~~sql
-- mssql
SELECT name FROM TEST_TB WHERE name IS NULL OR name = '' -- 2건 조회
SELECT name FROM TEST_TB WHERE NULLIF(name,'') IS NULL -- 2건 조회
SELECT ISNULL(컬럼명, 'NULL') FROM 테이블명 WHERE 컬럼명 != 'NULL' -- 결과: 20
SELECT 컬럼명, COUNT(ISNULL(컬럼명, 'NULL')) FROM 테이블명 GROUP BY 컬럼명 
-- 결과:
-- NULL 20
-- 값1 50
-- 값2 30
~~~

## 참고
[[Oracle] 오라클 NULL 사용시 주의사항 정리](https://gent.tistory.com/281)  
[[MySQL] Empty 및 Null 체크 방법](https://needneo.tistory.com/242)  
[[MSSQL] ISNULL 함수 사용법 (NVL, NVL2, IFNULL)](https://gent.tistory.com/373)  
[SQLTest](https://sqltest.net/)  