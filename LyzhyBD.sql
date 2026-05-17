USE master;
GO
DROP DATABASE IF EXISTS SkiResortGraph;
GO
CREATE DATABASE SkiResortGraph;
GO
USE SkiResortGraph;
GO

CREATE TABLE Instructor (
    id INT PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
) AS NODE;

CREATE TABLE Trail (
    id INT PRIMARY KEY,
    name NVARCHAR(50) NOT NULL,
    difficulty INT NOT NULL -- Оценка сложности от 1 до 5
) AS NODE;

CREATE TABLE Lift (
    id INT PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
) AS NODE;


CREATE TABLE TeachesOn (
    work_shift NVARCHAR(20) NOT NULL -- Смена: Утро, Вечер
) AS EDGE;

CREATE TABLE LeadsTo (
    travel_time_mins INT NOT NULL -- Время подъема в минутах
) AS EDGE;

CREATE TABLE ConnectedWith (
    difficulty_diff INT NOT NULL -- Разница в сложности между трассами
) AS EDGE;

ALTER TABLE TeachesOn ADD CONSTRAINT EC_TeachesOn CONNECTION (Instructor TO Trail);
ALTER TABLE LeadsTo ADD CONSTRAINT EC_LeadsTo CONNECTION (Lift TO Trail);
ALTER TABLE ConnectedWith ADD CONSTRAINT EC_ConnectedWith CONNECTION (Trail TO Trail);
GO


INSERT INTO Instructor (id, name) VALUES
(1, N'Иван'), (2, N'Пётр'), (3, N'Сергей'), (4, N'Анна'), (5, N'Мария'),
(6, N'Дмитрий'), (7, N'Елена'), (8, N'Михаил'), (9, N'Ольга'), (10, N'Алексей');

INSERT INTO Trail (id, name, difficulty) VALUES
(1, N'Трасса №1', 1), 
(2, N'Трасса №2', 2), 
(3, N'Трасса №3', 2), 
(4, N'Трасса №4', 3), 
(5, N'Трасса №5', 4),
(6, N'Трасса №6', 5), 
(7, N'Трасса №7', 4), 
(8, N'Трасса №8', 3), 
(9, N'Трасса №9', 2), 
(10, N'Трасса №10', 1);

INSERT INTO Lift (id, name) VALUES
(1, N'Подъемник №1'), (2, N'Подъемник №2'), (3, N'Подъемник №3'), (4, N'Подъемник №4'), (5, N'Подъемник №5'),
(6, N'Подъемник №6'), (7, N'Подъемник №7'), (8, N'Подъемник №8'), (9, N'Подъемник №9'), (10, N'Подъемник №10');
GO


INSERT INTO TeachesOn ($from_id, $to_id, work_shift) VALUES
((SELECT $node_id FROM Instructor WHERE id = 1), (SELECT $node_id FROM Trail WHERE id = 1), N'Утро'),
((SELECT $node_id FROM Instructor WHERE id = 1), (SELECT $node_id FROM Trail WHERE id = 2), N'Вечер'), -- Иван на двух трассах
((SELECT $node_id FROM Instructor WHERE id = 2), (SELECT $node_id FROM Trail WHERE id = 1), N'Вечер'), -- Пётр тоже на 1-й трассе
((SELECT $node_id FROM Instructor WHERE id = 3), (SELECT $node_id FROM Trail WHERE id = 2), N'Утро'),
((SELECT $node_id FROM Instructor WHERE id = 4), (SELECT $node_id FROM Trail WHERE id = 3), N'Вечер'),
((SELECT $node_id FROM Instructor WHERE id = 5), (SELECT $node_id FROM Trail WHERE id = 4), N'Утро'),
((SELECT $node_id FROM Instructor WHERE id = 6), (SELECT $node_id FROM Trail WHERE id = 5), N'Вечер'),
((SELECT $node_id FROM Instructor WHERE id = 7), (SELECT $node_id FROM Trail WHERE id = 6), N'Утро'),
((SELECT $node_id FROM Instructor WHERE id = 8), (SELECT $node_id FROM Trail WHERE id = 7), N'Вечер'),
((SELECT $node_id FROM Instructor WHERE id = 9), (SELECT $node_id FROM Trail WHERE id = 8), N'Утро'),
((SELECT $node_id FROM Instructor WHERE id = 10), (SELECT $node_id FROM Trail WHERE id = 9), N'Вечер');


