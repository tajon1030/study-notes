# SQL 레벨업

## 8장 SQL의 순서
### 23강 레코드에 순번 붙이기
순서 조작의 기초: 레코드에 순번을 붙이는 방법

#### 1. 기본키가 한 개의 필드일 경우
체중 테이블 Weights

| student_id | weight |
|------------|--------|
| A100       | 50     |
| A101       | 55     |
| A124       | 55     |
| B343       | 60     |
| B346       | 72     |
| C563       | 72     |
| C345       | 72     |

윈도우 함수를 이용하여 순번을 붙이면 다음과 같다.  
~~~sql
SELECT student_id,
        ROW_NUMBER OVER(ORDER BY student_id) AS seq
FROM Weights;
~~~

상관 서브쿼리를 이용하면 다음과 같다.  
~~~sql
SELECT student_id,
        (SELECT COUNT(*)
          FROM Weights W2
          WHERE W2.student_id <= W1.student_id) AS seq
FROM Weights W1;
~~~

성능 측면에서 윈도우 함수를 이용하는 편이 좋다.  
윈도우 함수에서는 스캔 횟수가 1회이고 인덱스 온리 스캔을 사용하지만  
상관서브쿼리를 사용하면 2회의 스캔이 실행된다.

#### 2. 기본키가 여러개의 필드로 구성되는 경우
체중 테이블2 Weights2

| class | student_id | weight |
|-------|------------|--------|
| 1     | 100        | 50     |
| 1     | 101        | 55     |
| 1     | 102        | 55     |
| 2     | 100        | 60     |
| 2     | 101        | 72     |
| 2     | 102        | 72     |
| 2     | 103        | 72     |

윈도우 함수를 사용하여 순번을 할당하면 다음과 같다.  
ORDER BY 키에 필드를 추가하기만 하면 된다.  
~~~sql
SELECT class, 
       student_id, 
       ROW_NUMBER() OVER(ORDER BY class, student_id) AS seq 
FROM Weights2;
~~~

상관 서브쿼리를 사용하는 경우에는 다중 필드 비교를 사용하면 된다.  
~~~sql
SELECT calss,
        student_id,
        (SELECT COUNT(*)
          FROM Weights2 W2
          WHERE (W2.class, W2.student_id) <= (W1.class, W1.student_id)) AS seq
FROM Weights2 W1;
~~~
해당 방법의 장점은 필드 자료형을 원하는 대로 지정할 수 있다는 것이다.

#### 3. 그룹마다 순번을 붙이는 경우
학급마다 순번을 붙여 표현하기위해 윈도우 함수를 사용하면 다음과 같다.  
~~~sql
SELECT class, student_id, 
      ROW_NUMBER() OVER(PARTITION BY class ORDER BY student_id) AS seq
FROM Weights2;
~~~

상관 서브쿼리를 사용하는것도 비슷하다.  
~~~sql
SELECT calss,
        student_id,
        (SELECT COUNT(*)
          FROM Weights2 W2
          WHERE W2.class = W1.class
          AND W2.student_id <= W1.student_id) AS seq
FROM Weights2 W1;
~~~

#### 4. 순번과 갱신
체중테이블3 Weights3

| class | student_id | weight | seq |
|-------|------------|--------|-----|
| 1     | 100        | 50     |     |
| 1     | 101        | 55     |     |
| 1     | 102        | 55     |     |
| 2     | 100        | 60     |     |
| 2     | 101        | 72     |     |
| 2     | 102        | 72     |     |
| 2     | 103        | 72     |     |

seq를 갱신하는 UPDATE문을 만들때 윈도우 함수를 사용하면 다음과 같다.
~~~sql
UPDATE Weights3
SET seq = (SELECT seq
            FROM (SELECT class, student_id, 
                          ROW_NUMBER() OVER(PARTITION BY class ORDER BY student_id) AS seq
                  FROM Weights3) SeqTbl
            WHERE Weights3.class = SeqTbl.class
                  AND Weights3.student_id = SeqTbl.student_id);
~~~

