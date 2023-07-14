# SQL 레벨업

## 5장  반복문 : 절차지향형의 속박
### 14강 반복문 의존증
> 관계조작은 관계 전체를 모두 조작의 대상으로 삼는다. 이러한 것의 목적은 반복을 제외하는것이다. 최종 사용자의 생산성을 생각하면 이러한 조건을 만족해야 한다. 그래야만 응용 프로그래머의 생산성에도 기여할 수 있을 것이다.

### 15강 반복계의 공포
매출계산을 하는 테이블 Sales

| company | year | sale |
|---------|------|------|
| A       | 2002 | 50   |
| A       | 2003 | 52   |
| A       | 2004 | 55   |
| A       | 2007 | 55   |
| B       | 2001 | 27   |
| B       | 2005 | 28   |
| B       | 2006 | 28   |
| B       | 2009 | 30   |
| C       | 2001 | 40   |
| C       | 2005 | 39   |
| C       | 2006 | 38   |
| C       | 2010 | 35   |

Sales2 : Sales테이블을 활용하여 만든 테이블  
- 이전 데이터가 없을 경우 NULL
- 이전 데이터보다 매출이 올랐을 경우 +
- 이전 데이터보다 매출이 내렸을 경우 -
- 이전 데이터와 매출이 동일한 경우 =

| company | year | sale | var |
|---------|------|------|-----|
| A       | 2002 | 50   |     |
| A       | 2003 | 52   | +   |
| A       | 2004 | 55   | +   |
| A       | 2007 | 55   | =   |
| B       | 2001 | 27   |     |
| B       | 2005 | 28   | +   |
| B       | 2006 | 28   | =   |
| B       | 2009 | 30   | +   |
| C       | 2001 | 40   |     |
| C       | 2005 | 39   | -   |
| C       | 2006 | 38   | -   |
| C       | 2010 | 35   | -   |

~~~sql
CREATE OR REPLACE PROCEDURE PROC_INSERT_VAR
IS

/* 커서 선언 */
CURSOR c_sales IS
    SELECT company, year, sale
    FROM Sales
    ORDER BY company, year;

/* 레코드 타입 선언 */
rec_sales c_sales%ROWTYPE;

/* 카운터 */
i_pre_sale INTEGER := 0;
c_company CHAR(1) := '*';
c_var CHAR(1) := '*';

BEGIN

OPEN c_sales;
    LOOP
        /* 레코드를 패치해서 변수에 대입 */
        fetch c_sales into rec_sales;
        /* 레코드가 없다면 반복을 종료 */
        exit when c_sales%notfound;

        IF(c_company = rec_sales.company) THEN
            /* 직전 레코드가 같은 회사의 레코드 일 때 */
            /* 직전 레코드와 매상을 비교 */
            IF (i_pre_sale < rec_sales.sale) THEN
                c_var := '+';
            ELSE IF(i_pre_sale > rec_sales.sale) THEN
                c_var := '-';
            ELSE
                c_var := '=';
            END IF;
        ELSE
            c_var := NULL;
        END IF;

        /* 등록 대상이 테이블에 테이블을 등록 */
        INSERT INTO Sales2 (company, year, sale, var)
            VALUES (rec_sales.company, rec_sales.year, rec_sales.sale, c_var);

        c_company := rec_sales.company;
        i_pre_sale := rec_sales.sale;
    END LOOP;

    CLOSE c_sales;
    commit;
END;
~~~

#### 1. 반복계의 단점
- 성능 -> 처리시간이 처리대상 레코드 수에 대해 선형적으로 증가한다.
- 실행의 오버헤드 -> 오버헤드에서 영향이 큰 SQL 파스(구문 분석)가 SQL을 받을때 마다 실행되어 오버헤드가 높아진다.
- 병렬분산이 힘들다
- 데이터베이스 진화로 인한 혜택을 받을 수 없다. -> 단순한 반복 SQL구문이 아닌 복잡한 SQL 구문을 빠르게 하려는데 중심을 두기때문

#### 2. 반복계를 빠르게 만드는 방법은 없을까?
- 반복계를 포장계로 다시 작성 -> 실상황에서 무리일 가능성이 높음
- 각각 SQL을 빠르게 수정 -> 반복계에서 사용하는 SQL구문은 이미 단순하여 튜닝 가능성이 제한
- 다중화 처리 -> 데이터를 분할할 수 있는 명확한 키가 없거나, 순서가 중요하거나, 병렬화시 물리리소스가 부족하면 사용 불가