INSERT INTO LeadsTo ($from_id, $to_id, travel_time_mins) VALUES
((SELECT $node_id FROM Lift WHERE id = 1), (SELECT $node_id FROM Trail WHERE id = 1), 5),
((SELECT $node_id FROM Lift WHERE id = 1), (SELECT $node_id FROM Trail WHERE id = 2), 7), 
((SELECT $node_id FROM Lift WHERE id = 2), (SELECT $node_id FROM Trail WHERE id = 2), 6),
((SELECT $node_id FROM Lift WHERE id = 3), (SELECT $node_id FROM Trail WHERE id = 3), 8),
((SELECT $node_id FROM Lift WHERE id = 3), (SELECT $node_id FROM Trail WHERE id = 4), 9),  
((SELECT $node_id FROM Lift WHERE id = 4), (SELECT $node_id FROM Trail WHERE id = 5), 10),
((SELECT $node_id FROM Lift WHERE id = 5), (SELECT $node_id FROM Trail WHERE id = 6), 12),
((SELECT $node_id FROM Lift WHERE id = 6), (SELECT $node_id FROM Trail WHERE id = 7), 11),
((SELECT $node_id FROM Lift WHERE id = 7), (SELECT $node_id FROM Trail WHERE id = 8), 9),
((SELECT $node_id FROM Lift WHERE id = 8), (SELECT $node_id FROM Trail WHERE id = 9), 7);
INSERT INTO LeadsTo ($from_id, $to_id, travel_time_mins) VALUES 
((SELECT $node_id FROM Lift WHERE id = 9), (SELECT $node_id FROM Trail WHERE id = 10), 6),
((SELECT $node_id FROM Lift WHERE id = 10), (SELECT $node_id FROM Trail WHERE id = 10), 5);

INSERT INTO ConnectedWith ($from_id, $to_id, difficulty_diff) VALUES
((SELECT $node_id FROM Trail WHERE id = 1), (SELECT $node_id FROM Trail WHERE id = 2), 1),   
((SELECT $node_id FROM Trail WHERE id = 1), (SELECT $node_id FROM Trail WHERE id = 3), 1),   
((SELECT $node_id FROM Trail WHERE id = 2), (SELECT $node_id FROM Trail WHERE id = 4), 1),   
((SELECT $node_id FROM Trail WHERE id = 3), (SELECT $node_id FROM Trail WHERE id = 5), 2),   
((SELECT $node_id FROM Trail WHERE id = 4), (SELECT $node_id FROM Trail WHERE id = 6), 1),   
((SELECT $node_id FROM Trail WHERE id = 5), (SELECT $node_id FROM Trail WHERE id = 6), 0),   
((SELECT $node_id FROM Trail WHERE id = 6), (SELECT $node_id FROM Trail WHERE id = 7), -1),  
((SELECT $node_id FROM Trail WHERE id = 7), (SELECT $node_id FROM Trail WHERE id = 8), -1),  
((SELECT $node_id FROM Trail WHERE id = 8), (SELECT $node_id FROM Trail WHERE id = 9), -1),  
((SELECT $node_id FROM Trail WHERE id = 9), (SELECT $node_id FROM Trail WHERE id = 10), -1); 
GO

