-- drop indexes
DROP INDEX idx_vytisk_vydani_titul;
DROP INDEX idx_zanr_nazev;
-- drop sequences
DROP SEQUENCE pokuta_seq;
DROP SEQUENCE rezervace_seq;
DROP SEQUENCE vypujcka_seq;
DROP SEQUENCE ctenar_seq;
DROP SEQUENCE zamestnanec_seq;
DROP SEQUENCE vytisk_seq;
DROP SEQUENCE titul_seq;
DROP SEQUENCE zanr_seq;
DROP SEQUENCE autor_seq;
DROP SEQUENCE update_logs_seq;

-- drop tables
DROP TABLE pokuta CASCADE CONSTRAINTS;
DROP TABLE rezervace CASCADE CONSTRAINTS;
DROP TABLE vypujcka CASCADE CONSTRAINTS;
DROP TABLE ctenar CASCADE CONSTRAINTS;
DROP TABLE zamestnanec CASCADE CONSTRAINTS;
DROP TABLE casopis CASCADE CONSTRAINTS;
DROP TABLE kniha CASCADE CONSTRAINTS;
DROP TABLE vytisk CASCADE CONSTRAINTS;
DROP TABLE AutorTitul CASCADE CONSTRAINTS;
DROP TABLE TitulZanr CASCADE CONSTRAINTS;
DROP TABLE titul CASCADE CONSTRAINTS;
DROP TABLE AutorZanr CASCADE CONSTRAINTS;
DROP TABLE zanr CASCADE CONSTRAINTS;
DROP TABLE autor CASCADE CONSTRAINTS;
DROP TABLE update_logs CASCADE CONSTRAINTS;


-- sequences for generating primary keys
CREATE SEQUENCE update_logs_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE autor_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE titul_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE vytisk_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE zanr_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE zamestnanec_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE ctenar_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE vypujcka_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE rezervace_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE pokuta_seq START WITH 1 INCREMENT BY 1;

-- table for table updates
CREATE TABLE update_logs (
    id_logu         int NOT NULL,
    table_name      nvarchar2(255) NOT NULL,
    operation_type  nvarchar2(255) NOT NULL,
    old_value       nvarchar2(255) NOT NULL,
    new_value       nvarchar2(255) NOT NULL,
    change_date     DATE NOT NULL,
    CONSTRAINT pk_log PRIMARY KEY (id_logu)
);

-- -- trigger for update_logs table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_update_logs_id
BEFORE INSERT ON update_logs
FOR EACH ROW
BEGIN
    :new.id_logu := update_logs_seq.NEXTVAL;
END;
/

-- table autor
CREATE TABLE autor (
    id_autora int NOT NULL,
    jmeno nvarchar2(255) NOT NULL,
    prijmeni nvarchar2(255) NOT NULL,
    datum_narozeni DATE NOT NULL,
    datum_umrti DATE,
    jazyk nvarchar2(255) NOT NULL,
    CONSTRAINT pk_autor PRIMARY KEY (id_autora)
);

-- trigger for autor table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_autor_id
BEFORE INSERT ON autor
FOR EACH ROW
BEGIN
    :new.id_autora := autor_seq.NEXTVAL;
END;
/

-- table zanr
CREATE TABLE zanr (
    id_zanru int NOT NULL,
    nazev nvarchar2(255) NOT NULL,
    CONSTRAINT pk_zanr PRIMARY KEY (id_zanru)
);

-- table AutorZanr to represent N to N relationship
CREATE TABLE AutorZanr (
    autor int NOT NULL REFERENCES autor(id_autora),
    zanr int NOT NULL REFERENCES zanr(id_zanru),
    PRIMARY KEY (autor, zanr)
);

-- trigger for zanr table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_zanr_id
BEFORE INSERT ON zanr
FOR EACH ROW
BEGIN
    :new.id_zanru := zanr_seq.NEXTVAL;
END;
/

-- table titul
CREATE TABLE titul (
    id_titulu int NOT NULL,
    nazev nvarchar2(255) NOT NULL,
    CONSTRAINT pk_titul PRIMARY KEY (id_titulu)
);

-- trigger for titul table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_titul_id
BEFORE INSERT ON titul
FOR EACH ROW
BEGIN
    :new.id_titulu := titul_seq.NEXTVAL;
END;

-- table TitulZanr to represent N to N relationship
CREATE TABLE TitulZanr (
    titul int NOT NULL REFERENCES titul(id_titulu),
    zanr int NOT NULL REFERENCES zanr(id_zanru),
    PRIMARY KEY (titul, zanr)
);

-- table AutorTitul to represent N to N relationship
CREATE TABLE AutorTitul (
    autor int NOT NULL REFERENCES autor(id_autora),
    titul int NOT NULL REFERENCES titul(id_titulu),
    PRIMARY KEY (autor, titul)
);

-- table vytisk
CREATE TABLE vytisk (
    id_vytisku int NOT NULL,
    vydani nvarchar2(255),
    pocet_stran int,
    cena NUMERIC(10, 2),
    stav nvarchar2(255),
    titul int,
    vytisk_titul int REFERENCES titul(id_titulu),
    CONSTRAINT pk_vytisk PRIMARY KEY (id_vytisku)
);

-- trigger for vytisk table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_vytisk_id
BEFORE INSERT ON vytisk
FOR EACH ROW
BEGIN
    SELECT vytisk_seq.NEXTVAL INTO :new.id_vytisku FROM dual;
END;
/

