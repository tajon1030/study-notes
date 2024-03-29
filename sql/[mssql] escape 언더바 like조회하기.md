# [mssql] escape 예약어 like 조회하기

언더바와 같은 예약어를 포함하고있는 컬럼을 조회하려고 할때, 그냥 검색할 특수문자만 입력하게되면 원하는대로 조회가 되지않습니다.  

예를 들어 언더바를 포함하고있는 아이디를 가진 회원을 찾고싶다 라고 할 경우  
~~~sql
SELECT * FROM USERS WHERE LOGIN_ID LIKE '%_%'
~~~
다음과 같이 쿼리문을 작성한다면 언더바는 글자 하나를 의미하여 그저 LOGIN_ID 길이가 한자리 이상을 가지는 모든 데이터가 조회될 것입니다.  

따라서 이러한 경우에는 특별한 방법을 사용해야하는데 이때 사용하는 것이 **escape** 입니다.  
사용법은 사용하려는 특수문자앞에 아무 문자나 작성한뒤 쿼리문 뒤에 escape로 선언하면 됩니다.  
이런 방식으로 해당문자가 백스페이스와같은 역할을 한다는것을 명시할 수 있습니다.  

위에서 원하는 쿼리식을 다시 작성한다면 다음과 같습니다.  
~~~sql
SELECT * FROM USERS WHERE LOGIN_ID LIKE '%#_%' ESCAPE '#';
~~~