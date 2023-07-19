# SQL 레벨업

## 3장  SQL의 조건 분기
### 8강 UNION을 사용한 쓸데 없이 긴 표현
UNION을 사용하면 테이블에 접근하는 횟수가 많아져서 I/O비용이 크게 늘어난다.  
따라서 SQL에서 조건 분기를 할 때 UNION을 사용해도 좋을지 여부는 신중히 검토해야 한다.
#### 1. UNION을 사용한 조건분기와 관련된 간단한 예제
상품테이블 Items

| itme_id | year | item_name | price_tax_ex | price_tax_in |
|---------|------|-----------|--------------|--------------|
| 100     | 2000 | cup       | 500          | 525          |
| 100     | 2001 | cup       | 520          | 546          |
| 100     | 2002 | cup       | 600          | 630          |
| 100     | 2003 | cup       | 600          | 630          |
| 101     | 2000 | spoon     | 500          | 525          |
| 101     | 2001 | spoon     | 500          | 525          |
| 101     | 2002 | spoon     | 500          | 525          |
| 101     | 2003 | spoon     | 500          | 525          |

구해야 할 것: 2002년 이전의 가격은 세전으로, 이후의 가격은 세후로 표시하여 테이블 추출

이 경우 UNION을 사용한 조건분기를 사용하면 쓸데없이 긹고 읽기 힘든 쿼리가 되고, 성능에 문제가 생긴다.  
실행계획을 살펴보면 테이블에 2회 접근하게되어 성능을 나쁘게 만든다.
#### 2. WHERE 구에서 조건분기를 하는 사람은 초보자
> 조건분기를 WHERE 구로 하는 사람들은 초보자다. 잘 하는 사람은 SELECT 구만으로 조건 분기를한다.

~~~sql
SELECT item_name, year,
    CASE WHEN year <= 2001 THEN price_tax_ex
         WHEN year >= 2002 THEN price_tax_in END AS price
FROM Items;
~~~

#### 3. SELECT 구를 사용한 조건 분기의 실행 계획
테이블에 대한 접근이 1회로 줄어든것을 확인 가능하다.

### 9강 집계와 조건 분기
인구 테이블 Population

| prefecture | sex | pop |
|------------|-----|-----|
| seoul      | 1   | 60  |
| seoul      | 2   | 40  |
| dajeon     | 1   | 90  |
| dajeon     | 2   | 100 |
| busan      | 1   | 50  |
| busan      | 2   | 70  |
| suwon      | 1   | 80  |
| suwon      | 2   | 60  |
| incheon    | 1   | 100 |
| incheon    | 2   | 70  |

위의 테이블을 아래와 같은 형식으로 바꿔보도록 한다.  
| prefecture | pop_men | pop_wom |
|------------|---------|---------|
| seoul      | 60      | 40      |

#### 1. 집계 대상으로 조건 분기
UNION을 사용할 경우 테이블 풀 스캔이 2회 수행된다 -> 비효율적  
(사실 sex필드에 인덱스가 존재할 경우 CASE식으로 수행되는 테이블 풀 스캔 1회 보다  
UNION 식으로 수행되는 인덱스 스캔 2회가 더 빠르게 작동할 수도 있다.)

집계의 조건 분기도 CASE식을 사용하면 쿼리가 굉장히 간단해진다.  
~~~sql
SELECT prefecture,
        SUM(CASE WHEN sex = 1 THEN pop ELSE 0 END) AS pop_men,
        SUM(CASE WHEN sex = 2 THEN pop ELSE 0 END) AS pop_wom
    FROM Population
GROUP BY prefecture;
~~~

실행계획을 살펴보면 테이블 풀 스캔이 1회로 감소한 것을 확인 할 수 있다.

#### 2. 집약 결과로 조건 분기
직원 테이블 Employees

| emp_id | team_id | emp_name | team   |
|--------|---------|----------|--------|
| 1      | 1       | A        | front  |
| 1      | 2       | A        | back   |
| 1      | 3       | A        | design |
| 2      | 4       | B        | sales  |
| 3      | 2       | C        | back   |
| 4      | 1       | D        | front  |
| 4      | 2       | D        | back   |
| 4      | 3       | D        | design |
| 4      | 4       | D        | sales  |
| 5      | 3       | E        | design |
| 5      | 1       | E        | front  |

