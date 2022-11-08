CREATE DATABASE foodDB;
USE foodDB;
CREATE TABLE tbl_today (
날짜 VARCHAR(10) NOT NULL,
식품명 VARCHAR(125) NOT NULL,
섭취량 INT,
칼로리 INT
);

INSERT tbl_today VALUES ("2022-07-03", "행복 토스트 식빵", 1, 100);
INSERT tbl_today VALUES ("2022-07-05", "버거킹 스태커 와퍼2", 2, 200);

SELECT * FROM tbl_today;

-- 기본키를 설정할 수 없을 경우...
-- 각 튜플마다 일련번호(index)를 부여하거나 WHERE 조건을 2개 이상 준다.
/* 
cf)
DELETE FROM tbl_today WHERE food = "비타500";
WHERE 조건의 컬럼이 기본키가 아니므로 UPDATE 나 DELETE 시 오류가 뜬다. 따라서... 
Edit -> Preferences... -> SQL Editor 탭의 Other 항목에서 Safe Updates 체크 해제 후 MySQL 재시작
*/
