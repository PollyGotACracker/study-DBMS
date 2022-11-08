/*
DDL 명령 세트 : CREATE, DROP, ALTER
	CREATE DATABASE : Schema 생성
    CREATE TABLE : 데이터를 저장할 Table 정의 및 생성
    
    DROP DATABASE : Schema 를 완전하게 제거, Schema 에 포함된 모든 객체가 같이 삭제된다.
    DROP TABLE : Table 을 완전하게 제거
    
    ALTER TABLE : 칼럼 추가, 칼럼 변경 등을 수행하는 명령
				  명령을 수행하는 데 많은 비용이 소요된다.
                  꼭 필요한 경우, 불가피한 경우가 아니면 가급적 사용하지 말자
*/
DROP TABLE tbl_student;

CREATE TABLE tbl_student (
	st_num	VARCHAR(5)	NOT NULL	PRIMARY KEY,
	st_name	VARCHAR(10)	NOT NULL,	
	st_dept	VARCHAR(20),		
	st_grade	INT,		
	st_tel	VARCHAR(15),		
	st_addr	VARCHAR(125)		
);
