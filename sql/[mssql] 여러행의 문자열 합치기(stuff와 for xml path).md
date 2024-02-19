# [mssql] 여러행의 문자열 합치기(stuff와 for xml path)

select한 여러 row의 컬럼을 하나의 문자열로 합쳐서 표현해야 할 때가 있습니다.  
이럴경우 **FOR XML PATH('')**를 통해 여러행의 자료를 임의의 구분자 ', '를 넣어 한 열의 구문으로 만들고  
**STUFF()**를 이용해 맨 앞의 구분자 ','를 없애는 방식으로 나타낼 수 있습니다.  

## STUFF
stuff 는 문자열의 시작위치와 길이를 지정하여 원하는 문자로 치환 가능합니다.
~~~sql
STUFF(문자열,시작위치,길이,치환문자)
~~~

## FOR XML
for xml은 쿼리실행결과를 xml로 나타냅니다.  
for xml 에는 여러 모드가 있으며 여러행의 문자열을 합치기위해서 사용할 모드의 경우 path로 간편하게 xml형태를 가공가능합니다.  
만약 다음과 같은 임의의 테이블이 있을 경우  
| seq | memo    |
|-----|---------|
| 1   | tiger   |
| 1   | lion    |
| 2   | cat     |

~~~sql
select * from tmp for xml path
~~~  
쿼리를 실행하면 다음과 같은 결과를 나타내게 됩니다.

~~~xml
<row>
    <seq>1</seq>
    <memo>tiger</memo>
</row>
<row>
    <seq>1</seq>
    <memo>lion</memo>
</row>
<row>
    <seq>2</seq>
    <memo>cat</memo>
</row>
~~~

만약 for xml path에 옵션값을 준다면 xml의 <row>가 해당 명칭으로 변경됩니다.  
~~~sql
select memo from tmp for xml path('')
~~~  
~~~xml
<memo>tiger</memo>
<memo>lion</memo>
<memo>cat</memo>
~~~
위 쿼리를 실행한 결과 row가 빈문자열이 되면서 제거됐습니다.  

아래와 같이 행구분자(',')추가하게되면 컬럼의 명칭이 null이 되어 <memo></memo> 컬럼명이 제거됩니다.
~~~sql
select ','+ memo from tmp for xml path('')
-- ,tiger,lion,cat
~~~ 

## 여러행의 문자열 합치기 예제
| seq | memo    |
|-----|---------|
| 1   | tiger   |
| 1   | lion    |
| 2   | cat     |
| 2   | dog     |
| 2   | rabbit  |
| 3   | hamster |

tmp테이블에 다음과 같은 데이터가 존재할 경우 seq에 따라 memo값을 한 컬럼으로 나타내고 싶다면 다음과 같이 쿼리를 작성하면 됩니다.

~~~sql
select distinct seq, 
        stuff( (
            select ',' + memo
            from tmp
            where seq = t.seq
            for xml path('')
        ), 1, 1, '') as memo
from tmp t
~~~  

for xml path('') 와 구분자를 이용하여 하나의 문자열로 나타내고 stuff를 사용하여 맨 앞에 있는 구분자를 제거하였습니다.  
그리고 같은 seq끼리 묶기위하여 where절을 사용하며, 동일한 값의 행이 중복되어 나타나기때문에 `distinct`를 이용하여 중복을 제거해줍니다.  

| seq | memo             |
|-----|------------------|
| 1   | tiger, lion      |
| 2   | cat, dog, rabbit |
| 3   | hamster          |

만약 memo에 중복된 값이 존재할 경우 memo를 나타내는 서브쿼리에서 `group by`를 해주면 중복되는 memo값을 제거할 수 있습니다.  
~~~sql
select distinct seq, 
        stuff( (
            select ',' + memo
            from tmp
            where seq = t.seq
            group by memo
            for xml path('')
        ), 1, 1, '') as memo
from tmp t
~~~

## 참고
[[MsSQL] 여러 행 문자열 합치기 - For Xml Path() / Stuff() 알아가기](https://da-new.tistory.com/13)