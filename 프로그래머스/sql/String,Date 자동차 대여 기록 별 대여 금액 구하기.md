## 자동차 대여 기록 별 대여 금액 구하기  
CAR_RENTAL_COMPANY_CAR 테이블과 CAR_RENTAL_COMPANY_RENTAL_HISTORY 테이블과 CAR_RENTAL_COMPANY_DISCOUNT_PLAN 테이블에서 자동차 종류가 '트럭'인 자동차의 대여 기록에 대해서 대여 기록 별로 대여 금액(컬럼명: FEE)을 구하여 대여 기록 ID와 대여 금액 리스트를 출력하는 SQL문을 작성해주세요. 결과는 대여 금액을 기준으로 내림차순 정렬하고, 대여 금액이 같은 경우 대여 기록 ID를 기준으로 내림차순 정렬해주세요.  

### 내가 쓴 풀이  
~~~sql
WITH TEMP AS (
select SUBSTRING_INDEX(DURATION_TYPE,'일 이상',1) as DURATION_TYPE, 
    SUBSTRING_INDEX(DISCOUNT_RATE,'%',1) as DISCOUNT_RATE
from CAR_RENTAL_COMPANY_DISCOUNT_PLAN
where CAR_TYPE = '트럭'
)

select HISTORY_ID,
ROUND(DAILY_FEE * (datediff(END_DATE, START_DATE)+1) * 
      (1- case
        when datediff(END_DATE, START_DATE) >= 90 
        then (select DISCOUNT_RATE from TEMP where DURATION_TYPE = 90)
        when datediff(END_DATE, START_DATE) >= 30 
        then (select DISCOUNT_RATE from TEMP where DURATION_TYPE = 30)
        when datediff(END_DATE, START_DATE) >= 7 
        then (select DISCOUNT_RATE from TEMP where DURATION_TYPE = 7)
        else 0
        end /100)
) as FEE
from CAR_RENTAL_COMPANY_RENTAL_HISTORY history
join CAR_RENTAL_COMPANY_CAR car
using (CAR_ID)
where car.CAR_TYPE = '트럭'
order by FEE desc, HISTORY_ID desc;
~~~

### 다른 풀이법1  
~~~sql
SELECT history_id, round(daily_fee * (timestampdiff(day, start_date, end_date)+1) * (100 - (
    case
        when (timestampdiff(day, start_date, end_date)+1) >= 90
        then (select discount_rate from car_rental_company_discount_plan where duration_type = '90일 이상' and car_type = '트럭')
        when (timestampdiff(day, start_date, end_date)+1) >= 30
        then (select discount_rate from car_rental_company_discount_plan where duration_type = '30일 이상' and car_type = '트럭')
        when (timestampdiff(day, start_date, end_date)+1) >= 7
        then (select discount_rate from car_rental_company_discount_plan where duration_type = '7일 이상' and car_type = '트럭')
        else 0
    end
)) * 0.01) fee
from car_rental_company_rental_history history join car_rental_company_car using(car_id)
where car_type = '트럭'
order by fee desc, history_id desc;
~~~  

%를 따로 제거해주지 않아도 됨

### 다른 풀이법2  
~~~sql
WITH final AS (
    SELECT h.history_id, 
           h.car_id,
           DATEDIFF(end_date, start_date)+1 AS duration,
           c.car_type,
           c.daily_fee,
           d.discount_rate
    FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY h
    JOIN CAR_RENTAL_COMPANY_CAR c ON c.car_id = h.car_id 
    LEFT JOIN CAR_RENTAL_COMPANY_DISCOUNT_PLAN d 
        ON d.car_type = c.car_type 
           AND d.duration_type = 
               CASE WHEN DATEDIFF(end_date, start_date)+1 BETWEEN 7 AND 29 
                    THEN '7일 이상'
                WHEN DATEDIFF(end_date, start_date)+1 BETWEEN 30 AND 89 
                    THEN '30일 이상'
                WHEN DATEDIFF(end_date, start_date)+1 >= 90 
                    THEN '90일 이상' END
    WHERE c.car_type = '트럭')

    SELECT history_id,
           ROUND(daily_fee * duration * (1-COALESCE(discount_rate,0)/100),0) AS fee
    FROM final
    ORDER BY fee desc, history_id desc;
~~~

join 조건을 case when then else 구문으로 만드는 방식

