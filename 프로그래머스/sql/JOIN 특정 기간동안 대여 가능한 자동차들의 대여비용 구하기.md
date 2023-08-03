## 특정 기간동안 대여 가능한 자동차들의 대여비용 구하기
  
CAR_RENTAL_COMPANY_CAR 테이블과 CAR_RENTAL_COMPANY_RENTAL_HISTORY 테이블과 CAR_RENTAL_COMPANY_DISCOUNT_PLAN 테이블에서 자동차 종류가 '세단' 또는 'SUV' 인 자동차 중 2022년 11월 1일부터 2022년 11월 30일까지 대여 가능하고 30일간의 대여 금액이 50만원 이상 200만원 미만인 자동차에 대해서 자동차 ID, 자동차 종류, 대여 금액(컬럼명: FEE) 리스트를 출력하는 SQL문을 작성해주세요. 결과는 대여 금액을 기준으로 내림차순 정렬하고, 대여 금액이 같은 경우 자동차 종류를 기준으로 오름차순 정렬, 자동차 종류까지 같은 경우 자동차 ID를 기준으로 내림차순 정렬해주세요.

### 내가 쓴 풀이  
~~~sql
SELECT CAR_ID, CAR.CAR_TYPE,  (30 * DAILY_FEE * (100-DISCOUNT_RATE)/100, 0) AS FEE
FROM CAR_RENTAL_COMPANY_CAR CAR 
JOIN CAR_RENTAL_COMPANY_DISCOUNT_PLAN PLAN 
ON CAR.CAR_TYPE = PLAN.CAR_TYPE
WHERE CAR.CAR_TYPE IN ('세단','SUV') 
AND SUBSTRING_INDEX(PLAN.DURATION_TYPE, "일", 1) = 30
AND CAR_ID NOT IN (SELECT CAR_ID
                  FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY HISTORY
                  WHERE DATE_FORMAT(START_DATE,"%Y-%m") = '2022-11' OR
                  DATE_FORMAT(END_DATE,"%Y-%m") = '2022-11' OR
                  (DATE_FORMAT(START_DATE,"%Y-%m") < '2022-11' AND DATE_FORMAT(END_DATE,"%Y-%m") > '2022-11'))
AND TRUNCATE(30 * DAILY_FEE * (100-DISCOUNT_RATE)/100,0) >=500000 AND TRUNCATE(30 * DAILY_FEE * (100-DISCOUNT_RATE)/100,0) <2000000
ORDER BY FEE DESC, CAR_TYPE, CAR_ID DESC;
~~~

TRUNCATE 명령어는 테이블의 내용을 전부 제거할때 쓰인다.  
TRUNCATE()은 함수로써 숫자의 특정 자리수 이하를 버리는 역할을 한다.  


### 다른 사람의 풀이 1   
~~~sql
select cpcar.CAR_ID, cpcar.CAR_TYPE, FLOOR(cpcar.DAILY_FEE * 30 * (1 - DISCOUNT_RATE * 0.01)) as FEE
from CAR_RENTAL_COMPANY_CAR as cpcar
    left join CAR_RENTAL_COMPANY_RENTAL_HISTORY as history
        on cpcar.CAR_ID = history.CAR_ID
            left join  CAR_RENTAL_COMPANY_DISCOUNT_PLAN as dct
                on  cpcar.CAR_TYPE = dct.CAR_TYPE
where cpcar.CAR_TYPE in ('세단','SUV') 
    and DURATION_TYPE = '30일 이상' 
group by cpcar.CAR_ID
having (max(END_DATE) < '2022-11-01' or max(END_DATE) is null) 
    and FEE between 500000 and 2000000
order by FEE desc, cpcar.CAR_TYPE asc, PLAN_ID desc
~~~


### 다른 사람의 풀이 2  
~~~sql
SELECT
    A.CAR_ID,
    A.CAR_TYPE,
    ROUND(A.DAILY_FEE * 30 * (1 - B.DISCOUNT_RATE/100)) AS FEE
FROM
    CAR_RENTAL_COMPANY_CAR A
INNER JOIN
   CAR_RENTAL_COMPANY_DISCOUNT_PLAN B 
ON
    A.CAR_TYPE = B.CAR_TYPE
WHERE
    A.CAR_TYPE REGEXP '세단|SUV' AND
    B.DURATION_TYPE = '30일 이상' AND
    A.CAR_ID NOT IN (
        SELECT CAR_ID
        FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY
        WHERE END_DATE >= '2022-11-01' AND START_DATE <= '2022-11-30'
    )
HAVING 
    FEE >= 500000 AND FEE < 2000000
ORDER BY
    FEE DESC, 
    A.CAR_TYPE ASC, 
    A.CAR_ID DESC
~~~

내가 쓴 풀이와 비슷한데 날짜 조건이 좀더 간단하다.  
또한 나는 where로 fee의 범위를 설정하려할때 오류가 나서 같은 쿼리문을 반복했는데  
having같은 경우 group by가 없더라도 사용할 수 있다는 점을 활용해 조건을 추가한것으로 보인다.  