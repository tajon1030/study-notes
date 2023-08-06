## 식품분류별 가장 비싼 식품의 정보 조회하기

FOOD_PRODUCT 테이블에서 식품분류별로 가격이 제일 비싼 식품의 분류, 가격, 이름을 조회하는 SQL문을 작성해주세요. 이때 식품분류가 '과자', '국', '김치', '식용유'인 경우만 출력시켜 주시고 결과는 식품 가격을 기준으로 내림차순 정렬해주세요.  

### 내가 쓴 풀이  
~~~sql
select a.CATEGORY, MAX_PRICE, PRODUCT_NAME
from 
(select category, max(price) MAX_PRICE
from FOOD_PRODUCT
where category in ('과자', '국', '김치', '식용유')
group by category
) a 
join FOOD_PRODUCT fp on MAX_PRICE = price
and a.category = fp.category
order by MAX_PRICE desc;
~~~

### 다른 풀이법1  
다중컬럼 in
~~~sql
SELECT CATEGORY, PRICE, PRODUCT_NAME
FROM FOOD_PRODUCT
WHERE (CATEGORY, PRICE) IN (
    SELECT CATEGORY, MAX(PRICE)
    FROM FOOD_PRODUCT
    GROUP BY CATEGORY
    HAVING CATEGORY IN ('과자', '국', '김치', '식용유')
)
ORDER BY PRICE DESC;
~~~

### 다른 풀이법2  
카테고리별 price 내림차순대로 순위를 정한뒤 1순위 값만 가져오는 방식
~~~sql
SELECT category, price, PRODUCT_NAME 
FROM (
  SELECT category, price, PRODUCT_NAME, ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS row_num
  FROM FOOD_PRODUCT
  WHERE category IN ('과자', '국', '김치', '식용유')
) AS subquery
WHERE row_num = 1
ORDER BY PRICE DESC;
~~~

### 다른 풀이법3  
~~~sql
WITH TEMP AS (
    SELECT CATEGORY, MAX(PRICE) AS MAX_PRICE
    FROM FOOD_PRODUCT
    WHERE CATEGORY = '과자' or CATEGORY = '국' or CATEGORY = '김치' or CATEGORY = '식용유'
    GROUP BY CATEGORY
)
SELECT T.CATEGORY, T.MAX_PRICE, F.PRODUCT_NAME
FROM TEMP T 
INNER JOIN FOOD_PRODUCT F 
ON T.CATEGORY = F.CATEGORY 
AND T.MAX_PRICE = F.PRICE
ORDER BY T.MAX_PRICE DESC
~~~