-- table for kniha
-- Generalizace/specializace: Typ 1.) tabulka pro nadtyp (titul) + pro podtypy (kniha,casopis) s primárním klíčem nadtypu
CREATE TABLE kniha (
    titul int NOT NULL REFERENCES titul(id_titulu),
    isbn nvarchar2(20) NOT NULL CHECK (REGEXP_LIKE(isbn, '^(\d[-\s]?){9}\d(([-\s]?\d){3})?$')),
    CONSTRAINT pk_kniha PRIMARY KEY (titul)
);

-- table for casopis
-- Generalizace/specializace: Typ 1.) tabulka pro nadtyp (titul) + pro podtypy (kniha,casopis) s primárním klíčem nadtypu
CREATE TABLE casopis (
    titul int NOT NULL REFERENCES titul(id_titulu),
    issn nvarchar2(9) NOT NULL CHECK (REGEXP_LIKE(issn, '^[0-9]{4}-[0-9]{4}$')),
    CONSTRAINT pk_casopis PRIMARY KEY (titul)
);

-- table zamestnanec
CREATE TABLE zamestnanec (
    id_zamestnance int NOT NULL,
    jmeno nvarchar2(255) NOT NULL,
    prijmeni nvarchar2(255) NOT NULL,
    ulice nvarchar2(255) NOT NULL,
    mesto nvarchar2(255) NOT NULL,
    psc nvarchar2(20) NOT NULL,
    telefon nvarchar2(20) NOT NULL,
    CONSTRAINT pk_zamestnanec PRIMARY KEY (id_zamestnance)
);

-- trigger for zamestnanec table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_zamestnanec_id
BEFORE INSERT ON zamestnanec
FOR EACH ROW
BEGIN
    :new.id_zamestnance := zamestnanec_seq.NEXTVAL;
END;
/

-- table ctenar
CREATE TABLE ctenar (
    id_prukazu int NOT NULL,
    jmeno nvarchar2(255) NOT NULL,
    prijmeni nvarchar2(255) NOT NULL,
    ulice nvarchar2(255) NOT NULL,
    mesto nvarchar2(255) NOT NULL,
    psc nvarchar2(20) NOT NULL,
    telefon nvarchar2(20) ,
    email nvarchar2(255) UNIQUE,
    platnost_prukazu DATE NOT NULL,
    CONSTRAINT pk_ctenar PRIMARY KEY (id_prukazu)
);

-- trigger for ctenar table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_ctenar_id
BEFORE INSERT ON ctenar
FOR EACH ROW
BEGIN
    :new.id_prukazu := ctenar_seq.NEXTVAL;
END;
/

-- table vypujcka
CREATE TABLE vypujcka (
    id_vypujcky int NOT NULL,
    zamestnanec_vydal int NOT NULL REFERENCES zamestnanec(id_zamestnance) ON DELETE SET NULL,
    zamestnanec_prijal int REFERENCES zamestnanec(id_zamestnance) ON DELETE SET NULL,
    ctenar int REFERENCES ctenar(id_prukazu) ON DELETE CASCADE,
    vytisk int REFERENCES vytisk(id_vytisku),
    datum_vypujceni DATE NOT NULL,
    ocekavane_vraceni DATE NOT NULL,
    datum_vraceni DATE,
    CONSTRAINT pk_vypujcka PRIMARY KEY (id_vypujcky)
);

-- trigger for vypujcka table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_vypujcka_id
BEFORE INSERT ON vypujcka
FOR EACH ROW
BEGIN
    :new.id_vypujcky := vypujcka_seq.NEXTVAL;
END;
/

-- table rezervace
CREATE TABLE rezervace (
    id_rezervace int NOT NULL,
    ctenar int REFERENCES ctenar(id_prukazu) ON DELETE CASCADE,
    titul int REFERENCES titul(id_titulu),
    vypujcka int REFERENCES vypujcka(id_vypujcky),
    datum_rezervace DATE NOT NULL,
    stav nvarchar2(255) NOT NULL,
    CONSTRAINT pk_rezervace PRIMARY KEY (id_rezervace)
);

-- trigger for rezervace table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_rezervace_id
BEFORE INSERT ON rezervace
FOR EACH ROW
BEGIN
    :new.id_rezervace := rezervace_seq.NEXTVAL;
END;
/

-- table pokuta
CREATE TABLE pokuta (
    id_pokuty int NOT NULL,
    vypujcka int REFERENCES vypujcka(id_vypujcky) ON DELETE CASCADE,
    datum_udeleni DATE NOT NULL,
    cena NUMERIC(10, 2) NOT NULL CHECK (cena >= 0),
    stav nvarchar2(255) NOT NULL,
    CONSTRAINT pk_pokuta PRIMARY KEY (id_pokuty)
);

-- trigger for pokuta table to use the sequence for primary key
CREATE OR REPLACE TRIGGER trg_pokuta_id
BEFORE INSERT ON pokuta
FOR EACH ROW
BEGIN
    :new.id_pokuty := pokuta_seq.NEXTVAL;
END;
/

-- NONTRIVIAL TRIGGER1: to log updates in the vytisk table
CREATE OR REPLACE TRIGGER trg_log_vytisk_update
AFTER UPDATE ON vytisk
FOR EACH ROW
BEGIN
    INSERT INTO update_logs(table_name, operation_type, old_value, new_value, change_date)
    VALUES ('vytisk', 'UPDATE', :old.stav, :new.stav, SYSDATE);
END;
/

-- NONTRIVIAL TRIGGER2: to ensure library card is valid before insert on vypujcka
CREATE OR REPLACE TRIGGER trg_platnost_prukazu_pred_vypujckov
BEFORE INSERT ON vypujcka
FOR EACH ROW
DECLARE
    prukaz_platnost DATE;
