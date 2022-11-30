-- 여기는 주석문
-- 여기는 root 로 접속한 화면입니다
-- SELECT : DB Server에 뭔가 요청하는 명령 키워드
SELECT 30+40;
SELECT '대한민국만세';
-- || : Oracle 에서 문자열 연결, '대한민국' || '만세'
SELECT CONCAT('대한민국', '만세');

-- world SCHEMA 를 open 하기
-- SCHEMA = DATABASE
USE world; -- 1. DB를 open 하고

SELECT * 
FROM city; -- 2. city table 에서 데이터를 SELECT(선택)하여 보여주기

-- WHERE 조건절에 조건을 부여하여 필요한 데이터만 제한적으로 SELECT 하기
SELECT * 
FROM city 
WHERE District = 'Noord-Holland';

SELECT *
FROM city
WHERE Name = 'Alkmaar';

-- Selection 조회
-- 데이터 개수를 축소하여 필요한 데이터들만 보기
SELECT *
FROM city
WHERE Name = 'Herat';

-- Projection 조회
-- 데이터의 항목을 축소하여 필요한 항목(칼럼)들만 보기
SELECT Name, Population
FROM city;

-- Selection 과 Projection 을 동시에 적용하기
SELECT district, population
FROM city
WHERE name = 'Herat';

-- district 칼럼에 저장된 데이터를 한 묶음으로 묶고
-- 묶음에 포함된 데이터들의 개수를 세어서 보여주기
SELECT district, count(district)
FROM city
GROUP BY district;

-- 성적테이블에서 각 과목의 총점과 평균을 계산하여 보여주기
SELECT 과목, SUM(점수), AVG(점수)
FROM 성적테이블
GROUP BY 과목;

-- 학생별 총점과 평균 계산하여 보여주기
SELECT 학번, 이름, SUM(점수), AVG(점수)
FROM 성적테이블
GROUP BY 학번, 이름;

SELECT 학번, 이름, SUM(점수), AVG(점수)
FROM 성적테이블
GROUP BY 학번, 이름
ORDER BY 학번;

/*
city table 에서 인구(population)가 1만 이상인 도시들만
찾으시오
*/

SELECT *
FROM city
WHERE Population >= 10000;

/*
city table 에서 인구가 1만 이상인 도시들을 
인구가 많은 순서대로 조회하기
*/

SELECT *
FROM city
WHERE Population >= 10000
ORDER BY Population DESC;

/*
city table 에서 인구가 1만 이상 5만 이하인 도시들의 인구 평균을 구하시오
*/ 

-- cf) GROUP BY Name을 쓸 경우, 각 도시의 인구 평균을 구한다는 의미이므로
-- 각 도시별 인구 수가 그대로 나오게 되는 실수 발생
SELECT AVG(Population)
FROM city
WHERE Population >= 10000 AND Population <= 50000;

SELECT AVG(Population)
FROM city
WHERE Population BETWEEN 10000 AND 50000;

/*
city table 에서 인구가 1만 이상 5만 이하인 도시들의
국가별(countryCode) 인구 평균을 구하고 국가별로 정렬
-- 통계(count(), sum(), avg(), max(), min())와 관련된 SQL은
	반드시 projection 을 수행하여 칼럼을 제한해야 한다(SELECT * 사용 불가).
    projection 칼럼 중에 통계함수로 묶이지 않은 칼럼은
    반드시 GROUP BY 절에서 명시해 주어야 한다.
*/

SELECT CountryCode, AVG(population)
FROM city
WHERE Population >= 10000 AND Population <= 50000
GROUP BY CountryCode
ORDER BY CountryCode;

-- 범위를 부여하는 조건절에서
-- ~~이상 AND ~~이하의 조건일 때
SELECT CountryCode, AVG(population)
FROM city
WHERE population BETWEEN 10000 AND 50000
GROUP BY CountryCode
ORDER BY CountryCode;

/*
city table 에서
각 국가별 인구평균을 계산하고
인구 평균이 5만 이상인 국가만 조회

먼저 국가별 인구 평균을 계산하고
계산된 인구 평균이 5만 이상인 경우
AVG() 함수로 계산한 결과에 조건을 부여하기 때문에
이러한 경우는 WHERE 가 아니고,
HAVING 절을 GROUP BY 다음에 둔다
*/

SELECT CountryCode, AVG(population) AS 평균
FROM city
GROUP BY CountryCode
HAVING AVG(population) >= 50000;

