# SQL 레벨업

## 4장  집약과 자르기
### 12강 집약
SQL의 집약함수:
- COUNT
- SUN
- AVG
- MAX
- MIN

#### 1. 여러 개의 레코드를 한 개의 레코드로 집약
비집약테이블 NonAggTbl

| id  | data_type | data_1 | data_2 | data_3 | data_4 | data_5 | data_6 |
|-----|-----------|--------|--------|--------|--------|--------|--------|
| Kim | A         | 100    | 10     | 64     | 134    | 33     |        |
| Kim | B         | 45     | 2      | 44     | 564    | 38     | 181    |
| Kim | C         |        | 3      | 567    | 2234   | 555    | 345    |

구해야 할 것: 한 사람을 한 개의 레코드로 집약하여 테이블 생성  
(A:data_1,2 / B:data_3,4,5 / C:data_6 이용)

##### CASE 식과 GROUP BY 응용
~~~sql
SELECT id,
    CASE WHEN data_type = 'A' THEN data_1 ELSE NULL END AS data_1,
    CASE WHEN data_type = 'A' THEN data_2 ELSE NULL END AS data_2,
    CASE WHEN data_type = 'B' THEN data_3 ELSE NULL END AS data_3,
    CASE WHEN data_type = 'B' THEN data_4 ELSE NULL END AS data_4,
    CASE WHEN data_type = 'B' THEN data_5 ELSE NULL END AS data_5,
    CASE WHEN data_type = 'C' THEN data_6 ELSE NULL END AS data_6
FROM NonAggTbl
GROUP BY id;
~~~  
MySQL이 아닐 경우 해당 쿼리는 문법오류가 발생한다.  
GROUP BY 구로 집약했을때 SELECT 구로 입력할 수 있는 것은 다음과 같은 세가지이다.  
- 상수
- GROUP BY 구에서 사용한 집약 키
- 집약 함수

따라서 귀찮더라도 집약함수를 사용하여 작성해야한다.  
~~~sql
SELECT id,
    MAX(CASE WHEN data_type = 'A' THEN data_1 ELSE NULL END) AS data_1,
    MAX(CASE WHEN data_type = 'A' THEN data_2 ELSE NULL END) AS data_2,
    MAX(CASE WHEN data_type = 'B' THEN data_3 ELSE NULL END) AS data_3,
    MAX(CASE WHEN data_type = 'B' THEN data_4 ELSE NULL END) AS data_4,
    MAX(CASE WHEN data_type = 'B' THEN data_5 ELSE NULL END) AS data_5,
    MAX(CASE WHEN data_type = 'C' THEN data_6 ELSE NULL END) AS data_6
FROM NonAggTbl
GROUP BY id;
~~~  

##### 집약, 해시, 정렬
PostgreSQL과 Oracle의 실행계획을 살펴보면 GROUP BY 집약조작에 모두 해시 알고리즘이 사용되고있다.  
집약할때는 해시를 사용하기도하지만 경우에 따라서 정렬을 사용하기도 한다.  
GROUP BY 구에 지정되어 있는 필드를 해시함수를 사용해 해시키로 변환하고,  
같은 해시 키를 가진 그룹을 모아 집약하는 방법으로서  
GROUP BY의 유일성이 높으면 더 효율적으로 작동한다.

성능 주의점 : 정렬과 해시 모두 메모리를 많이 사용하므로, 워킹 메모리가 확보되지않으면 성능문제가 일어난다.  
따라서 연산 대상 레코드 수가 많은 집약함수를 사용하는 SQL에서는 충분한 성능검증이 필요하다.

#### 2. 합쳐서 하나
연령별 가격 테이블 PriceByAge

| reserve_id | low_age | high_age | price |
|------------|---------|----------|-------|
| product1   | 0       | 50       | 2000  |
| product1   | 51      | 100      | 3000  |
| product2   | 0       | 100      | 4200  |
| product3   | 0       | 20       | 500   |
| product3   | 31      | 70       | 800   |
| product3   | 71      | 100      | 1000  |
| product4   | 0       | 99       | 8900  |

구해야할 것: 해당 테이블에서 0~100세까지 모든 연령이 가지고 놀 수 있는 제품을 구하기

