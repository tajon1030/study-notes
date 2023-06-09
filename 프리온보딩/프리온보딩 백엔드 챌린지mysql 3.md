﻿
# 3회차 - MySQL 기본개념 (공유용)
## 1.  쿼리 실행 절차
1.  parse??? → SQL문장 → MySQL이 이해할 수 있도록 처리 (parsing)
        1.  Lexical analysis: The server breaks down the query into individual tokens, such as keywords, identifiers, and operators.
        2.  Syntax analysis: The server checks the query for proper syntax and structure, and verifies that all the elements of the query are used correctly.
        3.  Semantic analysis: The server checks that all the tables and columns referenced in the query exist, and verifies that the query is semantically correct.
        4.  Query optimization: The server optimizes the query for execution by creating an execution plan that outlines the most efficient way to retrieve the requested data.

2.  어떤 테이블과 어떤 인덱스를 읽을지 선택
- 불필요한 조건 제거 및 복잡한 연산 단순화
- join의 경우 read 순서 결정
- 각 테이블 별 조건과 인덱스 통계정보를 활용하여 사용할 인덱스 결정
- 임시테이블에 데이터를 두고 한 번 더 가공할지 결정
3.  데이터를 가져옴
## 2.  `SELECT`
**실행순서 - 면접질문**
FROM / JOIN → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
## 3.  join이란?
여러 테이블에서 데이터를 가져오는 방법
###  join의 종류
**1.  inner join**
- 두 테이블 모두에 값을 가지고 있는 경우
- 두 테이블 모두에 값이 있어야만 표시됨
 
**2.  left join**
- left table에서 값을 모두 가져오고 right table은 match가 있는 경우에만 가져옴
- left join을 시도했기 때문에, right table에서 없는 값들이 NULL로 표시된다

**3.  right join**
- right table에서 값을 모두 가져오고 left table은 match가 없는 경우에만 가져옴

**4.  full join**
- table 전체를 다 봄

**5.  CROSS JOIN**
- 합집합 같은 느낌

**6.  SELF JOIN**
- 본인 테이블을 대상으로 CROSS JOIN


## 4.  subquery란?
query안에 query문을 추가하는 것
- 먼저 돌아가고, 여기서 돌아간 값을 밖에있는(outer, parent) 쿼리가 사용한다
- select, from, where 에 사용

## 5.  SQL 내장함수란?
단어 그대로 “기본으로 제공하는 함수”
다양한 종류들이 있지만 그룹함수(aggregation)에 대해서만 짚고감
(실제로 SQL 내장함수들 중 면접에서 제일 많이 물어봄)
- COUNT(), MAX(), MIN(), AVG()
- 여러 레코드의 값을 병합해서 하나의 값으로 만들어냄
- GROUP BY와 같이 사용됨.
- Aggregation은 언제 실행되는지??

 CASE WHEN … THEN … END