-- Запрос 1: Цепочка «Подъемник -> Трасса -> Трасса»
SELECT L.name AS LiftName, T1.name AS FirstTrail, T1.difficulty AS Difficulty1, T2.name AS NextTrail, T2.difficulty AS Difficulty2
FROM Lift AS L, LeadsTo AS LT, Trail AS T1, ConnectedWith AS CW, Trail AS T2
WHERE MATCH(L-(LT)->T1-(CW)->T2)
  AND L.name = N'Подъемник №1';

-- Запрос 2: «Инструктор -> Трасса <- Подъемник»
SELECT I.name AS InstructorName, T.name AS TrailName, T.difficulty AS Difficulty, L.name AS LiftName
FROM Instructor AS I, TeachesOn AS TO_R, Trail AS T, LeadsTo AS LT, Lift AS L
WHERE MATCH(I-(TO_R)->T<-(LT)-L)
  AND I.name = N'Иван';

-- Запрос 3: «Подъемник -> Трасса -> Трасса -> Трасса»
SELECT L.name AS LiftName, T1.name AS Trail1, T2.name AS Trail2, T3.name AS Trail3
FROM Lift AS L, LeadsTo AS LT, Trail AS T1, ConnectedWith AS CW1, Trail AS T2, ConnectedWith AS CW2, Trail AS T3
WHERE MATCH(L-(LT)->T1-(CW1)->T2-(CW2)->T3);

-- Запрос 4: «Инструктор 1 -> Трасса <- Инструктор 2»
SELECT I1.name AS Instructor1, T.name AS SharedTrail, T.difficulty AS Difficulty, I2.name AS Instructor2
FROM Instructor AS I1, TeachesOn AS TO1, Trail AS T, TeachesOn AS TO2, Instructor AS I2
WHERE MATCH(I1-(TO1)->T<-(TO2)-I2)
  AND I1.id < I2.id;

-- Запрос 5:«Инструктор -> Трасса -> Трасса <- Подъемник»
SELECT I.name AS Instructor, T1.name AS Trail1, T2.name AS Trail2, L.name AS Lift
FROM Instructor AS I, TeachesOn AS TO_R, Trail AS T1, ConnectedWith AS CW, Trail AS T2, LeadsTo AS LT, Lift AS L
WHERE MATCH(I-(TO_R)->T1-(CW)->T2<-(LT)-L)
  AND I.name = N'Пётр';
GO

-- 6. SHORTEST_PATH

-- Запрос 1: Шаблон "+" (Путь по трассам от Трассы №1 до Трассы №3)
WITH T1 AS (
    SELECT TrailStart.name AS StartTrail,
           STRING_AGG(TrailNext.name, ' -> ') WITHIN GROUP (GRAPH PATH) AS FullRoute,
           LAST_VALUE(TrailNext.name) WITHIN GROUP (GRAPH PATH) AS LastTrail
    FROM Trail AS TrailStart,
         ConnectedWith FOR PATH AS cw,
         Trail FOR PATH AS TrailNext
    WHERE MATCH(SHORTEST_PATH(TrailStart(-(cw)->TrailNext)+))
      AND TrailStart.name = N'Трасса №1'
)
SELECT StartTrail, FullRoute 
FROM T1 
WHERE LastTrail = N'Трасса №3';

-- Запрос 2:"{1,n}" (Путь от 1 до 5 переходов от Трассы №1 до Трассы №5)
WITH T2 AS (
    SELECT TrailStart.name AS StartTrail,
           STRING_AGG(TrailNext.name, ' -> ') WITHIN GROUP (GRAPH PATH) AS FullRoute,
           LAST_VALUE(TrailNext.name) WITHIN GROUP (GRAPH PATH) AS LastTrail
    FROM Trail AS TrailStart,
         ConnectedWith FOR PATH AS cw,
         Trail FOR PATH AS TrailNext
    WHERE MATCH(SHORTEST_PATH(TrailStart(-(cw)->TrailNext){1,5}))
      AND TrailStart.name = N'Трасса №1'
)
SELECT StartTrail, FullRoute 
FROM T2 
WHERE LastTrail = N'Трасса №6';
GO