# [mssql] 자주 사용하는 update문

## 기본적인 update
~~~sql
UPDATE product
SET price = 2500
  , expdate = convert(datetime, '2023-09-10')
WHERE id = 153202
~~~  
흔하게 볼수있는 기본적인 update문으로  
업데이트할 컬럼이 여러개일때 콤마를 사용한다.


## 다른테이블과 조인하는 update  
SQL Server에서는 UPDATE문에서 FROM 절을 사용할 수 있다.  

다른테이블에서 데이터를 조회한 결과를 이용하여 update 해야하는 경우  
쿼리를 작성하면 다음과 같다.  
~~~sql
UPDATE product
SET a.sale_p = b.sale_p, a.price = b.price
FROM product a
JOIN 임시엑셀테이블 b
ON a.id = b.id
~~~

~~~sql
UPDATE product
SET a.sale_p = b.sale_p, a.price = b.price
FROM product a, 임시엑셀테이블 b
WHERE a.id = b.id
~~~


## 서브쿼리를 사용하여 update
서브쿼리의 결과는 하나의 행, 하나의 열이 조회되어야한다.  
~~~sql
UPDATE product
SET expdate = (SELECT a.expdate FROM product a WHERE a.id = 44932)
WHERE id IN (59234, 22034) 
~~~  

WHERE절에서 서브쿼리를 사용하여 업데이트할 데이터 항목을 가져올 수 있다.  
~~~sql
UPDATE product
SET sale_p = 0.3
WHERE id IN (SELECT a.id
             FROM 임시엑셀테이블 a
             WHERE a.expdate < convert(datetime, '2023-09-10'))
~~~

## 참고
[[MSSQL] UPDATE 문 사용법 3가지 (데이터 수정)](https://gent.tistory.com/499)  