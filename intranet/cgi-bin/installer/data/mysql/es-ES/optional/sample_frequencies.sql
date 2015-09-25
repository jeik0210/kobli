INSERT INTO subscription_frequencies
    (description, unit, unitsperissue, issuesperunit, displayorder)
VALUES
    ('2/d�a', 'd�a', 1, 2, 1),
    ('1/d�a', 'd�a', 1, 1, 2),
    ('3/semana', 'semana', 1, 3, 3),
    ('1/semana', 'semana', 1, 1, 4),
    ('1/2 semanas', 'semana', 2, 1, 5),
    ('1/3 semanas', 'semana', 3, 1, 6),
    ('1/mes', 'mes', 1, 1, 7),
    ('1/2 meses', 'mes', 2, 1, 8),
    ('1/3 meses', 'mes', 3, 1, 9),
    ('2/a�o', 'mes', 6, 1, 10),
    ('1/a�o', 'a�o', 1, 1, 11),
    ('1/2 a�o', 'a�o', 2, 1, 12),
    ('Irregular', NULL, 1, 1, 13);