BEGIN
    -- retrieve expiration date of ctenars library card
    SELECT platnost_prukazu INTO prukaz_platnost
    FROM ctenar
    WHERE id_prukazu = :NEW.ctenar;

    -- check if library card is expired
    IF prukaz_platnost < SYSDATE THEN
        -- error if it is expired
        RAISE_APPLICATION_ERROR(-20000, 'Cannot create loan: Reader''s library card is expired.');
    END IF;
END;
/

--PROCEDURE1: check for overdue loans and update the penalties
CREATE OR REPLACE PROCEDURE update_overdue_penalties IS
    -- cursor to all overdue loans
    CURSOR overdue_loans IS
        SELECT id_vypujcky
        FROM vypujcka
        WHERE datum_vraceni IS NULL AND ocekavane_vraceni < SYSDATE;

    v_loan_id vypujcka.id_vypujcky%TYPE;

BEGIN
    OPEN overdue_loans;
    LOOP
        FETCH overdue_loans INTO v_loan_id;
        EXIT WHEN overdue_loans%NOTFOUND;
        -- update penalty for each overdue loan
        INSERT INTO pokuta (vypujcka, datum_udeleni, cena, stav)
        VALUES (v_loan_id, SYSDATE, 50.00, 'Unpaid');
    END LOOP;
    CLOSE overdue_loans;
EXCEPTION
    WHEN OTHERS THEN
        -- unexpected errors
        DBMS_OUTPUT.put_line('Error occurred: ' || SQLERRM);
END;
/

--PROCEDURE2: insert a new book and link it with author and genre
CREATE OR REPLACE PROCEDURE add_book_author_genre(
    p_nazev NVARCHAR2,
    p_genre_name NVARCHAR2,
    p_author_firstname NVARCHAR2,
    p_author_lastname NVARCHAR2
) IS
    v_titul_id INT;
    v_genre_id INT;
    v_author_id INT;
