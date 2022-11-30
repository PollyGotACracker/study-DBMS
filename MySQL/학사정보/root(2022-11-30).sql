-- 학사정보 SQL, root 화면

DROP DATABASE schoolDB;
CREATE DATABASE schoolDB;

USE schoolDB;

CREATE TABLE tbl_students (
	st_num	VARCHAR(5)	NOT NULL	PRIMARY KEY,
	st_name	VARCHAR(10)	NOT NULL,
	st_dept	VARCHAR(20),
	st_grade	INT,
	st_tel	VARCHAR(15),		
	st_addr	VARCHAR(125)	
);
-- excel 에서 다른 이름으로 저장(csv 파일, utf-8 아닌 형식으로)
-- Table data import Wizard 를 실행하여 데이터 import

-- import 데이터 확인하기
-- import 된 데이터의 개수를 확인하기
SELECT COUNT(*) FROM tbl_students;

-- 샘플데이터 SELECT 하여 확인하기
SELECT * FROM tbl_students
WHERE st_num='S0015';

/*
학생정보 table 에 대한 정규화
1. tbl_students 데이터에 대한 문제점 이해하기
	가. 대표적으로 문제가 되는 데이터는 "학과(이름)" 이다.
		학과(이름)은 일반적인 문자열로 저장되어있고, 
        같은 데이터가 여러번 중복되어 나타난다.
	나. 만약 이 데이터들을 사용하다가 학과(이름)가 변경되는 경우가 발생한다면
		다수의 데이터에 대한 UPDATE 쿼리가 필요할 것이다.
        아래의 UPDATE SQL 이 필요할 것이다.
	다. 만약 기존에 건축공학으로 되어있는 데이터가 다수 존재한다면 
		그 데이터들이 모두 UPDATE 되어야 할 것이다.
	라. 실제 Table 에 다수의 데이터가 UPDATE 되는 것은 별로 좋은 실행이 아니다.
		(데이터가 UPDATE 되는 동안 Table lock 발생, 연계된 모든 processor 대기(교착상태;Deadlock))
        (Deadlock 방지를 위해, DML 동작이 일정 시간을 초과하면 Rollback)
	마. 자주 발생하는 경우는 아니지만, 학과(이름) 정보를 변경하는 경우가 발생할 가능성이 있다면
		이 table 은 정규화 과정을 수행해야 한다.
*/

UPDATE tbl_students 
SET st_dept = '건축 아키텍쳐' 
WHERE st_dept = '건축공학';

-- tbl_students 테이블의 학과(이름) 항목에 대하여 정규화 하기
-- 1. tbl_students 테이블의 학과 칼럼들 이름을 중복되지 않게 리스트 찾기

SELECT DISTINCT st_dept FROM tbl_students ORDER BY st_dept;
SELECT st_dept FROM tbl_students GROUP BY st_dept ORDER BY st_dept;

-- 학생정보와 학과테이블을 분리하기 위한 임시 테이블 생성
CREATE TABLE tbl_depts (
dp_code VARCHAR(5),
dp_name VARCHAR(20)
);

SELECT * FROM tbl_depts;
/*
학생정보 테이블에 학과명만 추출하여 별도의 리스트로 만들고 
리스트에 학과코드를 추가했다.
일부 동일한 학과일 경우 학과 코드를 같은 값으로 매칭
tbl_depts 테이블을 생성하고 데이터를 import 했다.
*/

/*
1. tbl_students 테이블의 학과명 대신 사용할 학과코드 칼럼을 생성(추가)
2. 각 학생의 학과명에 해당하는 학과코드를 tbl_depts 에서 찾아서
	Update 를 수행하기
*/
-- 테이블 구조 변경: ALTER TABLE 명령(DDL 명령)
-- 학생테이블에 st_dpcode 칼럼을 VARCHAR(5) 형식으로 추가하라
ALTER TABLE tbl_students ADD (st_dpcode VARCHAR(5));
DESC tbl_students;

-- 필요없는 칼럼을 삭제하기
-- ALTER TABLE tbl_students DROP st_dpcode;

