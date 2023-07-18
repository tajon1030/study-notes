# SQL 레벨업

## 9장 갱신과 데이터 모델
### 26강 갱신은 효율적으로
#### 1. NULL 채우기
keycol + seq로 유일함을 나타내는 테이블 OmitTbl

| keycol | seq | val |
|--------|-----|-----|
| A      | 1   | 50  |
| A      | 2   |     |
| A      | 3   |     |
| A      | 4   | 70  |
| A      | 5   |     |
| A      | 6   | 900 |
| B      | 1   | 10  |
| B      | 2   | 20  |
| B      | 3   |     |
| B      | 4   | 3   |
| B      | 5   |     |
| B      | 6   |     |

비어있는 부분은 본래 값은 있지만 이전 레코드와 같은 값을 가지므로 생략

만약 비어있는 부분에 값을 채워넣어야할 경우 UPDATE구문을 어떻게 생성해야 할까  
문제는 갱신대상이 되는 레코드에 val 필드를 계산해서 넣을 방법  
-> 반복계를 사용한 접근법은 좋지 않은 방법  
-> 상관 서브쿼리를 사용한 접근법  
~~~sql
UPDATE OmitTbl
SET val = (SELECT val
                FROM OmitTbl OT1
                WHERE OT1.keycol = OmitTbl.keycol -- 같은 keycol을 가짐
                        AND OT1.seq = (SELECT MAX(seq)
                                        FROM OmitTbl OT2
                                        WHERE OT2.keycol = OmitTbl.keycol
                                                AND OT2.seq < OmitTbl.seq -- 자신보다 작은 seq를 가짐
                                                AND OT2.val IS NOT NULL)) -- val이 NULL 이 아님
WHERE val IS NULL;
~~~

#### 2. 반대로 NULL을 작성
채우기 이후의 OmitTbl을 채우기 이전으로 변환할때에도 비슷한 방식을 사용한다.  
~~~sql
UPDATE OmitTbl
SET val = CASE WHEN val 
                = (SELECT val
                        FROM OmitTbl OT1
                        WHERE OT1.keycol = OmitTbl.keycol
                                AND OT1.seq 
                                        = (SELECT MAX(seq)
                                                FROM OmitTbl OT2
                                                WHERE OT2.keycol = OmitTbl.keycol
                                                AND OT2.seq < OmitTbl.seq))
        THEN NULL
        ELSE val END;
~~~

### 27강 레코드에서 필드로의 갱신
점수를 레코드로 갖는 테이블 ScoreRows

| student_id | subject | score |
|------------|---------|-------|
| A001       | eng     | 100   |
| A001       | kor     | 58    |
| A001       | math    | 90    |
| BB002      | eng     | 77    |
| B002       | kor     | 60    |
| C001       | eng     | 52    |
| C003       | kor     | 49    |
| C003       | science | 100   |


점수를 필드로 갖는 테이블 ScoreCols

| student_id | score_en | score_ko | score_mt |
|------------|----------|----------|----------|
| A001       |          |          |          |
| B002       |          |          |          |
| C003       |          |          |          |
| D004       |          |          |          |

#### 1. 필드를 하나씩 갱신
한 과목식 갱신하는 SQL은 간단하고 명확하지만 3개의 상관 서브쿼리를 실행해야하기때문에 성능적으로 좋지않다.  

#### 2. 다중 필드 할당
~~~sql
UPDATE ScoreCols
SET (score_en, score_ko, score_mt)
        = (SELECT MAX(CASE WHEN subject = 'eng'
                        THEN score
                        ELSE NULL END) AS score_en,
                MAX(CASE WHEN subject = 'ko'
                        THEN score
                        ELSE NULL END) AS score_ko,
                MAX(CASE WHEN subject = 'math'
                        THEN score
                        ELSE NULL END) AS score_mt
                FROM ScoreRows SR
                WHERE SR.student_id = ScoreCols.student_id);
~~~

- 다중 필드 할당: 세개의 필드를 (score_en, score_ko, score_mt)와 같은 리스트 형식으로 지정했다.  
이렇게 하면 리스트 전체를 하나의 조작 단위로 만들 수 있다.  
- 스칼라 서브쿼리 : 각각의 점수에 MAX함수를 적용시켰는데, 이렇게 하지않으면 서브쿼리로 여러개의 레코드가 리턴된다.  
예를 들어 A001의 score_en 필드의 경우 MAX함수를 사용하지않으면(100,NULL,NULL)처럼 3개의 값이 리턴된다.

#### 3. NOT NULL 제약이 걸려있는 경우
점수를 필드로 가지는 테이블 ScoreColsNN (NOT NULL 제약 추가)

| student_id | score_en | score_ko | score_mt |
|------------|----------|----------|----------|
| A001       | 0        | 0        | 0        |
| B002       | 0        | 0        | 0        |
| C003       | 0        | 0        | 0        |
| D004       | 0        | 0        | 0        |

