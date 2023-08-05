## 저자 별 카테고리 별 매출액 집계하기  
2022년 1월의 도서 판매 데이터를 기준으로 저자 별, 카테고리 별 매출액(TOTAL_SALES = 판매량 * 판매가) 을 구하여, 저자 ID(AUTHOR_ID), 저자명(AUTHOR_NAME), 카테고리(CATEGORY), 매출액(SALES) 리스트를 출력하는 SQL문을 작성해주세요.  
결과는 저자 ID를 오름차순으로, 저자 ID가 같다면 카테고리를 내림차순 정렬해주세요.  

### 내가 쓴 풀이  
~~~sql
select AUTHOR.AUTHOR_ID,
AUTHOR_NAME,
CATEGORY,
SUM(TOTAL_BOOK_SALES) TOTAL_SALES
FROM 
    (select CATEGORY, AUTHOR_ID, 
            SUM(SALES) * PRICE as TOTAL_BOOK_SALES
     from BOOK_SALES JOIN BOOK
     ON BOOK.BOOK_ID = BOOK_SALES.BOOK_ID
     WHERE DATE_FORMAT(SALES_DATE,"%Y-%m") = '2022-01'
     GROUP BY BOOK.BOOK_ID) AS A 
JOIN AUTHOR ON AUTHOR.AUTHOR_ID = A.AUTHOR_ID
group by A.AUTHOR_ID, CATEGORY
order by AUTHOR_ID, CATEGORY desc;
~~~

### 다른 풀이법  
USING 은 조인할 두 컬럼의 이름이 같은경우 ON대신 사용할 수 있다.  
~~~sql
SELECT AUTHOR_ID, AUTHOR_NAME, CATEGORY, SUM(SALES *  PRICE) AS TOTAL_SALES
 FROM BOOK JOIN AUTHOR USING (AUTHOR_ID) JOIN BOOK_SALES USING (BOOK_ID)
 WHERE DATE_FORMAT(SALES_DATE, '%Y-%m') IN ('2022-01')
 GROUP BY AUTHOR_NAME, CATEGORY
 ORDER BY AUTHOR_ID ASC, CATEGORY DESC;
~~~  


