# [mssql] delete from from  
회사에서 delete from from 이라는 구문을 보게 되었습니다.  
실수로 작성한 구문인가 했는데 실제로 잘 동작하는 쿼리문이었습니다.  

우선 평소에 자주 사용하는 delete문에 대해서 짚고 넘어가도록 하겠습니다.  
## 기본적인 delete문  
기본적인 delete문은 다음과 같습니다.  
~~~sql
delete 
from member 
where name = 'Jake'
-- member테이블에서 name컬럼값이 Jake인 항목을 삭제한다.
~~~

MSSQL(T-SQL)에서는 **from 키워드를 생략해도 된다**고 합니다.  
따라서 다음과 같이 나타낼 수 있습니다.  
~~~sql
delete mebmer
where name = 'Jake'
~~~

## 다른테이블과 join하여 나오는 값을 삭제  
다른테이블과 join하여 나오는 값을 삭제하는법은 다음과 같습니다.  
~~~sql
delete post  -- 삭제할 테이블
from member m -- 조인 테이블
where m.name = 'Jake'
and m.id = post.writer_id
-- member테이블과 post테이블을 조인하여 member테이블의 name컬럼값이 Jake인 post값을 삭제한다.
~~~
앞선 쿼리는 from 키워드를 생략한 쿼리문입니다.  
생략된 from 키워드를 다시 작성하면 회사에서 본 것과 같은 delete from from 의 구문을 만들게 됩니다.  
~~~sql
delete 
from post
from member m
where m.name = 'Jake'
and m.id = post.writer_id
~~~


다음과 같이 기술할수도 있습니다.  
이상한요구이긴 하나 다음 쿼리는 이름이 Test인 회원의 추천인의 게시글을 삭제합니다.  
~~~sql
delete post
from member m1
join member m2
on m1.id = m2.recommend_member_id
where m2.name = 'Test'
and post.writer_id = m1.id
~~~

만약 조인영역의 from절(여기서는 post p)에 삭제할 테이블(post)이 동일하게 기술되어있다면,  
별도 테이블 조인을 하지않아도(where 조건 이후에 and p.id = post.id와 같은 조인조건을 작성하지않아도)  
테이블에 해당하는 데이터가 삭제됩니다.  
~~~sql
delete post
from post p
join member m
on p.writer_id = m.id
where m.name = 'Jake'
~~~

## 특정조건에 해당하는/해당하지않는 컬럼 삭제하기
IN절로 delete문을 작성하기에는 성능상 이슈가 발생한다면 EXIST를 사용하여 다음과 같이 쿼리를 작성할 수 있습니다.  
~~~sql
delete post
where exists (select 1
              from member m
              where m.name = 'Jake'
              and post.writer_id = m.id)
~~~



### 참고
https://stackoverflow.com/questions/56453021/sql-server-delete-from-table-from-table
https://gent.tistory.com/500