~~~sql
SELECT product_id
FROM PriceByAge
GROUP BY product_id
HAVING SUM(high_age - low_age + 1) = 101;
~~~
HAVING 구를 이용하여 각 레코드의 연령 범위에 있는 정수 개수를 구할 수 있다.


### 13강 자르기
GROUP BY 는 집약외에도 자르기 라는 기능을 한꺼번에 수행한다.  
자르기란 원래 모집합인 테이블을 작은 부분 집합들로 분리하는 것을 말한다.

#### 1. 자르기와 파티션
신체 정보를 저장하는 인물 테이블 Persons

| name   | age | height | weight |
|--------|-----|--------|--------|
| Aria   | 30  | 188    | 90     |
| Adela  | 21  | 167    | 55     |
| Bill   | 56  | 157    | 48     |
| Bake   | 88  | 187    | 70     |
| Becky  | 33  | 177    | 120    |
| Chris  | 77  | 175    | 48     |
| Dawin  | 23  | 160    | 55     |
| Dawson | 46  | 182    | 90     |
| Donald | 45  | 176    | 53     |

구해야 할 것: 이름 첫 글자를 사용해 특정 알파벳으로 시작하는 이름을 가진 사람인지 몇명인지 집계

~~~sql
SELECT SUBSTRING(name, 1, 1) AS label,
    COUNT(*)
FROM Persons
GROUP BY SUBSTRING(name, 1, 1);
~~~

##### 파티션
GROUP BY 구로 잘라 만든 하나하나의 부분집합을 파티션이라고 부른다.

구해야 할 것: 나이를 기준으로 어린이(20세 미만), 성인(20~69), 노인(70세 이상)으로 나누기

~~~sql
SELECT CASE WHEN age < 20 THEN '어린이'
              WHEN age BETWEEN 20 AND 69 THEN '성인'
              WHEN age >= 70 THEN '노인'
              ELSE NULL END AS age_class,
        COUNT(*)
FROM Persons
GROUP BY CASE WHEN age < 20 THEN '어린이'
              WHEN age BETWEEN 20 AND 69 THEN '성인'
              WHEN age >= 70 THEN '노인'
              ELSE NULL END;
~~~

자르기의 기준이 되는 키를 GROUP BY 구와 SELECT 구 모두에 입력하는 것이 포인트이다.  
MySQL과 PostgreSQL 의 경우에는 SELECT 구에 붙인 별칭을 이용하여 `GROUP BY age_class` 처럼 작성가능하다.

#### 2. PARTITION BY 구를 사용한 자르기
GROUP BY 에서 집약 기능을 제외하고 자르는 기능만 남긴 것이 윈도우 함수의 PARTITION BY 구이다.

구해야 할 것: 연령등급(어린이,성인,노인)에서 어린 순서로 순위를 매기기

~~~sql
SELECT name, age,
        CASE WHEN age < 20 THEN '어린이'
             WHEN age BETWEEN 20 AND 69 THEN '성인'
             WHEN age >= 70 THEN '노인'
             ELSE NULL END AS age_class,
        RANK() OVER(PARTITION BY CASE WHEN age < 20 THEN '어린이'
                                     WHEN age BETWEEN 20 AND 69 THEN '성인'
                                     WHEN age >= 70 THEN '노인'
                                     ELSE NULL END
                    ORDER BY age) AS age_rank_in class
FROM Persons
ORDER BY age_class, age_rank_in_class;
~~~

Persons 테이블의 레코드가 모두 원래 형태로 나오는 것에 주목  
PARTITION BY 구는 입력에 정보를 추가할 뿐 원본 테이블 정보를 완전히 그대로 유지한다.

### 마치며
- GROUP BY 구 혹은 윈도우 함수의 PARTITION BY 구는 집합을 자를 때 사용
- GROUP BY 구 또는 윈도우 함수는 내부적으로 해시 또는 정렬처리를 실행
- 해시 또는 정렬은 메모리를 많이 사용해 만약 메모리가 부족하면 일시 영역으로 저장소를 사용해 성능 문제를 일으킴
- GROUP BY 구 또는 윈도우 함수와 CASE 식을 함께 사용하면 굉장히 다양한 것을 표현할 수 있다.