#### 3. 반복계의 장점
- 실행계획의 안정성 -> 실행계획이 단순하여 변동위험이 거의 없다.
- 예상 처리시간 정밀도 -> 처리시간 = 한번의 실행시간 * 실행횟수
- 트랜잭션 제어가 편리 -> 트랜잭션 정밀도를 미세하게 제어 가능하다.  
(특정 반복 횟수마다 커밋한다면 중간에 오류가 발생해도 해당지점 근처에서 다시 처리를 실행하면 된다.)


### 16강 SQL에서는 반복을 어떻게 표현할까?
#### 1. 포인트는 CASE 식과 윈도우 함수
윈도우 함수를 사용한 방법

~~~sql
INSERT INTO Sales2
    SELECT company, year, sale,
            CASE SIGN(sale - MAX(sale) OVER (PARTITION BY company
                                                ORDER BY year
                                                ROWS BETWEEN 1 PRECEDING
                                                    AND 1 PRECEDING))
            WHEN 0 THEN '='
            WHEN 1 THEN '+'
            WHEN -1 THEN '-'
            ELSE NULL END AS var
    FROM Sales;
~~~  
- SIGN 함수  
: 숫자 자료형이 음수라면 -1, 양수 1, 0이면 0을 리턴하는 함수로,  
CASE식의 조건부분에서 윈도우 함수를 몇번씩 사용하지 않도록 해주는 기술  
- ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING : 대상 범위의 레코드를 직전의 1개로 제한한다.

#### 2. 최대 반복 횟수가 정해진 경우
우편번호 테이블 PostalCode

| pcode   |
|---------|
| 4130001 |
| 4130002 |
| 4130103 |
| 4130041 |
| 4103213 |
| 4380824 |

구해야할 것: 4130033과 인접한 우편번호 찾기 (가까운 지역일수록 우편번호 숫자가 일치함)

##### 문제의 포인트 : 순위
rank필드를 구하여 MIN함수를 이용해 구할 수 있다.

~~~sql
SELECT pcode FROM PostalCode
    WHERE CASE WHEN pcode = '4130033' THEN 0
               WHEN pcode LIKE '413003%' THEN 1
               WHEN pcode LIKE '41300%' THEN 2
               WHEN pcode LIKE '4130%' THEN 3
               WHEN pcode LIKE '413%' THEN 4
               WHEN pcode LIKE '41%' THEN 5
               WHEN pcode LIKE '4%' THEN 6
               ELSE NULL 
          END =
          (SELECT MIN ( CASE WHEN pcode = '4130033' THEN 0
                            WHEN pcode LIKE '413003%' THEN 1
                            WHEN pcode LIKE '41300%' THEN 2
                            WHEN pcode LIKE '4130%' THEN 3
                            WHEN pcode LIKE '413%' THEN 4
                            WHEN pcode LIKE '41%' THEN 5
                            WHEN pcode LIKE '4%' THEN 6
                            ELSE NULL 
                        END )
            FROM PostalCode);
~~~

실행계획을 살펴보면 테이블 접근이 2회 발생한다.(but 인덱스 온리 스캔을 지원하는 DBMS에서는 인덱스를 사용한 접근만 실행 할 수 있다.)  
레코드 수가 늘어날 경우를 생각해보면 스캔 횟수를 줄일 수 있는 방법을 생각해야한다.

##### 윈도우 함수를 사용한 스캔 횟수 감소
순위의 최솟값을 서브쿼리에서 찾기때문에 테이블 스캔이 2번 일어나므로 윈도우 함수를 사용하여 스캔횟수를 줄일 수 있다.

