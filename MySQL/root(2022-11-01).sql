-- 여기는 root 화면
USE world;
SELECT * FROM country ORDER BY name;

-- name 칼럼에 저장된 문자열을 정확히 검색할 때
SELECT * FROM country WHERE name = "South Korea";

-- 중간 문자열, like 연산자 검색
-- %문자열 : 문자열로 끝나는 모든 데이터
SELECT * FROM country WHERE name LIKE '%Korea';

-- 문자열% : 문자열로 시작하는 모든 데이터
SELECT * FROM country WHERE name LIKE 'Korea%';

-- %문자열% : 문자열을 포함하고 있는 모든 데이터
SELECT * FROM country WHERE name LIKE '%Korea%'
ORDER BY code;

-- %문자열% 표기 방식이 변환 과정에서 문제가 생길 수 있으므로 CONCAT 함수 이용
SELECT * FROM country WHERE name LIKE CONCAT('%', 'Korea', '%') ORDER BY code;
