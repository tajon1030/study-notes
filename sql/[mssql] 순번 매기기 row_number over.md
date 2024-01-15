# [mssql] row_number over

현재 저는 회사에서 사용하는 mssql 버전이 12버전 미만이라 페이징 처리할 때는 물론이고,  
각종 db데이터를 집어넣을때 ROW_NUMBER 라는 함수를 많이 사용하고 있습니다.  

## 순번매기기  
ROW_NUMBER OVER 함수는 기본적으로 순번을 매기기 위한 기능으로 **ORDER BY**와 함께 쓰입니다.  
만약 ORDER BY를 작성하지 않는다면  
> "row_number" 함수에는 ORDER BY가 포함된 OVER 절이 있어야 합니다.  
와 같은 오류메시지를 보게될것입니다.  

ROW_NUMBER 값은 ORDER BY 절에 적힌 컬럼을 기준으로 순번을 결정짓게되고  
SELECT 절 맨 뒤에 ORDER BY를 적지않더라도 OVER절 내부의 ORDER BY 기준으로 정렬하여 조회결과를 출력하게 됩니다.  
~~~sql
SELECT ROW_NUMBER() OVER(ORDER BY col DESC) as rn
FROM tb
-- ORDER BY col ---(없어도 된다!)
~~~
SELECT 절 뒤에 ROW_NUMBER() OVER절 내부의 ORDER BY 기준과 다른 기준을 작성한다면  
순번은 OVER 절 안에 있는 기준으로 매겨지지만  
조회는 SELECT 절 뒤에 붙은 ORDER BY 기준으로 이루어집니다.  

이렇게 순번을 결정지어서 다음과 같이 페이징처리를 할 수 있습니다.
~~~sql
SELECT T.COL1
  FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY COL1) AS RN
              , COL1
          FROM TB1
       ) T
 WHERE T.RN BETWEEN ({pageNo} - 1) * {pageSize} + 1 AND {pageNo} * {pageSize}
~~~


## 정렬없이 순번 매기기  
그럴일은 거의 없겠지만 만약 정렬과는 상관없이 조회된 순서로만 순번을 매기고싶다면  
ORDER BY 절은 필수이므로 `ROW_NUMBER() OVER(ORDER BY (SELECT 1))` 처럼 선언하면 됩니다.  

## 그룹별 순서 매기기 
그룹별 순서를 매길때에는 PARTITION BY라는 절과 함께 쓰입니다.  

### 임시테이블  
|  유저ID     |   작성일자   |   적요  |
|-------|------------|-----|
| 12345 | 2024-01-02 | abc |
| 12345 | 2024-01-02 | def |
| 12345 | 2024-01-05 | ab  |
| 23456 | 2024-01-01 | c   |

### 세금계산서테이블
|  유저ID     |      작성일자      |   순번  |   적요  |
|-------|------------|---|-----|
| 12345 | 2024-01-02 | 1 | abc |
| 12345 | 2024-01-02 | 2 | def |
| 12345 | 2024-01-05 | 1 | ab  |
| 23456 | 2024-01-01 | 1 | c   |


~~~sql
-- 임시테이블에 있는 값으로 세금계산서테이블에 값을 넣을때
INSERT INTO 세금계산서테이블
SELECT 유저ID
     , 작성일자
     , ROW_NUMBER() OVER(PARTITION BY 유저ID, 작성일자 ORDER BY 유저ID, 작성일자, 적요) AS 순번
     , 적요
  FROM 임시테이블
~~~

## 참고
[[MSSQL] 순번 매기기 (ROW_NUMBER 함수)](https://gent.tistory.com/581)  
