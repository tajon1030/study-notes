# [mssql] select into from 테이블 복사하기

개발DB에 실DB에 있는 데이터 중 일부를 넣어야 하는 상황이 발생했다.  
임시로 테이블을 만들고 일부 데이터만 삽입해넣은 후 해당 테이블을 SSMS의 데이터 내보내기 기능을 통해 삽입할 수 있었다.  

## select into from
~~~sql
SELECT *
INTO 생성할_백업_테이블명
FROM 원데이터_테이블명
WHERE 조건
~~~

## SSMS Export
- 원본 선택 : SQL Server Native Client 11.0  
(SQL Server 인증사용하여 실DB이름 및 암호 입력, 데이터베이스 선택)  
- 대상 선택 : SQL Server Native Client 11.0  
(SQL Server 인증사용하여 개발DB이름 및 암호 입력, 데이터베이스 선택)
- 하나 이상의 테이블 또는 뷰에서 데이터 복사
- 원본테이블 및 뷰 선택(매핑편집 확인)
- Finish

## 참고
[[MSSQL] SELECT ~ INTO ~ FROM (mssql 테이블 복사하기 select into)](https://infodbbase.tistory.com/50)  
[SSQL Export (내보내기 마법사 사용)](https://docko.tistory.com/218)  