/*
각 국가별로(그룹을 묶어서) 가장 인구가 많은 도시는?
MAX() 함수는 각 그룹에서 최대 값을 찾는 함수이다.
	이 함수를 사용할 때 한 개의 칼럼(name, 도시명)을 GROUP BY로 묶지 않고
	코드를 실행하면 인구가 가장 많은 도시의 이름을 알 수 있다.
*/

SELECT CountryCode AS 국가, Name AS 도시, MAX(population) AS 인구수
FROM city
GROUP BY CountryCode
ORDER BY MAX(population) DESC;

/*
country table 에서
각 국가별 GNP 값이 큰 국가부터 리스트를 조회
단, GNP가 1000 이상인 국가이름과 GNP 값
*/

SELECT * FROM country;

SELECT Name, GNP
FROM country
GROUP BY Name
HAVING GNP >= 1000
ORDER BY MAX(GNP) DESC;

/*
city table(국가 이름 없음) 과 country table 을 참조하여
인구가 1만 이상 5만 이하인 도시의 국가 이름이 무엇인가 조회
TABLE JOIN 사용
*/

-- cf) INNER JOIN 은 데이터의 교집합을 출력하므로 
-- 외래키가 없을 경우 값이 누락될 가능성이 있다
-- 따라서 LEFT JOIN 을 사용하는 것이 바람직하다

SELECT * FROM city;
SELECT * FROM country;

SELECT country.Name, city.population
FROM country
-- INNER JOIN city
LEFT JOIN city
ON country.Code = city.CountryCode
WHERE city.population BETWEEN 10000 AND 50000;

/*
SELECT [PREDICATE] [테이블명.] 속성명 [AS 별칭] [, [테이블명.]속성명, ...]
[, 그룹함수(속성명) [AS 별칭]]
[, Window함수 OVER (PARTITION BY 속성명1, 속성명2, ...
					ORDER BY 속성명3, 속성명4, ...)]
FROM 테이블명[, 테이블명, ...]
[WHERE 조건]
[GROUP BY 속성명, 속성명, ...]
[HAVING 조건]
[ORDER BY 속성명 [ASC | DESC]];

SELECT절 :
	- PREDICATE : 불러올 튜플 수를 제한할 명령어 기술
		* ALL : 모든 튜플을 검색할 때 지정. 주로 생략
		* DISTINCT : 중복된 튜플이 있으면 그 중 첫 번째 한 개만 검색
		* DISTINCTROW : 중복된 튜플을 제거하고 한 개만 검색하지만 
						선택된 속성의 값이 아닌, 튜플 전체를 대상으로 함
    - 속성명 : 검색하여 불러울 속성(열) 또는 속성을 이용한 수식 지정
		* 기본 테이블을 구성하는 모든 속성을 지정할 때 '*'를 기술
        * 두 개 이상의 테이블을 대상으로 검색할 때 '테이블명.속성명'으로 표현
	- AS : 속성 및 연산의 이름을 다른 제목으로 표시하기 위해 사용
FROM절 : 질의에 의해 검색될 데이터들을 포함하는 테이블명 기술
WHERE절 : 검색할 조건 기술(테이블의 모든 데이터에 대한 조건)
ORDER BY절 : 특정 속성을 기준으로 정렬하여 검색
	- 속성명 : 정렬의 기준이 되는 속성명 기술
	- [ASC | DESC] : 정렬 방식. 'ASC'는 오름차순, 'DESC'는 내림차순. 생략하면 오름차순 지정
그룹함수 : GROUP BY절에 지정된 그룹별로 속성의 값을 집계할 함수 기술
	COUNT / SUM / AVG / MAX / MIN / STDDEV 표준편차 / VARIANCE 분산 / 
	ROLLUP 그룹별 소계. 하위레벨에서 상위레벨 / CUBE 그룹별 소계. 상위레벨에서 하위레벨
WINDOW함수 : GROUP BY절을 이용하지 않고 속성의 값을 집계할 함수 기술. 인수로 지정한 속성이 대상 레코드의 범위(WINDOW)
	ROW_NUMBER() 일련번호 / RANK() 공동순위 반영 / DENSE_RANK() 공동순위 무시 
	- PARTITION BY : WINDOW 함수가 적용될 범위로 사용할 속성 지정
	- ORDER BY : PARTITION 안에서 정렬 기준으로 사용할 속성 지정
GROUP BY절 : 특정 속성을 기준으로 그룹화하여 검색. 일반적으로 그룹함수와 함께 사용
HAVING절 : GROUP BY와 함께 사용. 그룹에 대한 조건 지정(GROUP BY로 그룹화된 새로운 테이블에 대한 조건)
		   HAVING절에 사용된 속성(컬럼)은 반드시 SELECT절에 기술되어야 함
*/