구해야 할 것: 소속된 팀이 1개라면 해당 직원은 팀 이름 그대로 출력  
소속된 팀이 2개라면 해당 직원은 2개를 겸무 라는 문자열 출력  
소속된 팀이 3개 이상이라면 해당직원은 3개 이상을 겸무라는 문자열을 표시하여 테이블 추출

최적의 방법은 SELECT 구문과 CASE 식을 사용하는 것이다.  
~~~sql
SELECT emp_name
    CASE WHEN COUNT(*) = 1 THEN MAX(team)
         WHEN COUNT(*) = 2 THEN '2개를 겸무'
         WHEN COUNT(*) >= 3 THEN '3개 이상을 겸무'
    END AS team
FROM Employees
GROUP BY emp_name;
~~~

### 10강 그래도 UNION이 필요한 경우
#### 1. UNION을 사용할 수 밖에 없는 경우
여러개의 테이블에서 검색한 결과를 머지하는 경우  
(FROM구에서 테이블을 결합하면 CASE를 사용할 수도 있지만 필요없는 결합이 발생해 성능적으로 악형향 발생)  

#### 2. UNION을 사용하는 것이 성능적으로 더 좋은 경우
UNION을 사용했을때 좋은 인덱스를 사용하지만, 이외의 경우에는 테이블 풀 스캔이 발생한다면  
UNION을 사용한 방법이 성능적으로 더 좋을 수 있다.

ThreeElements 테이블

| key | name | date_1     | flg_1 | date_2     | flg_2 | date_3     | flg_3 |
|-----|------|------------|-------|------------|-------|------------|-------|
| 1   | a    | 2023-07-01 | T     |            |       |            |       |
| 2   | b    |            |       | 2023-07-01 | T     |            |       |
| 3   | c    |            |       | 2023-07-01 | F     |            |       |
| 4   | d    |            |       | 2023-09-10 | T     |            |       |
| 5   | e    |            |       |            |       | 2023-07-01 | T     |
| 6   | f    |            |       |            |       | 2023-12-02 | F     |

해당 인덱스를 추가하여 UNION을 사용하면 테이블 풀 스캔보다도 빠른 접근 속도를 기대할 수 있다.  
~~~sql
CREATE INDEX IDX_1 ON ThreeElements (date_1,flg_1);
CREATE INDEX IDX_1 ON ThreeElements (date_2,flg_2);
CREATE INDEX IDX_1 ON ThreeElements (date_3,flg_3);
~~~

OR을 사용한 방법을 사용하면 다음과 같다.  
~~~sql
SELECT key, name
    date_1, flg_1,
    date_2, flg_2,
    date_3, flg_3,
FROM ThreeElements
WHERE (date_1='2023-07-01' AND flg_1 = 'T')
    OR (date_2='2023-07-01' AND flg_2 = 'T')
    OR (date_3='2023-07-01' AND flg_3 = 'T');
~~~
WHERE 구문에서 OR을 사용하면 해당 필드에 부여된 인덱스를 사용할 수 없다.  
따라서 이 경우 UNION과 OR의 성능비교는 3회 인덱스 스캔 VS 1회 테이블 풀 스캔  
이럴 경우 테이블이 크고, WHERE 조건으로 선택되는 레코드 수가 충분히 작다면 UNION이 더 빠르다.

* 참고
OR 쿼리를 IN 쿼리로 변환  
~~~sql
SELECT key, name
    date_1, flg_1,
    date_2, flg_2,
    date_3, flg_3,
FROM ThreeElements
WHERE ('2023-07-01', 'T')
    IN ((date_1, flg_1),
        (date_2, flg_2),
        (date_3, flg_3));
~~~

### 마치며
- SQL의 성능은 저장소의 I/O를 얼마나 감소시킬 수 있을지가 열쇠
- UNION 에서 조건분기를 표현한다면 내가 지금 쓸데없이 길게 쓰고 있는 것은 아닐까 항상의식하기
- IN 또는 CASE 식으로 조건 분기를 표한 할 수 있다면 테이블 스캔을 크게 감소시킬 가능성이 있다.