-- tbl_students 테이블과 tbl_depts 테이블을 JOIN 수행
-- students 테이블의 st_dept(학과명)과 depts 테이블의 dp_name 의 값이 일치하는 정보를 JOIN


-- student, dept table 을 JOIN 한 결과에서 
-- dp_code 데이터를 찾을 수 없는지(dp_code IS NULL) 를 확인하기
-- 여기서 결과가 하나도 나오지 않아야 한다.
SELECT st_num, st_name, st_dept, dp_name, dp_code
FROM tbl_students ST 
	LEFT JOIN tbl_depts DP
	ON ST.st_dept = DP.dp_name
		WHERE dp_code IS NULL;
/*
학생정보의 학과이름을 사용하여 학과테이블에서 학과정보를 
JOIN SELECT 하여 보여주기
이 쿼리에서 현재 st_dpcode 데이터는 null 인 상태임이 확인되었다.
이 쿼리 결과에서 dp_code 데이터를 st_dpcode 칼럼에 UPDATE 를 한다면
원하는 결과를 얻어낼 수 있다.
*/        
SELECT st_num, st_name, st_dept, dp_name, dp_code
FROM tbl_students ST 
	LEFT JOIN tbl_depts DP
	ON ST.st_dept = DP.dp_name;

/*
위에서 JOIN SELECT 한 결과에서 보여준 dp_code 데이터를 
학생 테이블의 st_dpcode 칼럼에 모두 UPDATE 를 수행한다.

주의
MySQL 에서는 여러가지 이유로 다량의 데이터를 UPDATE 하거나, DELETE 할 수 없도록
초기 설정이 되어있다.
이러한 조치를 Safe Update Mode 라고 한다.
현재 학생 데이터 전체에 대하여 UPDATE 를 수행하려고 하기 때문에 
잠시 이 mode 를 사용하지 않도록 설정해주어야 한다.
*/

SET SQL_SAFE_UPDATES = 0;

UPDATE tbl_students ST
	LEFT JOIN tbl_depts DP
		ON ST.st_dept = DP.dp_name
SET ST.st_dpcode = DP.dp_code;

/*
1. tbl_students 테이블 전체를 SELECT 하여 나열
2. 나열된 List 를 반복하면서 st_dept 칼럼의 데이터를 내부의 () SELECT 문에 한 개씩 전달
3. 내부의 SELECT 문이 실행되어 tbl_depts 에서 학과명을 찾고
4. 찾은 학과명을 마치 하나의 칼럼 데이터처럼 표현하는 코드
*/
SELECT st_dept, st_dpcode,
(SELECT dp_code FROM tbl_depts WHERE dp_name = st.dept) AS DPCODE FROM tbl_students;

-- Sub QUERY 를 사용하여 데이터 일괄 UPDATE 하기
UPDATE tbl_students SET st_dept = (SELECT dp_code FROM tbl_depts WHERE dp_name = st_dept);

SELECT st_num, st_name, st_dpcode, st_grade, st_tel, st_addr 
FROM tbl_students
ORDER BY st_num;

-- 학생정보에 학과코드를 UPDATE 완료했다.
-- 정식으로 사용할 학과정보 테이블을 생성하자.
DROP TABLE tbl_depts;
CREATE TABLE tbl_depts(
	dp_code	VARCHAR(5)		PRIMARY KEY,
	dp_name	VARCHAR(20)	NOT NULL	UNIQUE,
	dp_prof	VARCHAR(20),		
	dp_office	VARCHAR(5),		
	dp_tel	VARCHAR(15),		
	dp_manager	VARCHAR(20),		
	dp_man_tel	VARCHAR(15)		
);

DESC tbl_detps;
SELECT * FROM tbl_depts;

-- 가상테이블인 view CREATE
CREATE VIEW view_students
AS
(
	SELECT st_num, st_name, st_dpcode, dp_name, dp_prof, dp_tel, st_grade, st_tel, st_addr
	FROM tbl_students
		LEFT JOIN tbl_depts
			ON st_dpcode = dp_code
	ORDER BY st_num
);

SELECT * FROM view_students; 