상관 서브쿼리를 사용하는 경우에는 그냥 넣어주면 된다.(mysql에서는 자기참조 주의)  
~~~sql
UPDATE Weights3
SET seq = (SELECT COUNT(*)
          FROM Weights3 W2
          WHERE W2.class = Weights3.class
          AND W2.student_id <= Weights3.student_id);
~~~
### 24강 레코드에 순번 붙이기 응용
#### 1. 중앙값 구하기
중앙값을 구하기 위해 집합지향적 발상에 기반한 GROUP BY 와 HAVING을 이용하여 sql을 만들면 코드가 복잡하고 성능이 나쁘다.  
따라서 윈도우 함수를 이용하여 자연수의 특징을 활용하면 양쪽 끝에서부터 숫자세기를 할 수 있다.  
~~~sql
-- 양쪽끝에서 레코드 하나씩 세어 중간을 찾는 방식
SELECT AVG(weight) AS median
FROM (SELECT weight,
              ROW_NUMBER() OVER (ORDER BY weight ASC, student_id ASC) AS hi,
              ROW_NUMBER() OVER (ORDER BY weight DESC, student_id DESC) AS lo
      FROM Weights) TMP
WHERE hi IN (lo, lo+1, lo-1);
~~~

주의할점으로 첫번째는 순번을 붙일때 반드시 ROW_NUMBER함수를 사용해야 한다는 것(RANK, DENSE_RANK는 연속성과 유일성을 위반)  
두번째는 ORDER BY 정렬키에 student_id 도 포함해야한다는 것

위의 코드를 성능 개선하면 다음과 같다.  
~~~sql
SELECT AVG(weight)
FROM (SELECT weight,
              2 * ROW_NUMBER() OVER(ORDER BY weight) - COUNT(*) OVER() AS diff
      FROM Weights) TMP
WHERE diff BETWEEN 0 AND 2;
~~~  
ROW_NUMBER함수로 구한 순번을 2배해서 DIFF를 구하고, 거기에서 COUNT(*)을 빼는 것  
| weight | ROW_NUMBER() | 2*ROW_NUMBER() | COUNT(*) | diff |
|--------|--------------|----------------|----------|------|
| 50     | 1            | 2              | 7        | -5   |
| 55     | 2            | 4              | 7        | -3   |
| 55     | 3            | 6              | 7        | -1   |
| 60     | 4            | 8              | 7        | 1    |
| 72     | 5            | 10             | 7        | 3    |
| 72     | 6            | 12             | 7        | 5    |
| 72     | 7            | 14             | 7        | 7    |

정렬을 한번만 사용하므로 성능이 좋다.

#### 2. 순번을 사용한 테이블 분할
순번 테이블 Numbers

| num |
|-----|
| 1   |
| 3   |
| 4   |
| 7   |
| 8   |
| 9   |
| 12  |

구해야할 것: 단절구간 찾기

집합 지향적 방법으로 생성하면 다음과 같다.  
~~~sql
SELECT (N1.num + 1) AS gap_start,
        (MIN(N2.num) -1) AS gap_end
FROM Numbers N1 INNER JOIN Numbers N2
  ON N2.num > N1.num
GROUP BY N1.num
HAVING (N1.num + 1) < MIN(N2.num);
~~~

하지만 해당 방식은 조인을 활용하여 비용이 높고 실행계획 변동위험이 있다.  
따라서 절차지향적 방식으로 쿼리를 작성하면 다음과 같고, 성능이 굉장히 안정적이게 된다.
~~~sql
SELECT num+1 AS gap_start, (num_diff-1) AS gap_end
FROM ( SELECT num,
              MAX(num) OVER(ORDER BY num ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING) - num
       FROM Numbers) TMP(num,diff)
WHERE diff <>> 1;
~~~

#### 3. 테이블에 존재하는 시퀀스 구하기

### 25강 시퀀스객체, IDENTITY 필드, 채번 테이블
표준 SQL에서 순번을 다루는 기능으로 시퀀셜 객체와 IDENTITY 필드가 존재한다.  
이 책에서는 이 둘의 사용을 모두 최대한 사용하지 않는것으로 입장을 드러낸다.  
설령 사용할 수 밖에 없는 경우라도 꼭 필요한 부분에만 사용하길 바라고,  
IDENTITY 필드보다 시퀀스 객체의 사용을 권한다.  

