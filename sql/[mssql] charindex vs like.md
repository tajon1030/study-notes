# [mssql] charindex vs like

charindex는 특정위치의 인덱스를 찾을 수 있는 함수입니다.  
기본적인 문법은 다음과 같습니다.  
~~~sql
CHARINDEX([찾을문자], [대상문자열])
CHARINDEX([찾을문자], [대상문자열], [찾기시작할 위치])
~~~

전화번호를 자리수대로 나누거나 할때 SUBSTRING과 같은 함수를 사용해야하는데 그럴때 인덱스를 찾아내기위한 방법으로 쓸 수 있습니다.  
~~~sql  
SELECT LEFT('010-1234-5678', CHARINDEX('-', '010-1234-5678') - 1) -- 첫째자리
SELECT SUBSTRING('010-1234-5678', CHARINDEX('-', '010-1234-5678') + 1, LEN('010-1234-5678') - CHARINDEX('-', '010-1234-5678') - CHARINDEX('-', REVERSE('010-1234-5678'))) -- 가운데자리
SELECT RIGHT('010-1234-5678', CHARINDEX('-', REVERSE('010-1234-5678')) - 1) -- 마지막자리
~~~

이외에도 해당 문자가 존재하면 처음으로 나타나는 위치를, 존재하지않으면 0을 리턴하는 특징을 사용하여 like 연산 대신에 이용할 수도 있다는 것을 알게되어  
성능면에서 어떤것이 더 좋을까?에 대해 알아보았습니다.  
~~~sql
-- charindex 사용
SELECT * FROM TB1 WHERE CHARINDEX('word', COL) > 0;
-- like 사용
SELECT * FROM TB1 WHERE COL LIKE '%word%';
~~~
테스트를 직접 해봐야하겠지만 일단 일반적인 경우에는 성능 차이가 크지 않으며,  
최적화된 인덱스가 있다면 **CHARINDEX**가 성능 향상에 도움이 될 수 있다고 합니다.  

다만 기본적으로 CHARINDEX를 사용하면 대소문자 구분을 하지 않는데 구분을 시키기위해서는 다음과 같이 사용해야합니다.  
~~~sql
CHARINDEX([찾을문자], [대상문자열] COLLATE Latin1_General_CS_AS)
~~~

그렇지만 CHARINDEX는 단순 문자열 검색에 특화되어있기때문에  
만약 텍스트 검색을 주로 사용하기위한 성능향상을 위해서라면  
Full Text Search라는 기능을 사용해 보는것을 고려하는것이 좋을것입니다.  

## 참고
[MSSQL 특정 문자 찾기 CHARINDEX](https://aidenarea.tistory.com/entry/MSSQL-%ED%8A%B9%EC%A0%95-%EB%AC%B8%EC%9E%90-%EC%B0%BE%EA%B8%B0-CHARINDEX)

## Full Text Search에 대해서...
[[MSSQL] 풀텍스트인덱스 사용법](https://inpa.tistory.com/entry/MYSQL-%F0%9F%93%9A-%ED%92%80%ED%85%8D%EC%8A%A4%ED%8A%B8-%EC%9D%B8%EB%8D%B1%EC%8A%A4Full-Text-Index-%EC%82%AC%EC%9A%A9%EB%B2%95)  
[FullTextSearch를 이용한 DB성능 개선 일지](https://www.essential2189.dev/db-performance-fts)  