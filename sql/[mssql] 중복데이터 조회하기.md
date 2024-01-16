# [mssql] 중복데이터 조회하기

## 집계함수 GROUP BY 를 사용하는 방법
GROUP BY를 사용하면 중복 컬럼값을 **하나**만 가져올 수 있습니다.  
단, GROUP BY 에 들어간 컬럼 이외의 값을 조회할 수 없습니다.  
~~~sql
SELECT job
     , deptno
     , COUNT(*) AS cnt
  FROM emp
 GROUP BY job, deptno 
 HAVING COUNT(*) > 1
~~~

## COUNT(*) OVER(PARTITION BY) 사용하는 방법
~~~sql
SELECT a.*
  FROM (
         SELECT empno
              , ename
              , hiredate
              , job
              , deptno
              , COUNT(*) OVER(PARTITION BY job, deptno) AS cnt
           FROM emp
       ) a
 WHERE a.cnt > 1
~~~
이 방식은 **중복 건수들만 모두** 조회하게 됩니다.

## ROW_NUMBER() OVER(PARTITION BY) 를 사용하는 방법
이 방식은 특정 컬럼을 기준으로 중복을 제거하고, 모든 컬럼값을 조회할 수 있습니다.  
~~~sql
SELECT empno
     , ename
     , job
     , hiredate
  FROM (
         SELECT empno
              , ename
              , job
              , hiredate
              -- job별로 hiredate가 최신순으로 순번 지정
              , ROW_NUMBER() OVER(PARTITION BY job ORDER BY hiredate DESC) AS rn
           FROM emp
       )
 WHERE rn = 1 -- 첫번째 순번만 조회
 ORDER BY job
~~~

## 참고
[[Oracle] 오라클 중복 데이터를 찾는 2가지 방법](https://gent.tistory.com/485)  
[[Oracle] 중복 데이터 하나만 남기고 제거 2가지 방법](https://gent.tistory.com/478)