/*
JOIN
2개의 테이블에 대해 연관된 튜플들을 결합하여 하나의 새로운 릴레이션 반환
- INNER JOIN
조건 없는 INNER JOIN 은 CROSS JOIN(교차조인) 과 동일한 결과
	- EQUI JOIN : 공통 속성 기준으로 =(equal) 비교에 의해 같은 값을 가지는 행을 연결하는 방법
				이 때 중복 속성을 제거하여 같은 속성을 한 번만 표기하는 방법을 NATURAL JOIN(자연조인)
                * WHERE절
				SELECT [테이블명1.]속성명, [테이블명2.]속성명, ...
				FROM 테이블명1, 테이블명2, ...
                WHERE 테이블명1.속성명 = 테이블명2.속성명;
                * NATURAL JOIN절
                SELECT [테이블1.]속성명, [테이블명2.]속성명, ...
                FROM 테이블명1 NATURAL JOIN 테이블명2;
                * JOIN ~ USING절 (속성명이 같을 때만 사용)
                SELECT [테이블명1.]속성명, [테이블명2.]속성명, ...
                FROM 테이블명1 JOIN 테이블명2 USING(속성명);
    - NON-EQUL JOIN : = 조건이 아닌 <, <>, >=, <= 비교 연산자를 사용하는 방법
				SELECT [테이블명1.]속성명, [테이블명2.]속성명, ...
				FROM 테이블명1, 테이블명2,
				WHERE (NON-EQUL JOIN 조건);
- OUTER JOIN
릴레이션에서 JOIN 조건에 만족하지 않는 튜플도 결과로 출력하기 위한 방법
	- LEFT OUTER JOIN : INNER JOIN 의 결과를 구한 후, 우측 항 릴레이션 튜플과 맞지 않는 좌측 항 릴레이션 튜플에 NULL 값을 붙여서 추가
						1.
						SELECT [테이블명1.]속성명, [테이블명2.]속성명, ...
                        FROM 테이블명1 LEFT OUTER JOIN 테이블명2
						ON 테이블명1.속성명 = 테이블명2.속성명;
                        2.
						SELECT [테이블명1.]속성명, [테이블명2.]속성명 ...
						FROM 테이블명1, 테이블명2
						WHERE 테이블명1.속성명 = 테이블명2.속성명(+);
    - RIGHT OUTER JOIN : INNER JOIN 의 결과를 구한 후, 좌측 항 릴레이션 튜플과 맞지 않는 우측 항 릴레이션 튜플에 NULL 값을 붙여서 추가 
						1.
                        SELECT [테이블명1.]속성명, [테이블명2.]속성명, ...
						FROM 테이블명1 RIGHT OUTER JOIN 테이블명2
                        ON 테이블명1.속성명 = 테이블명2.속성명;
                        2.
                        SELECT [테이블명1.]속성명, [테이블명2.]속성명, ...
                        FROM 테이블명1, 테이블명2
                        WHERE 테이블명1.속성명(+) = 테이블명2.속성명;
    - FULL OUTER JOIN : INNER JOIN 의 결과를 구한 후, 좌/우측 항 릴레이션 튜플과 맞지 않는 우/좌측 항 릴레이션 튜플에 NULL 값을 붙여서 추가
						SELECT [테이블명1.]속성명, [테이블명2.]속성명, ...
                        FROM 테이블명1 FULL OUTER JOIN 테이블명2
                        ON 테이블명1.속성명 = 테이블명2.속성명;
- SELF JOIN : 
같은 테이블에서 2개의 속성을 연결하여 EQUI JOIN 을 하는 방법
						1. 
						SELECT [별칭1.]속성명, [별칭1.]속성명, ...
						FROM 테이블명1 [AS] 별칭1 JOIN 테이블명1 [AS] 별칭2
						ON 별칭1.속성명 = 별칭2.속성명;
						2.
						SELECT [별칭1.]속성명, [별칭1.]속성명, ...
						FROM 테이블명1 [AS] 별칭1, 테이블명1 [AS] 별칭2
						WHERE 별칭1.속성명 = 별칭2.속성명;
*/