앞에서 작성했던 코드를 이용하면 NULL이 들어갈수없기때문에 오류가 발생하여 수정해줘야한다.  
~~~sql
UPDATE ScoreCols
SET (score_en, score_ko, score_mt)
        = (SELECT COALESCE(MAX(CASE WHEN subject = 'eng' -- 학생은 있지만 과목이 없을때의 null 대응
                        THEN score
                        ELSE NULL END), 0) AS score_en,
                COALESCE(MAX(CASE WHEN subject = 'ko'
                        THEN score
                        ELSE NULL END), 0) AS score_ko,
                COALESCE(MAX(CASE WHEN subject = 'math'
                        THEN score
                        ELSE NULL END), 0) AS score_mt
                FROM ScoreRows SR
                WHERE SR.student_id = ScoreCols.student_id)
WHERE EXISTS (SELECT * -- 처음부터 학생이 존재하지 않는 때의 null 대응
                FROM ScoreRows
                WHERE student_id = ScoreColsNN.student_id);
~~~  
두단계에 걸쳐 NULL을 대응하는데,  
첫번째는 학생 D004에 해당하는 처음부터 테이블 사이에 일치하지 않는 레코드가 존재한 경우로,  
처음부터 갱신대상에서 제외한다.  
두번째는 학생은 존재하지만 과목이 없는 경우로 COALESCE함수를 이용하여 NULL을 0으로 변경해서 대응  

MERGE 구문이 있는 DBMS의 경우 MERGE구문을 활용할 수 있다.  
~~~sql
MERGE INTO ScoreColsNN
USING (SELECT student_id,
                COALESCE(MAX(CASE WHEN subject = 'eng'
                                THEN score
                                ELSE NULL END), 0) AS score_en,
                COALESCE(MAX(CASE WHEN subject = 'ko'
                                THEN score
                                ELSE NULL END), 0) AS score_ko,
                COALESCE(MAX(CASE WHEN subject = 'mt'
                                THEN score
                                ELSE NULL END), 0) AS score_mt
        FROM ScoreRows
        GROUP BY student_id) SR
ON (ScoreColsNN.student_id = SR.student_id)
WHEN MATCHED THEN
        UPDATE SET ScoreColsNN.score_en = SR.score_en,
                ScoreColsNN.score_ko = SR.score_ko,
                ScoreColsNN.score_mt = SR.score_mt;
~~~

### 28강 필드에서 레코드로 변경
점수를 필드로 갖는 테이블ScoreCols -> 점수를 레코드로 갖는 테이블Score Rows

~~~sql
UPDATE ScoreRows
SET score = (SELECT CASE ScoreRows.subject
                        WHEN 'en' THEN score_en
                        WHEN 'ko' THEN score_ko
                        WHEN 'math' THEN score_mt
                        ELSE NULL END
                FROM ScoreCols
                WHERE student_id = ScoreRows.student_id);
~~~

### 29강 같은 테이블의 다른 레코드로 갱신
참조 대상 주가 테이블 Stocks(trend필드를 연산해서 insert)

| brand | sale_date  | price |
|-------|------------|-------|
| A     | 2008-07-01 | 1000  |
| A     | 2008-07-04 | 1200  |
| A     | 2008-08-12 | 800   |
| B     | 2008-06-04 | 3000  |
| B     | 2008-09-11 | 3000  |
| C     | 2008-07-01 | 9000  |
| D     | 2008-06-04 | 5000  |
| D     | 2008-06-05 | 5000  |
| D     | 2008-06-06 | 4800  |
| D     | 2008-12-01 | 5100  |

갱신 대상 주가 테이블 Stocks2

| brand | sale_date | price | trend |
|-------|-----------|-------|-------|

trend는 이전 종가와 비교해서 올랐다면 u, 내렸다면 d, 그대로라면 k라는 값을 지정한다.  
처음으로 거래한 날은 NULL이다.

#### 1. 상관 서브쿼리 사용
상관 서브쿼리를 사용하여 INSERT SELECT구문을 사용하면 쉽게 추가할 수 있다.
다만 Stocks테이블에 수차례에 걸친 접근이 발생한다.
~~~sql
INSERT INTO Stocks2
SELECT brand, sale_date, price,
        CASE SIGN(price - 
                        (SELECT price
                                FROM Stocks S1
                                WHERE brand = Stocks.brand
                                        AND slale_date = (SELECT MAX(sale_date)
                                                                FROM Stocks S2
                                                                WHERE brand = Stocks.brand
                                                                AND sale_date < Stocks.sale_date)))
        WHEN -1 THEN 'd'
        WHEN 0 THEN 'k'
        WHEN 1 THEN 'u'
        ELSE NULL END
FROM Stocks;
~~~

#### 2. 윈도우 함수 사용
따라서 윈도우 함수를 통해 코드를 개선 가능하다.  
~~~sql
INSERT INTO Stocks2
SELECT brand, sale_date, price,
        CASE SIGN(price - 
                MAX(price) OVER(PARTITION BY brand
                                ORDER BY sale_date
                                ROWS BETWEEN 1 PRECEDING
                                        AND 1 PRECEDING))
        WHEN -1 THEN 'd'
        WHEN 0 THEN 'k'
        WHEN 1 THEN 'u'
        ELSE NULL END
