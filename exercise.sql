-- Kreiranje tablice 'odjel'
CREATE TABLE odjel (
                       sifra INT PRIMARY KEY,
                       naziv VARCHAR(45) NOT NULL
);

-- Kreiranje tablice 'projekt'
CREATE TABLE projekt (
                         sifra INT PRIMARY KEY,
                         naziv VARCHAR(45) NOT NULL,
                         datumpocetka DATETIME NOT NULL,
                         datumkraja DATETIME
);

-- Kreiranje tablice 'zaposlenik'
CREATE TABLE zaposlenik (
                            sifra INT PRIMARY KEY,
                            nadredeni INT,
                            ime VARCHAR(45) NOT NULL,
                            prezime VARCHAR(45) NOT NULL,
                            datumrodenja DATETIME NOT NULL,
                            placa DECIMAL(18,2) NOT NULL,
                            odjel INT,
                            FOREIGN KEY (odjel) REFERENCES odjel(sifra)
);

-- Kreiranje tablice 'sudjeluje'
CREATE TABLE sudjeluje (
                           zaposlenik INT,
                           projekt INT,
                           datumpristupanja DATETIME NOT NULL,
                           PRIMARY KEY (zaposlenik, projekt),
                           FOREIGN KEY (zaposlenik) REFERENCES zaposlenik(sifra),
                           FOREIGN KEY (projekt) REFERENCES projekt(sifra)
);

-- Ažurirajte plaću zaposlenika za one koji su na projektu "MIPRO II" i počeli raditi u prosincu 2023
UPDATE zaposlenik
SET placa = placa - 100
    FROM zaposlenik z
JOIN sudjeluje s ON z.sifra = s.zaposlenik
    JOIN projekt p ON s.projekt = p.sifra
WHERE p.naziv = 'MIPRO II'
  AND s.datumpristupanja >= '2023-12-01'
  AND s.datumpristupanja < '2024-01-01';


-- Briši sve unose u tablici 'sudjeluje' koji se odnose na projekt 'HETA I'
DELETE FROM sudjeluje
WHERE projekt IN (
    SELECT sifra
    FROM projekt
    WHERE naziv = 'HETA I'
);

-- Briši projekt iz tablice 'projekt' s nazivom 'HETA I'
DELETE FROM projekt
WHERE naziv = 'HETA I';

-- Izlistajte jedinstvene nazive projekata na kojima su sudjelovali zaposlenici iz odjela 'Tajništvo'
SELECT DISTINCT p.naziv
FROM projekt p
         JOIN sudjeluje s ON p.sifra = s.projekt
         JOIN zaposlenik z ON s.zaposlenik = z.sifra
         JOIN odjel o ON z.odjel = o.sifra
WHERE o.naziv = 'Tajništvo';

-- Drugi dio ispita, MySQL / MariaDB --

CREATE FUNCTION GetFirstThreeChars(param1 VARCHAR(255), param2 VARCHAR(255))
    RETURNS VARCHAR(6)
    DETERMINISTIC
BEGIN
    DECLARE firstThreeParam1 VARCHAR(3);
    DECLARE firstThreeParam2 VARCHAR(3);

    -- Ekstrakt prvih 3 slova iz parametra 1
    SET firstThreeParam1 = LEFT(param1, 3);

    -- Ekstrakt prvih 3 slova iz parametra 2
    SET firstThreeParam2 = LEFT(param2, 3);

    -- Vratiti spojene rezultate
RETURN CONCAT(firstThreeParam1, firstThreeParam2);
END //

    -- Pozivanje funkcije --
SELECT GetFirstThreeChars('Hello', 'World');

CREATE TABLE odjel_log (
                           log_id INT AUTO_INCREMENT PRIMARY KEY,
                           sifra INT,
                           naziv VARCHAR(45),
                           datum_unosa DATETIME DEFAULT CURRENT_TIMESTAMP,
                           akcija VARCHAR(50)
);

CREATE TRIGGER after_odjel_insert
    AFTER INSERT ON odjel
    FOR EACH ROW
BEGIN
    INSERT INTO odjel_log (sifra, naziv, akcija)
    VALUES (NEW.sifra, NEW.naziv, 'Unos');
END //

-- Umetanje novog reda u tablicu 'odjel'
INSERT INTO odjel (sifra, naziv) VALUES (1, 'HR');

-- Provjera tablice 'odjel_log' da biste vidjeli je li okidač radio
SELECT * FROM odjel_log;

CREATE PROCEDURE DeleteEmployeesByProject(IN project_id INT)
BEGIN
    -- Obriši sve unose u tablici 'sudjeluje' za navedeni projekt
DELETE FROM sudjeluje
WHERE projekt = project_id;

END //

    CALL DeleteEmployeesByProject(1);