BEGIN
    -- insert new title
    INSERT INTO titul (nazev)
    VALUES (p_nazev)
    RETURNING id_titulu INTO v_titul_id;

    -- find id_zanru based on genre name
    SELECT id_zanru INTO v_genre_id
    FROM zanr
    WHERE nazev = p_genre_name;

    -- link title to genre
    INSERT INTO TitulZanr (titul, zanr)
    VALUES (v_titul_id, v_genre_id);

    -- find id_autora based on full name
    SELECT id_autora INTO v_author_id
    FROM autor
    WHERE jmeno = p_author_firstname AND prijmeni = p_author_lastname;

    -- link title to author
    INSERT INTO AutorTitul (autor, titul)
    VALUES (v_author_id, v_titul_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Genre or author not found');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'An unexpected error occurred: ' || SQLERRM);
END;
/

-- populate tables with sample data
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, jazyk) VALUES (1, 'J.K.', 'Rowling', TO_DATE('1965-07-31', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (2, 'George', 'Orwell', TO_DATE('1903-06-25', 'YYYY-MM-DD'), TO_DATE('1950-01-21', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (3, 'Charles', 'Dickens', TO_DATE('1812-02-07', 'YYYY-MM-DD'), TO_DATE('1870-06-09', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (4, 'F. Scott', 'Fitzgerald', TO_DATE('1896-09-24', 'YYYY-MM-DD'), TO_DATE('1940-12-21', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (5, 'Gabriel Garcia', 'Marquez', TO_DATE('1927-03-06', 'YYYY-MM-DD'), TO_DATE('2014-04-17', 'YYYY-MM-DD'), 'Spanish');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (6, 'Agatha', 'Christie', TO_DATE('1890-09-15', 'YYYY-MM-DD'), TO_DATE('1976-01-12', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, jazyk) VALUES (7, 'Stephen', 'King', TO_DATE('1947-09-21', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (8, 'Vladimir', 'Nabokov', TO_DATE('1899-04-22', 'YYYY-MM-DD'), TO_DATE('1977-07-02', 'YYYY-MM-DD'), 'Russian');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (9, 'Franz', 'Kafka', TO_DATE('1883-07-03', 'YYYY-MM-DD'), TO_DATE('1924-06-03', 'YYYY-MM-DD'), 'German');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (10, 'Virginia', 'Woolf', TO_DATE('1882-01-25', 'YYYY-MM-DD'), TO_DATE('1941-03-28', 'YYYY-MM-DD'), 'English');

INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (11, 'Virginia', 'Woolf', TO_DATE('1882-01-25', 'YYYY-MM-DD'), TO_DATE('1941-03-28', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (12, 'Virginia', 'Woolf', TO_DATE('1882-01-25', 'YYYY-MM-DD'), TO_DATE('1941-03-28', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (13, 'Virginia', 'Woolf', TO_DATE('1882-01-25', 'YYYY-MM-DD'), TO_DATE('1941-03-28', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (14, 'Virginia', 'Woolf', TO_DATE('1882-01-25', 'YYYY-MM-DD'), TO_DATE('1941-03-28', 'YYYY-MM-DD'), 'English');
INSERT INTO autor (id_autora, jmeno, prijmeni, datum_narozeni, datum_umrti, jazyk) VALUES (15, 'Virginia', 'Woolf', TO_DATE('1882-01-25', 'YYYY-MM-DD'), TO_DATE('1941-03-28', 'YYYY-MM-DD'), 'English');

INSERT INTO zanr (id_zanru, nazev) VALUES (1, 'Fantasy');
INSERT INTO zanr (id_zanru, nazev) VALUES (2, 'Science Fiction');
INSERT INTO zanr (id_zanru, nazev) VALUES (3, 'Historical');
INSERT INTO zanr (id_zanru, nazev) VALUES (4, 'Biography');
INSERT INTO zanr (id_zanru, nazev) VALUES (5, 'Mystery');
INSERT INTO zanr (id_zanru, nazev) VALUES (6, 'Romance');
INSERT INTO zanr (id_zanru, nazev) VALUES (7, 'Thriller');
INSERT INTO zanr (id_zanru, nazev) VALUES (8, 'Non-fiction');
INSERT INTO zanr (id_zanru, nazev) VALUES (9, 'Horror');
INSERT INTO zanr (id_zanru, nazev) VALUES (10, 'Short story');
INSERT INTO zanr (id_zanru, nazev) VALUES (11, 'Drama');
INSERT INTO zanr (id_zanru, nazev) VALUES (12, 'Comedy');

INSERT INTO AutorZanr (autor, zanr) VALUES (1, 1);
INSERT INTO AutorZanr (autor, zanr) VALUES (1, 11);
INSERT INTO AutorZanr (autor, zanr) VALUES (2, 2);
INSERT INTO AutorZanr (autor, zanr) VALUES (2, 6);
INSERT INTO AutorZanr (autor, zanr) VALUES (3, 10);
INSERT INTO AutorZanr (autor, zanr) VALUES (3, 11);
INSERT INTO AutorZanr (autor, zanr) VALUES (4, 10);
INSERT INTO AutorZanr (autor, zanr) VALUES (5, 4);
INSERT INTO AutorZanr (autor, zanr) VALUES (5, 10);
INSERT INTO AutorZanr (autor, zanr) VALUES (6, 10);
INSERT INTO AutorZanr (autor, zanr) VALUES (6, 7);
INSERT INTO AutorZanr (autor, zanr) VALUES (7, 9);
INSERT INTO AutorZanr (autor, zanr) VALUES (7, 1);
INSERT INTO AutorZanr (autor, zanr) VALUES (7, 2);
INSERT INTO AutorZanr (autor, zanr) VALUES (7, 11);
INSERT INTO AutorZanr (autor, zanr) VALUES (8, 10);
INSERT INTO AutorZanr (autor, zanr) VALUES (8, 8);
INSERT INTO AutorZanr (autor, zanr) VALUES (9, 10);
INSERT INTO AutorZanr (autor, zanr) VALUES (10, 11);

INSERT INTO titul (id_titulu, nazev) VALUES (1, 'The Wizards Return');
INSERT INTO titul (id_titulu, nazev) VALUES (2, 'The Play of Destiny');
INSERT INTO titul (id_titulu, nazev) VALUES (3, 'The Last Man in London');
INSERT INTO titul (id_titulu, nazev) VALUES (4, 'Revolutionary Love');
INSERT INTO titul (id_titulu, nazev) VALUES (5, 'Christmas Tales');
INSERT INTO titul (id_titulu, nazev) VALUES (6, 'Stage of Life');
INSERT INTO titul (id_titulu, nazev) VALUES (7, 'Jazz Age Stories');
INSERT INTO titul (id_titulu, nazev) VALUES (8, 'Memories of My Melancholy Life');
INSERT INTO titul (id_titulu, nazev) VALUES (9, 'Tales of the Peculiar');
INSERT INTO titul (id_titulu, nazev) VALUES (10, 'An Evening of Mysteries');
INSERT INTO titul (id_titulu, nazev) VALUES (11, 'The Thrilling Adventures');
INSERT INTO titul (id_titulu, nazev) VALUES (12, 'The Ghosts of Maine');
INSERT INTO titul (id_titulu, nazev) VALUES (13, 'The Castle in the Clouds');
INSERT INTO titul (id_titulu, nazev) VALUES (14, '3Time Warp Terror');
INSERT INTO titul (id_titulu, nazev) VALUES (15, 'The Dramatic Shadows');
INSERT INTO titul (id_titulu, nazev) VALUES (16, 'The Enchanter’s Tales');
INSERT INTO titul (id_titulu, nazev) VALUES (17, 'Reflections of Reality');
INSERT INTO titul (id_titulu, nazev) VALUES (18, 'Parables of the Absurd');
INSERT INTO titul (id_titulu, nazev) VALUES (19, 'The Waves of Society');
INSERT INTO titul (id_titulu, nazev) VALUES (20, 'Garfield');
INSERT INTO titul (id_titulu, nazev) VALUES (21, 'The Dark Knight');
INSERT INTO titul (id_titulu, nazev) VALUES (22, 'Donald the duck');
INSERT INTO titul (id_titulu, nazev) VALUES (23, 'Tom & Jerry');
INSERT INTO titul (id_titulu, nazev) VALUES (24, 'Airplane models');
INSERT INTO titul (id_titulu, nazev) VALUES (25, 'World war II');
INSERT INTO titul (id_titulu, nazev) VALUES (26, 'Score');

INSERT INTO TitulZanr (titul, zanr) VALUES (1, 1);
INSERT INTO TitulZanr (titul, zanr) VALUES (2, 11);
INSERT INTO TitulZanr (titul, zanr) VALUES (3, 2);
INSERT INTO TitulZanr (titul, zanr) VALUES (4, 6);
INSERT INTO TitulZanr (titul, zanr) VALUES (5, 10);
INSERT INTO TitulZanr (titul, zanr) VALUES (6, 11);
INSERT INTO TitulZanr (titul, zanr) VALUES (7, 10);
INSERT INTO TitulZanr (titul, zanr) VALUES (8, 4);
INSERT INTO TitulZanr (titul, zanr) VALUES (9, 10);
INSERT INTO TitulZanr (titul, zanr) VALUES (10, 10);
INSERT INTO TitulZanr (titul, zanr) VALUES (11, 7);
INSERT INTO TitulZanr (titul, zanr) VALUES (12, 9);
INSERT INTO TitulZanr (titul, zanr) VALUES (13, 1);
INSERT INTO TitulZanr (titul, zanr) VALUES (14, 2);
INSERT INTO TitulZanr (titul, zanr) VALUES (15, 11);
INSERT INTO TitulZanr (titul, zanr) VALUES (16, 10);
INSERT INTO TitulZanr (titul, zanr) VALUES (17, 8);
INSERT INTO TitulZanr (titul, zanr) VALUES (18, 10);
INSERT INTO TitulZanr (titul, zanr) VALUES (19, 11);
INSERT INTO TitulZanr (titul, zanr) VALUES (20, 12);
INSERT INTO TitulZanr (titul, zanr) VALUES (21, 2);
INSERT INTO TitulZanr (titul, zanr) VALUES (22, 12);
INSERT INTO TitulZanr (titul, zanr) VALUES (23, 12);
INSERT INTO TitulZanr (titul, zanr) VALUES (24, 3);
INSERT INTO TitulZanr (titul, zanr) VALUES (25, 3);
INSERT INTO TitulZanr (titul, zanr) VALUES (26, 1);

INSERT INTO AutorTitul (autor, titul) VALUES (1, 1);
INSERT INTO AutorTitul (autor, titul) VALUES (1, 2);
INSERT INTO AutorTitul (autor, titul) VALUES (2, 3);
INSERT INTO AutorTitul (autor, titul) VALUES (2, 4);
INSERT INTO AutorTitul (autor, titul) VALUES (3, 5);
INSERT INTO AutorTitul (autor, titul) VALUES (3, 6);
INSERT INTO AutorTitul (autor, titul) VALUES (4, 7);
INSERT INTO AutorTitul (autor, titul) VALUES (5, 8);
INSERT INTO AutorTitul (autor, titul) VALUES (5, 9);
INSERT INTO AutorTitul (autor, titul) VALUES (6, 10);
INSERT INTO AutorTitul (autor, titul) VALUES (6, 11);
INSERT INTO AutorTitul (autor, titul) VALUES (7, 12);
INSERT INTO AutorTitul (autor, titul) VALUES (7, 13);
INSERT INTO AutorTitul (autor, titul) VALUES (7, 14);
INSERT INTO AutorTitul (autor, titul) VALUES (7, 15);
INSERT INTO AutorTitul (autor, titul) VALUES (8, 16);
INSERT INTO AutorTitul (autor, titul) VALUES (8, 17);
INSERT INTO AutorTitul (autor, titul) VALUES (9, 18);
INSERT INTO AutorTitul (autor, titul) VALUES (10, 19);
INSERT INTO AutorTitul (autor, titul) VALUES (4, 20);
INSERT INTO AutorTitul (autor, titul) VALUES (3, 21);
INSERT INTO AutorTitul (autor, titul) VALUES (7, 22);
INSERT INTO AutorTitul (autor, titul) VALUES (1, 23);
INSERT INTO AutorTitul (autor, titul) VALUES (4, 24);
INSERT INTO AutorTitul (autor, titul) VALUES (8, 25);
INSERT INTO AutorTitul (autor, titul) VALUES (10, 26);

INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (1, 'First Edition', 320, 499.00, 'New', 1);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (2, 'Second Edition', 333, 549.00, 'New', 1);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (3, 'Second Edition', 333, 549.00, 'New', 1);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (4, 'Third Edition', 333, 609.00, 'New', 1);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (5, 'First Edition', 300, 540.00, 'New', 2);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (6, 'First Edition', 300, 540.00, 'New', 2);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (7, 'First Edition', 280, 439.00, 'New', 3);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (8, 'First Edition', 280, 439.00, 'New', 3);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (9, 'First Edition', 280, 439.00, 'New', 3);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (10, 'First Edition', 260, 505.00, 'New', 4);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (11, 'Third Edition', 260, 505.00, 'New', 4);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (12, 'Third Edition', 260, 505.00, 'New', 4);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (13, 'Second Edition', 310, 405.00, 'New', 5);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (14, 'First Edition', 290, 480.00, 'New', 6);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (15, 'First Edition', 290, 480.00, 'New', 6);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (16, 'Second Edition', 290, 480.00, 'New', 6);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (17, 'Second Edition', 290, 480.00, 'New', 6);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (18, 'First Edition', 275, 477.00, 'New', 7);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (19, 'Third Edition', 265, 527.00, 'New', 8);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (20, 'Second Edition', 350, 567.00, 'New', 9);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (21, 'First Edition', 240, 432.00, 'New', 10);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (22, 'First Edition', 240, 432.00, 'New', 10);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (23, 'First Edition', 325, 505.00, 'New', 11);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (24, 'Second Edition', 325, 505.00, 'New', 11);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (25, 'Third Edition', 325, 505.00, 'New', 11);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (26, 'First Edition', 215, 549.00, 'New', 12);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (27, 'Third Edition', 330, 593.00, 'New', 13);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (28, 'Second Edition', 299, 472.00, 'New', 14);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (29, 'First Edition', 360, 684.00, 'New', 15);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (30, 'First Edition', 360, 684.00, 'New', 15);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (31, 'First Edition', 360, 684.00, 'New', 15);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (32, 'First Edition', 250, 396.00, 'New', 16);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (33, 'Second Edition', 250, 396.00, 'New', 16);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (34, 'Second Edition', 250, 396.00, 'New', 16);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (35, 'Third Edition', 340, 495.00, 'New', 17);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (36, 'Third Edition', 340, 495.00, 'New', 17);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (37, 'Third Edition', 340, 495.00, 'New', 17);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (38, 'First Edition', 280, 441.00, 'New', 18);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (39, 'First Edition', 300, 540.00, 'New', 19);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (40, 'Second Edition', 300, 540.00, 'New', 19);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (41, 'Third Edition', 300, 540.00, 'New', 19);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (42, 'First Edition', 80, 139.00, 'New', 20);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (43, 'First Edition', 45, 159.00, 'New', 21);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (44, 'First Edition', 60, 89.00, 'New', 22);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (45, 'First Edition', 100, 99.00, 'New', 23);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (46, 'First Edition', 90, 109.00, 'New', 24);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (47, 'First Edition', 75, 99.00, 'New', 25);
INSERT INTO vytisk (id_vytisku, vydani, pocet_stran, cena, stav, titul) VALUES (48, 'First Edition', 25, 39.00, 'New', 26);

INSERT INTO kniha (titul, isbn) VALUES (1, '978-3-16-148410-0');
INSERT INTO kniha (titul, isbn) VALUES (2, '978-0-306-40615-7');
INSERT INTO kniha (titul, isbn) VALUES (3, '978-3-16-148411-7');
INSERT INTO kniha (titul, isbn) VALUES (4, '978-0-306-40616-4');
INSERT INTO kniha (titul, isbn) VALUES (5, '978-3-16-148412-4');
INSERT INTO kniha (titul, isbn) VALUES (6, '978-0-306-40617-1');
INSERT INTO kniha (titul, isbn) VALUES (7, '978-3-16-148413-1');
INSERT INTO kniha (titul, isbn) VALUES (8, '978-0-306-40618-8');
INSERT INTO kniha (titul, isbn) VALUES (9, '978-3-16-148414-8');
INSERT INTO kniha (titul, isbn) VALUES (10, '978-0-306-40619-5');
INSERT INTO kniha (titul, isbn) VALUES (11, '978-3-16-148415-5');
INSERT INTO kniha (titul, isbn) VALUES (12, '978-0-306-40620-1');
INSERT INTO kniha (titul, isbn) VALUES (13, '978-3-16-148416-2');
INSERT INTO kniha (titul, isbn) VALUES (14, '978-0-306-40621-8');
INSERT INTO kniha (titul, isbn) VALUES (15, '978-3-16-148417-9');
INSERT INTO kniha (titul, isbn) VALUES (16, '978-0-306-40622-5');
INSERT INTO kniha (titul, isbn) VALUES (17, '978-3-16-148418-6');
INSERT INTO kniha (titul, isbn) VALUES (18, '978-0-306-40623-2');
INSERT INTO kniha (titul, isbn) VALUES (19, '978-3-16-148419-3');

INSERT INTO casopis (titul, issn) VALUES (20, '1234-5678');
INSERT INTO casopis (titul, issn) VALUES (21, '2345-6789');
INSERT INTO casopis (titul, issn) VALUES (22, '3456-7890');
INSERT INTO casopis (titul, issn) VALUES (23, '4356-6890');
INSERT INTO casopis (titul, issn) VALUES (24, '6543-8709');
INSERT INTO casopis (titul, issn) VALUES (25, '3123-9929');
INSERT INTO casopis (titul, issn) VALUES (26, '1454-6690');

INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (1, 'Lucie', 'Nováková', 'Příkopy 20', 'Praha 1', '11000', '0123456789');
INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (2, 'Marek', 'Jelínek', 'Masarykova 30', 'Brno', '60200', '0987654321');
INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (3, 'Eva', 'Svobodová', 'Kapucínské náměstí 15', 'Brno', '60200', '0234567890');
INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (4, 'Petr', 'Krátký', 'Nádražní 101', 'Praha 5', '15000', '0345678901');
INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (5, 'Anna', 'Dlouhá', 'Hlavní 22', 'Ostrava', '70800', '0456789012');
INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (6, 'Jan', 'Horák', 'Rooseveltova 16', 'Plzeň', '30100', '0567890123');
INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (7, 'Tereza', 'Kopecká', 'Lidická 8', 'Liberec', '46001', '0678901234');
INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (8, 'Martin', 'Veselý', 'Jiráskova 3', 'Hradec Králové', '50002', '0789012345');
INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (9, 'Veronika', 'Pechová', 'Palackého 9', 'Olomouc', '77900', '0890123456');
INSERT INTO zamestnanec (id_zamestnance, jmeno, prijmeni, ulice, mesto, psc, telefon) VALUES (10, 'David', 'Černý', 'Husova 5', 'České Budějovice', '37001', '0901234567');

INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (1, 'Anna', 'Kovářová', 'Karlova 10', 'Praha 1', '11000', '0234567890', 'anna.kovarova@gmail.com', TO_DATE('2025-03-11', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (2, 'Jakub', 'Kovář', 'Česká 10', 'Brno', '22000', '0657483829', 'jakub.kovar@gmail.com', TO_DATE('2024-09-23', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (3, 'Jan', 'Vrzal', 'Cejl 87', 'Brno', '22000', '0564738291', 'vrzaljan@seznam.cz', TO_DATE('2025-04-12', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (4, 'Milan', 'Rus', 'Střední 622', 'Brno', '22000', '0054269438', 'milan.rus@centrum.cz', TO_DATE('2024-08-07', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (5, 'Petr', 'Pavel', 'Kořenec 19', 'Kořenec', '55201', '0775602709', 'pavel.petr@gmail.com', TO_DATE('2024-09-25', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (6, 'Lucie', 'Novotná', 'Vinohradská 48', 'Praha 2', '12000', '0123456789', 'lucie.novotna@gmail.com', TO_DATE('2025-04-30', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (7, 'Tomáš', 'Jaroš', 'Hlavní 123', 'České Budějovice', '37001', '0987654321', 'tomas.jaros@centrum.com', TO_DATE('2024-10-12', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (8, 'Eliška', 'Březinová', 'Jiráskova 1001', 'Hradec Králové', '50003', '0456789012', 'eliska.brezinova@gmail.com', TO_DATE('2024-11-05', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (9, 'Karel', 'Vomáčka', 'Dlouhá 88', 'Olomouc', '77900', '0678901234', 'karel.vomacka@gmail.com', TO_DATE('2025-02-04', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (10, 'Markéta', 'Svobodová', 'Krátká 9', 'Plzeň', '30100', '0789012345', 'marketa.svobodova@centrum.com', TO_DATE('2025-02-17', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (11, 'Jiří', 'Krátký', 'Nábřeží 456', 'Ústí nad Labem', '40002', '0890123456', 'jiri.kratky@gmail.com', TO_DATE('2024-08-18', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (12, 'Zuzana', 'Dlouhá', 'Poděbradova 321', 'Liberec', '46002', '0901234567', 'zuzana.dlouha@centrum.com', TO_DATE('2024-08-21', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (13, 'Marek', 'Procházka', 'Revolution 1989', 'Ostrava', '70030', '0012345678', 'marek.prochazka@gmail.com', TO_DATE('2025-05-29', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (14, 'Lenka', 'Malá', 'U Parku 10', 'Pardubice', '53002', '0234567891', 'lenka.mala@centrum.com', TO_DATE('2025-04-02', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (15, 'Ondřej', 'Velký', 'Na Kopci 2', 'Zlín', '76001', '0345678902', 'ondrej.velky@gmail.com', TO_DATE('2025-01-07', 'YYYY-MM-DD'));
INSERT INTO ctenar (id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu) VALUES (16, 'Jakub', 'Novák', 'Hlavní 2', 'Brno', '61300', '0335774864', 'jakub.novak333@seznam.cz', TO_DATE('2024-04-22', 'YYYY-MM-DD'));

INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni, datum_vraceni) VALUES (1, 1, 1, 1, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-31', 'YYYY-MM-DD'), TO_DATE('2024-02-03', 'YYYY-MM-DD'));
INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni) VALUES (2, 3, 3, 19, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-31', 'YYYY-MM-DD'));
INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni, datum_vraceni) VALUES (3, 2, 2, 13, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-28', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));
INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni) VALUES (4, 4, 4, 8, TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-04-22', 'YYYY-MM-DD'));
INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni) VALUES (5, 5, 5, 23, TO_DATE('2024-05-01', 'YYYY-MM-DD'), TO_DATE('2025-01-27', 'YYYY-MM-DD'));
INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni, datum_vraceni) VALUES (6, 3, 8, 18, TO_DATE('2024-01-22', 'YYYY-MM-DD'), TO_DATE('2024-02-29', 'YYYY-MM-DD'), TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni) VALUES (7, 3, 15, 4, TO_DATE('2024-04-12', 'YYYY-MM-DD'), TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni) VALUES (8, 2, 14, 15, TO_DATE('2024-11-11', 'YYYY-MM-DD'), TO_DATE('2025-02-20', 'YYYY-MM-DD'));
INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni, datum_vraceni) VALUES (9, 1, 1, 11, TO_DATE('2024-2-01', 'YYYY-MM-DD'), TO_DATE('2024-03-05', 'YYYY-MM-DD'), TO_DATE('2024-03-10', 'YYYY-MM-DD'));

INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni) VALUES (8, 2, 14, 15, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-02-02', 'YYYY-MM-DD'));

INSERT INTO rezervace (id_rezervace, ctenar, titul, datum_rezervace, stav) VALUES (1, 1, 2, TO_DATE('2024-06-01', 'YYYY-MM-DD'), 'Active');
INSERT INTO rezervace (id_rezervace, ctenar, titul, datum_rezervace, stav) VALUES (2, 2, 3, TO_DATE('2024-07-12', 'YYYY-MM-DD'), 'Active');
INSERT INTO rezervace (id_rezervace, ctenar, titul, datum_rezervace, stav) VALUES (3, 3, 4, TO_DATE('2024-08-21', 'YYYY-MM-DD'), 'Active');
INSERT INTO rezervace (id_rezervace, ctenar, titul, datum_rezervace, stav) VALUES (4, 4, 5, TO_DATE('2024-09-04', 'YYYY-MM-DD'), 'Active');
INSERT INTO rezervace (id_rezervace, ctenar, titul, datum_rezervace, stav) VALUES (5, 5, 1, TO_DATE('2024-10-19', 'YYYY-MM-DD'), 'Active');

INSERT INTO pokuta (id_pokuty, vypujcka, datum_udeleni, cena, stav) VALUES (1, 1, TO_DATE('2024-02-01', 'YYYY-MM-DD'), 50.00, 'Paid');
INSERT INTO pokuta (id_pokuty, vypujcka, datum_udeleni, cena, stav) VALUES (2, 9, TO_DATE('2024-03-06', 'YYYY-MM-DD'), 50.00, 'Paid');

COMMIT;

-- UKAZKA TRIGGERU 1:

--data pred/po volani triggeru
SELECT * FROM update_logs;
-- vyvolanie triggeru
UPDATE vytisk SET stav = 'Used'
WHERE id_vytisku = 1;


-- UKAZKA TRIGGERU 2:

-- vyvolanie triggeru
INSERT INTO vypujcka (id_vypujcky, zamestnanec_vydal, ctenar, vytisk, datum_vypujceni, ocekavane_vraceni) VALUES (10, 3, 16, 19, TO_DATE('2024-04-23', 'YYYY-MM-DD'), TO_DATE('2024-05-15', 'YYYY-MM-DD'));


-- UKAZKA PROCEDURY 1:

--data pred/po volani procedury
SELECT * FROM pokuta;
-- pouzitie procedury
BEGIN
    update_overdue_penalties;
END;
/


-- UKAZKA PROCEDURY 2:

--data pred/po volani procedury
--select ktory vyberie tituly ktore su zaner Fantasy
SELECT
    titul.nazev AS titul,
    zanr.nazev AS zanr,
    autor.jmeno || ' ' || autor.prijmeni AS autor
FROM
    zanr
    JOIN TitulZanr ON zanr.id_zanru = TitulZanr.zanr
    JOIN titul ON TitulZanr.titul = titul.id_titulu
    JOIN AutorTitul ON titul.id_titulu = AutorTitul.titul
    JOIN autor ON AutorTitul.autor = autor.id_autora
WHERE
    zanr.nazev = 'Fantasy';

-- pouzitie procedury
BEGIN
    add_book_author_genre('Harry Potter and the Philosopher''s Stone', 'Fantasy', 'J.K.', 'Rowling');
END;
/


-- UKAZKA EXPLAIN PLAN (s indexom):

--indexy:
CREATE INDEX idx_vytisk_vydani_titul ON vytisk(vydani, titul);
CREATE INDEX idx_zanr_nazev ON zanr(nazev);

--optimalizacia je tabulka AutorTitul + indexy

--explain plan
EXPLAIN PLAN FOR
--select authors by joining tables and lists the number of prints, which are First Edition and Fantasy
SELECT
    jmeno || ' ' || prijmeni AS Author,
    COUNT(id_vytisku) AS Number_Of_Copies
FROM
    autor
    JOIN AutorTitul ON autor.id_autora = AutorTitul.autor
    JOIN titul ON AutorTitul.titul = titul.id_titulu
    JOIN TitulZanr ON titul.id_titulu = TitulZanr.titul
    JOIN zanr ON TitulZanr.zanr = zanr.id_zanru
    JOIN vytisk ON titul.id_titulu = vytisk.titul
WHERE
    vytisk.vydani = 'First Edition' AND zanr.nazev = 'Fantasy'
GROUP BY
    jmeno, prijmeni;
SELECT * FROM TABLE(dbms_xplan.display());


-- pristupove prava pre druheho clena tymu
GRANT ALL ON autor TO XZELNI06;
GRANT ALL ON zanr TO XZELNI06;
GRANT ALL ON titul TO XZELNI06;
GRANT ALL ON TitulZanr TO XZELNI06;
GRANT ALL ON AutorTitul TO XZELNI06;
GRANT ALL ON vytisk TO XZELNI06;
GRANT ALL ON kniha TO XZELNI06;
GRANT ALL ON casopis TO XZELNI06;
GRANT ALL ON ctenar TO XZELNI06;
GRANT ALL ON zamestnanec TO XZELNI06;
GRANT ALL ON rezervace TO XZELNI06;
GRANT ALL ON vypujcka TO XZELNI06;
GRANT ALL ON pokuta TO XZELNI06;
GRANT ALL ON ctenar_pohled TO XZELNI06;


-- UKAZKA MATERIALIZOVANEHO POHLEDU:

DROP MATERIALIZED VIEW ctenar_pohled;

CREATE MATERIALIZED VIEW ctenar_pohled
CACHE
BUILD IMMEDIATE
REFRESH ON COMMIT
AS
SELECT *
FROM xmilis00.ctenar;


SELECT * FROM ctenar_pohled;

INSERT INTO ctenar(id_prukazu, jmeno, prijmeni, ulice, mesto, psc, telefon, email, platnost_prukazu)
    VALUES (100, 'Jozef', 'Kycina', 'Stránská', 'Praha', 11000,992664731,'JozoKycina@gmail.com', TO_DATE('2025-03-11', 'YYYY-MM-DD'));

COMMIT;

SELECT * FROM ctenar_pohled;


-- UKAZKA SELECTU (s with a case):


WITH info_kniha AS (
    SELECT DISTINCT
        titul.nazev AS nazev,
        autor.jmeno AS autor_jmeno,
        autor.prijmeni AS autor_prijmeni,
        CASE
            WHEN vytisk.pocet_stran < 100 THEN 'Krátká'
            WHEN vytisk.pocet_stran >= 100 AND vytisk.pocet_stran < 300 THEN 'Střední'
            ELSE 'Dlouhá'
        END AS delka_knihy,
        zanr.nazev AS zanr
    FROM
        vytisk
    JOIN
        titul ON titul.id_titulu = vytisk.titul
    INNER JOIN
        AutorTitul ON titul.id_titulu = AutorTitul.titul
    INNER JOIN
        autor ON AutorTitul.autor = autor.id_autora
    INNER JOIN
        TitulZanr ON titul.id_titulu = TitulZanr.titul
    INNER JOIN
        zanr ON TitulZanr.zanr = zanr.id_zanru
)
SELECT
    nazev,
    autor_jmeno,
    autor_prijmeni,
    delka_knihy,
    zanr
FROM
    info_kniha;
