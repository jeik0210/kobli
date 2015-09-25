INSERT INTO subscription_numberpatterns
    (label, displayorder, description, numberingmethod,
    label1, add1, every1, whenmorethan1, setto1, numbering1,
    label2, add2, every2, whenmorethan2, setto2, numbering2,
    label3, add3, every3, whenmorethan3, setto3, numbering3)
VALUES
    ('N�mero', 1, 'M�todo simple de numeraci�n', 'No.{X}',
    'N�mero', 1, 1, 99999, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL),

    ('Volumen, N�mero, Ejemplar', 2, 'Volumen N�mero Ejemplar 1', 'Vol.{X}, N�mero {Y}, Ejemplar {Z}',
    'Volumen', 1, 48, 99999, 1, NULL,
    'N�mero', 1, 4, 12, 1, NULL,
    'Ejemplar', 1, 1, 4, 1, NULL),

    ('Volumen, N�mero', 3, 'Volumen N�mero 1', 'Vol {X}, No {Y}',
    'Volumen', 1, 12, 99999, 1, NULL,
    'N�mero', 1, 1, 12, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL),

    ('Estacional', 4, 'Estaci�n del a�o', '{X} {Y}',
    'Estaci�n', 1, 1, 3, 0, 'estaci�n',
    'A�o', 1, 4, 99999, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL);
