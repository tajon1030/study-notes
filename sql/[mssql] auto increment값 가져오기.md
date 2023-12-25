# [mssql] auto increment값 가져오기

mybatis에서는 useGeneratedKeys옵션과 keyProperty옵션을 사용하여 db에 값을 insert한 다음 자동 생성된 id값을 가져올 수 있다.  
~~~xml
<insert id="insertArticle" parameterType="map" useGeneratedKeys="true"
        keyProperty="articleId" keyColumn="article_id">
    INSERT INTO article ( title, reg_date ) VALUES ( #{title}, GETDATE() )
</insert>
~~~  
~~~java
Map<String, String> params = new HashMap<>();
params.put("title", "제목");
myMapper.insert(params);

// insert 실행에 사용한 Map 파라미터에 articleId 값이 세팅된다.
System.out.println("articleId: " + params.get("articleId"));
~~~

그러나 현재 회사에서 진행중인 프로젝트의 경우 mybatis를 사용하지않고 nativequery를 이용하고 있기때문에  
mssql에서 직접 자동생성된 id값을 가져오기위한 쿼리를 insert문 뒤에 추가로 작성해야한다.  

## 자동증가 시드값을 가져오는 세가지 방법  
auto increment한 값을 가져오기위한 쿼리문으로 세가지 방법이 있다.  
1. IDENT_CURRENT('테이블명')  
2. @@IDENTITY  
3. SCOPE_IDENTITY()  

1번의 경우 현재 세션에 국한되지않고 가장 최근에 생성된 **특정테이블**에 대한 마지막 ID값을 반환해준다.  
`select IDENT_CURRENT('테이블명') as seq`  

2번의 경우 마지막으로 삽입된 행에서 생성된 ID값을 반환해준다.  
트리거나 다른 테이블에 의해 마지막으로 생성된 IDENTITY값이 변경된 경우 해당값을 반환한다.  
`select @@IDENTITY as seq`  

3번의 경우 **현재 스코프**에서 마지막으로 삽입된 행에서 생성된 ID값을 반환해준다.  
트리거 등으로 다른 스코프에서 마지막으로 생성된 IDENTITY 값이 변경된 경우 해당 값을 반환하지 않는다.  
`select SCOPE_IDENTITY() as seq`  

저장프로시저를 사용할때 3번의 경우가 유용하게 사용되며 트리거 등의 영향을 최소화할수있다는 장점이 있다.  

## 참고
[[DB] MSSQL 자동증가열(IDENTITY)사용법 및 주의사항](https://sosopro.tistory.com/30)  