~~~sql
SELECT pcode
FROM (SELECT pcode,
            CASE WHEN pcode = '4130033' THEN 0
                WHEN pcode LIKE '413003%' THEN 1
                WHEN pcode LIKE '41300%' THEN 2
                WHEN pcode LIKE '4130%' THEN 3
                WHEN pcode LIKE '413%' THEN 4
                WHEN pcode LIKE '41%' THEN 5
                WHEN pcode LIKE '4%' THEN 6
                ELSE NULL 
            END AS hit_code,
            MIN(CASE WHEN pcode = '4130033' THEN 0
                    WHEN pcode LIKE '413003%' THEN 1
                    WHEN pcode LIKE '41300%' THEN 2
                    WHEN pcode LIKE '4130%' THEN 3
                    WHEN pcode LIKE '413%' THEN 4
                    WHEN pcode LIKE '41%' THEN 5
                    WHEN pcode LIKE '4%' THEN 6
                    ELSE NULL 
                END)
            OVER(ORDER BY CASE WHEN pcode = '4130033' THEN 0
                                WHEN pcode LIKE '413003%' THEN 1
                                WHEN pcode LIKE '41300%' THEN 2
                                WHEN pcode LIKE '4130%' THEN 3
                                WHEN pcode LIKE '413%' THEN 4
                                WHEN pcode LIKE '41%' THEN 5
                                WHEN pcode LIKE '4%' THEN 6
                                ELSE NULL 
                            END) AS min_code
     FROM PostalCode) Foo
WHERE hit_code = min_code;
~~~

#### 3. 반복 횟수가 정해지지 않은 경우
##### 인접 리스트 모델과 재귀쿼리
우편번호 이력 테이블 PostalHistory

| name | pcode   | new_pcode |
|------|---------|-----------|
| A    | 4130001 | 4130002   |
| A    | 4130002 | 4130003   |
| A    | 4130103 |           |
| B    | 4130041 |           |
| C    | 4103213 | 4380824   |
| C    | 4380824 |           |

우편번호를 키로 삼아 데이터를 줄줄이 연결하는 포인터 체인 방식의 인접리스트 모델 테이블이다.

SQL에서 계층 구조를 찾는 방법중 하나는 재귀공통테이블식을 사용하는 방식이다.  
~~~sql
WITH Explosion (name, pcode, new_pcode, depth)
AS
(SELECT name, pcode, new_pcode, 1
    FROM PostalHistory
    WHERE name = 'A'
        AND new_pcode IS NULL -- 검색 시작
UNION ALL
SELECT Child.name, Child.pcode, Child.new_pcode, depth + 1
    FROM Explosion Parent, PostalHistory Child
    WHERE Parent.pcode = Child.new_pcode
        AND Parent.name = Child.name)

-- 메인 SELECT 구문
SELECT name,pcode,new_pcode
    FROM Explosion
    WHERE depth = (SELECT MAX(depth) FROM Explosion);
~~~

### 마치며
- SQL은 의도적으로 반복문을 설계에서 제외했다.
- 반복계는 성능적으로 큰 결점을 가지고 있지만, 몇가지 장점도 있다.
- 반복계는 성능 튜닝 가능성이 거의 없으므로 사용할 때 주의가 필요
- 트레이드오프를 고려하여 반복계와 포장계 중 어떤것을 채용할지 판단 필요

### 연습문제
16강 윈도우 함수를 사용한 방법 코드를 상관서브쿼리로 만들기

- 상관서브쿼리 : 서브쿼리 내부에서 외부쿼리와의 결합조건을 사용하고, 해당 결합키로 잘라진 부분집합을 조작하는 기술로  
PARTITION BY 구와 ORDER BY 구와 같은 기능을 가진다.

~~~sql
INSERT INTO Sales2
    SELECT company, year, sale,
    CASE SIGN(sale - (SELECT sale -- 직전 연도의 매상 선택
                        FROM Sales S2
                        WHERE S1.company = S2.company
                            AND S2.year = (SELECT MAX(year) -- 직전 연도 선택
                                            FROM Sales S3
                                            WHERE S1.company = S3.company
                                                AND S1.year > S3.year)))
    WHEN 0 THEN '='
    WHEN 1 THEN '+'
    WHEN -1 THEN '-'
    ELSE NULL END AS var
    FROM Sales S1;
~~~

사실 상관 서브쿼리는 윈도우 함수를 사용한 방법에 비해 가독성도 나쁘고,  
실행계획의 안정성도 낮으며 성능도 좋지않기때문에  
윈도우 함수를 사용할수있는 환경에서 상관서브쿼리를 사용하는 장점은 전혀 없다.