# [mssql] text 타입과 varchar타입

mssql에서 다음과 같은 쿼리문을 실행시켰는데 오류가 발생하였습니다.  
~~~sql
SELECT * FROM TB1 WHERE TEXT_COL = 'test'
~~~

> 오류 메세지 : 데이터 형식 Text 및 Varchar가 equal to 연산자에 호환되지 않습니다.  

이럴때의 해결책으로는 
`CONVERT(VARCHAR(max), 컬럼명)` 과 같이 형변환을 통해서 검색을 하면 오류없이 정상 실행 됩니다.  
~~~sql  
SELECT * FROM TB1 WHERE CONVERT(VARCHAR(MAX), TEXT_COL) = 'test'
~~~  

왜 이런 문제가 발생했는지 공식문서를 살펴보다가  
mysql과는 다르게 mssql에서 **text타입은 이후 버전에서 제거될 것**이며, **varchar(max)**을 사용하도록 알리는 내용을 발견하였습니다.  

varchar(max)는 text과 다르게 이점을 가지는데, 만약 varchar(max)의 데이터들이 8kb이하의 데이터를 가지게된다면 테이블의 저장공간에 저장되고  
그 이상이라면 out of row 방식으로 다른 공간에 데이터를 저장하고 포인터를 사용하여 가르키게 됩니다. (보통 테이블 공간에 저장이되면 속도 효율이 더 좋습니다.)  
따라서 이전에 쓰였던 text타입보다는 varchar타입을 사용하며  
8kb 보다 작은 데이터를 저장할것이라면 varchar(N)과 같은 방식을 사용합시다.  


## 참고  
[ntext, text 및 image(Transact-SQL)](https://learn.microsoft.com/ko-kr/sql/t-sql/data-types/ntext-text-and-image-transact-sql?view=sql-server-2016)  
[[MSSQL] 데이터 형식 Text 및 Varchar가 equal to 연산자에 호환되지 않습니다.](https://syrius.tistory.com/31)  
[[MSSQL] VARCHAR(MAX) vs VARCHAR(N) / VARCHAR(MAX) 의 단점](https://mozi.tistory.com/326)  
[MS SQL Server Data Type TEXT or VARCHAR?](https://www.datanamic.com/support/kb-dez005.html)