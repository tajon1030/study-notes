# mssql 락 
- 기본격리수준 commited read  
- select 시 자동 slock  
- dml 시 자동 xlock  

만약 테이블의 특정row에 update를 실행하고 아직 commit하지 않았다면 해당row에대해 xlock이 걸려있게 됩니다.  
xlock은 여러 트랜잭션이 동시에 읽기 및 쓰기를 수행하지 못하도록 막습니다.  
따라서 다른 트랜잭션이 해당 행을 읽으려고 할 때, 일반적으로 slock을 획득하려고 시도할 것인데 xlock이 걸려있는 경우에는 slock을 획득하지못하기때문에 대기하게 될것입니다.  

반대로 만약 테이블의 특정 row에 select가 실행되고 트랜잭션이 종료되지 않았을 경우엔 해당 row에 대해 slock이 걸려서 다른트랜잭션이 update를 실행하려 하면 대기상태에 돌입할것으로 예상될것입니다.  
하지만 이는 그렇지 않은데 기본설정상태에서 MSSQL은 SELECT문 즉시 slock을 해제하기때문에 트랜잭션이 종료되지않아도 update가 가능합니다.  
https://learn.microsoft.com/ko-kr/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-ver15#shared


## with(nolcok)을 사용하여 select 할 경우  
with(nolock)은 잠금을 무시하여 dirty read를 하기때문에 update한 데이터가 commit되지않았어도 update된 내역을 select해오게 됩니다.  
이럴경우 update를 진행한 트랜잭션에서 rollback을 하게된다면 select한 데이터는 잘못된 값이 될수있습니다.  

select를 할때 join해서 가져오는 경우 with(nolock)을 사용하기위해서는 모든 테이블에 적어줘야합니다.  

프로시저에서 사용되는 SELECT문에 WITH(NOLOCK)을 전부 걸고싶다면 프로시저 시작부분에 `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED` 라고 작성하면 됩니다.  
https://ence2.github.io/2020/11/mssql-with-nolock/



## 참고
https://mozi.tistory.com/323  
https://www.sqler.com/board_SQLQA/1090604  
https://dbtuner.tistory.com/entry/MSSQL-JOIN%EC%8B%9C-Share-lock  
https://mangkyu.tistory.com/299  


## 추가 정리 - mysql
- 기본격리수준 repeatable read  
- 기본 select는 락을 걸지 않음  

### case 1. 
t1 : select  
t2 : update  
t1 : select (update이전내역조회)  
t2 : commit  
t1: select (update이전내역조회)  
t1: commit  
t3: select  
=> t1이 select를 먼저 시작했으면  
t2가 나중에 트랜잭션을 시작해서 업데이트하고 커밋할지라도  
t1은 이전내역을 보여준다(repeatable read)  
t1이 commit하고 새롭게 select하면 이제는 t2업데이트가 적용된 모습이 보인다.  


### case 2  
t1 : select  
t2 : update  
t1 : select for share  
=> update시에 xlock이 걸렸는데 slock이 걸리는 조회가 되지않고 대기상태가 된다.  
t2 : commit  
t2에서 commit을 해줘야 t1의 select for share가 가능해진다.  
그리고 이때에는 update된 내역이 조회된다<-????read committed?  


### case 3  
t1 : select for share  
t2 : update  
=> select for share시에 slock이 걸려서 xlock이 걸리는 update는 대기  

### case4  
t2 : update  
t1 : select(update 이전 내역 조회)  
t2 : commit  
t1 : select(update 이전 내역 조회  
t1 : select for share (update이후내역 조회)  
t1 : select(update 이전 내역 조회  
t1 : select for share (update이후내역 조회)  
t3 : select for share (잘조회됨)  

## 추가
레코드락/갭락/넥스트키락/자동증가락  
https://suhwan.dev/2019/06/09/transaction-isolation-level-and-lock/  
https://mangkyu.tistory.com/298  

mysql은 pk에 lock을 걸어야지 해당 row에만 lock이 생성되고  
그렇지 않은 경우에는 모든 row에 lock이 생성된다.  
inddex에 lock을 걸면 해당 row에만 lock이 생성되고 pk에도 lock이 생성된다.  
https://willbfine.tistory.com/578  

mssql에서는? ->?

### 참고
https://idea-sketch.tistory.com/45