FROM Stocks;
~~~

#### 3. insert와 update 어떤 것이 좋을까?
INSERT SELECT 에는 두가지 장점이 있다. 일반적으로 update에 비해 고속 처리를 기대할 수 있다는 점과,  
mysql 처럼 갱신 sql에서의 자기참조를 허가하지않는 데이터베이스에서도 사용할수있다.  

반면 insert를 사용하면 같은 크기와 구조를 가진 데이터를 두개 만들어야한다는 것이 단점이다.  
따라서 저장소 용량을 2배 이상 소비한다.

Stocks2테이블을 뷰로 만드는 방법을 떠올릴수도 있다.  
이는 insert와 update에서는 얻을 수 없는 장점인,  
저장소 용량을 절약함은 물론, 정보를 항상 최신으로 유지할수있다는 장점이 있다.  
그러나 Stocks2뷰에 접근할때마다 복잡한 연산이 수행되므로 접근 쿼리 성능이 낮아진다.

### 30강 갱신이 초래하는 트레이드 오프
주문 테이블 Orders

| order_id | order_shop | order_name | order_date |
|----------|------------|------------|------------|
| 1        | seoul      | a          | 2011/08/22 |
| 2        | incheon    | b          | 2011/09/01 |
| 3        | incheon    | c          | 2011/09/20 |
| 4        | busan      | d          | 2011/08/05 |
| 5        | dajeon     | e          | 2011/08/22 |
| 6        | suwon      | f          | 2011/08/29 |

주문명세 테이블 OrderReceipts

| order_id | order_receipt_id | item_group | delivery_date |
|----------|------------------|------------|---------------|
| 1        | 1                | a          | 2011/08/24    |
| 1        | 2                | b          | 2011/08/25    |
| 1        | 3                | c          | 2011/08/26    |
| 2        | 1                | d          | 2011/09/04    |
| 3        | 1                | b          | 2011/09/22    |
| ...      | ...              | ...        | ...           |

주문마다 주문일과 상품의 배송예정일의 차이를 구해 3일 이상이라면 배송이 늦어지고있음을 알리고 싶다.

#### 1. SQL을 사용하는 방법
diff_days필드를 구해서 날짜 차이를 구할 수 있다.  
~~~sql
SELECT O.order_id, O.order_name,
        ORC.delivery_date - O.order_date AS diff_Date
FROM Orders O
        INNER JOIN OrderReceipts ORC
                ON O.order_id = ORC.order_id
WHERE ORC.delivery_date - O.order_date >= 3;
~~~

주문번호를 집약하여 최대 지연일을 구할 수도 있다.  
~~~sql
SELECT O.order_id,
        MAX(O.order_name),
        MAX(ORC.delivery_date - O.order_date) AS max_diff_days
FROM Orders O
        INNER JOIN OrderReceipts ORC
                ON O.order_id = ORC.order_id
WHERE ORC.delivery_date - O.order_date >= 3
GROUP BY O.order_id;
~~~

여기서 O.order_name에 MAX함수를 적용한것은 SELECT 구문에 order_name 필드를 GROUP BY 구때문에 그냥은 입력할 수 없기 때문이다.  
덧붙여, order_id와 order_name필드가 1:1 대응한다는 전제가 성립한다면 GROUP BY 구에 order_name필드를 포함하여 작성할 수 있고,  
그렇게 한다면 MAX함수를 order_name필드에 적용하지 않을 수 있다.

#### 2. 모델 갱신을 사용하는 방법
배송이 늦어질 가능성이 있는 주문의 레코드에 대해 플래그 필드를 Orders테이블에 추가하면  
해당 플래그만을 조건으로 삼아 지연 여부를 확인할 수 있다.

### 31강 모델 갱신의 주의점
복잡한 쿼리때문에 머리를 싸매지 않아도 된다는 점에서 모델 갱신은 좋은 해결책이다.  
그러나, 여기서도 세가지 트레이드오프가 존재한다.

#### 1. 높아지는 갱신 비용
검색부하를 갱신부하로 미루는 꼴이다.

#### 2. 갱신까지의 시간랙(Time Rag) 발생
데이터의 실시간성이라는 문제가 발생한다.

#### 3. 모델 갱신비용 발생
RDB데이터 모델 갱신은 코드 기반의 수정에 비해 대대적 수정이 요구된다.

### 32강 시야 협착 : 관련문제
이전 내용과 유사한 내용들이므로 생략

### 33강 데이터 모델을 지배하는 자가 시스템을 지배한다.
데이터 모델 설계가 잘못되었다면 만회하기가 어렵기때문에 테이블 설계는 처음이 중요하다.

### 마치며
- SQL을 효율적으로 갱신하려면 다중 필드 할당, 서브쿼리, CASE 식, MERGE 구문 등을 다양하게 활용
- 모든 문제를 반드시 코딩으로 해결할 필요는 없음
- 문제 해결 과정에서 모델을 변경하는 편이 손쉬운 경우도 있지만, 이후 그러한 모델을 다시 바꾸려면 힘듦