# [mssql] set nocount

회사 프로젝트 중 쿼리문에 SET NOCOUNT ON 이라는 선언이 적혀져있는 것을 보고 해당 쿼리문이 해당하는 의미에 대해 찾아보게 되었습니다.  

## SET NOCOUNT 이란?
SET NOCOUNT {ON/OFF} 는 쿼리문이나 프로시저의 영향을 받은 행 수를 나타내는 메시지가 결과집합의 일부로 반환되지 않도록 하는 것을 의미합니다.  
MSSQL에서 쿼리문을 실행했을때 n개 행이 영향을 받음 이라는 메시지를 확인 할 수 있는데,  
해당 메시지는 INSERT나 UPDATE/DELETE 처럼 테이블에 영향을 주면 출력이 되고,  
때로는 이런 메시지를 출력하는 것이 서버 부하에 영향을 줄 수 있습니다.  
따라서 프로시저나 쿼리문 시작점에 SET NOCOUNT ON 이라는 문구를 삽입해주면 메시지를 제거해주어 이에따른 서버부하를 줄일 수 있게됩니다.  


## 참고
[[MSSQL] SET NOCOUNT 정의와 사용법 (프로시저 성능 향상)](https://coding-factory.tistory.com/95)