#### 1. 시퀀스 객체
시퀀스 객체를 정의하는 예는 다음과 같다.  
~~~sql
CREATE SEQUENCE testseq
START WITH 1  -- START: 초기값
INCREMENT BY 1 -- INCREMENT 증가값
MAXVALUE 10000 -- MAXVALUE 최댓값
MINVALUE 1 -- MINVALUE 최솟값
CYCLE; -- CYCLE 최댓값에 도달하였을때 순환 여부
~~~

해당 기능이 가장 자주 사용되는 장소는 INSERT구문 내부로,  
시퀀스 객체로 만들어진 순번을 기본키로 사용해 레코드를 INSERT 한다.

~~~sql
INSERT INTO HogeTbl VALUES(NEXT VALUE FOR nextval, 'a', 'b', ...);
~~~

시퀀스 객체의 문제점은 다음과 같이 세가지로 정리될 수 있다.  
- 1. 표준화가 늦어서 구현에 따라 구문이 달라 이식성이 없고, 사용할 수 없는 구현도 있다.
- 2. 시스템에서 자동으로 생성되는 값이므로 실제 엔티티 속성이다.
- 3. 성능문제를 일으킨다.

3을 중심으로 설명해보자면, 시퀀스 객체가 생성하는 순번으로 기본적으로 다음과 같은 세가지 특성을 가진다.  
- 유일성
- 연속성
- 순서성  
따라서 시퀀스 객체는 동시 실행 제어를 위한 락 매커니즘이 필요하다.  
락 매커니즘은 동시에 여러 사용자가 시퀀스 객체에 접근하는 경우 락 충돌로 인해 성능 저하 문제가 발생한다.  

성능문제를 완화하는 방법으로는 CACHE와 NOORDER객체가 있다.  
- CACHE  
: 새로운 값이 필요할때마다 메모리에 읽어들일 필요가 있는 값의 수를 설정. 장애발생시 비어있는 숫자 발생  
- NOORDER  
: 순서성을 담보하지 않아 오버헤드를 줄이는 효과  

또한 시퀀스 객체가 성능 문제를 일으키는 경우는 핫스팟과 관련된 문제가 있다.  
I/O 부하가 몰리는 부분을 핫스팟이라고 하는데  
시퀀스 객체를 사용한 INSERT를 반복해서 대량의 레코드를 생성하는 경우 해당 문제가 발생한다.

해당 문제를 완화 할 수 있는 방법으로  
1. Oracle의 역키인덱스처럼, 연속된 값을 도입하는 경우라도 DBMS 내부에서 변화를 주어 제대로 분산할 수 있는 구조(일종의 해시)를 사용하는것  
2. 인덱스에 복잡한 필드를 추가하여 데이터 분산도를 높이는 것 (emp_id, seq)처럼 추가적 필드를 사용해 인덱스를 만드는 것  
이 있다.  
그러나 이러한 방법은 SELECT 구문의 성능이 나빠질 위험이 있고 구현의존적 방법이기때문에 좋지않다.

#### 2. IDENTITY 필드
자동 순번 필드로 테이블에 INSERT가 발생할 때 마다 자동으로 순번을 붙여준다.  
시퀀스 객체는 CACHE, NOORDER를 지정할 수 있으나 IDENTITY 필드는 제한적으로 사용할수있거나 사용할수 없으므로 이점이 거의 없다.

#### 3. 채번 테이블
옛날에 사용되던 순번 전용 테이블을 이용하는 방식으로 성능이 제대로 나오지않으므로 현재 사용할 이유가 전혀 없다.

### 마치며
- SQL에서 초기에 배제했던 절차 지향형이 윈도우 함수라는 형태로 부활
- 윈도우 함수를 사용하면 코드를 간결하게 기술할 수 있으므로 가독성 향상
- 윈도우 함수는 조인 또는 테이블 접근을 줄이므로 성능향상을 가져옴
- 시퀀스 객체 또는 IDENTITY 필드는 성능 문제를 일으키는 원인이 되므로 사용할 때 주의가 필요