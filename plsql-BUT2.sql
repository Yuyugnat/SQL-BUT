SHOW ERRORS;

-- exo 6)
CREATE OR REPLACE FUNCTION nbEtudiantsParGroupe (p_idGroupe etudiants.idGroupe%TYPE) RETURN NUMBER IS
nb NUMBER;
v_idGroupe etudiants.idGroupe%TYPE;
BEGIN
    SELECT idGroupe INTO v_idGroupe FROM groupes WHERE idGroupe = p_idGroupe;
    SELECT COUNT(*) INTO nb FROM etudiants WHERE idGroupe = p_idGroupe;
    RETURN nb;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END nbEtudiantsParGroupe;
/

SELECT nbEtudiantsParGroupe('Q1')
FROM DUAL;

SELECT nbEtudiantsParGroupe('Q5')
FROM DUAL;


-- exo 7)
CREATE OR REPLACE FUNCTION nbEtudiantsParPromotion(p_idPromotion IN Promotions.idPromotion%TYPE)
RETURN NUMBER IS
nb NUMBER;
BEGIN
    SELECT SUM(nbEtudiantsParGroupe(idGroupe)) INTO nb FROM groupes WHERE idPromotion = p_idPromotion;
    RETURN nb;
END nbEtudiantsParPromotion;
/

SELECT nbEtudiantsParPromotion('A1')
FROM DUAL ; 

UPDATE Promotions
SET nbEtudiantsPromotion = nbEtudiantsParPromotion(idPromotion);

SELECT * FROM Promotions;

-- exo 8)
CREATE OR REPLACE PROCEDURE affichageInfosEtudiant(p_idEtudiant IN etudiants.idEtudiant%TYPE)
IS
v_idEtudiant etudiants.idEtudiant%TYPE;
v_nomEtudiant etudiants.nomEtudiant%TYPE;
v_prenomEtudiant etudiants.prenomEtudiant%TYPE;
v_sexeEtudiant etudiants.sexeEtudiant%TYPE;
v_dateNaissanceEtudiant etudiants.dateNaissanceEtudiant%TYPE;
v_idGroupe etudiants.idGroupe%TYPE;
BEGIN
    SELECT idEtudiant, nomEtudiant, prenomEtudiant, sexeEtudiant, dateNaissanceEtudiant, idGroupe INTO v_idEtudiant, v_nomEtudiant, v_prenomEtudiant, v_sexeEtudiant, v_dateNaissanceEtudiant, v_idGroupe FROM etudiants WHERE idEtudiant = p_idEtudiant;
    DBMS_OUTPUT.PUT_LINE('idEtudiant : ' || v_idEtudiant);
    DBMS_OUTPUT.PUT_LINE('nomEtudiant : ' || v_nomEtudiant);
    DBMS_OUTPUT.PUT_LINE('prenomEtudiant : ' || v_prenomEtudiant);
    DBMS_OUTPUT.PUT_LINE('sexEtudiant : ' || v_sexeEtudiant);
    DBMS_OUTPUT.PUT_LINE('dateNaissanceEtudiant : ' || v_dateNaissanceEtudiant);
    DBMS_OUTPUT.PUT_LINE('idGroupe : ' || v_idGroupe);
    EXCEPTION WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Aucun étudiant avec cet id');
END affichageInfosEtudiant;
/

CALL affichageInfosEtudiant('E1');

-- exo 9)
CREATE OR REPLACE PROCEDURE miseAJourCoefficientModules
IS
BEGIN
FOR i IN (SELECT * FROM MODULES)
LOOP
UPDATE MODULES
SET COEFFICIENTMODULE = (
    SELECT SUM(COEFFICIENTMATIERE)
    FROM MATIERES
    WHERE MATIERES.IDMODULE = i.IDMODULE
)
WHERE idModule = i.idModule;
END LOOP;
END miseAJourCoefficientModules;
/

CALL miseAJourCoefficientModules();

SELECT idModule, coefficientModule
FROM MODULES;


-- exo 10)
CREATE OR REPLACE PROCEDURE affichageNotesEtudiant(p_idEtudiant IN Etudiants.idEtudiant%TYPE)
IS
BEGIN
FOR i IN (SELECT * FROM NOTES n JOIN MATIERES m ON n.idMatiere = m.idMatiere WHERE idEtudiant = p_idEtudiant)
LOOP
DBMS_OUTPUT.PUT_LINE(i.nomMatiere || ' ' || i.note);
END LOOP;
END affichageNotesEtudiant;
/

CALL affichageNotesEtudiant('E1');

-- exo 11)
CREATE OR REPLACE PROCEDURE affichageNotesEtudiantSemestre(
    p_idEtudiant IN Etudiants.idEtudiant%TYPE, 
    p_idSemestre IN Semestres.idSemestre%TYPE
) IS
    CURSOR cur IS SELECT NOMMATIERE, NOTE FROM NOTES n JOIN MATIERES m ON m.IDMATIERE = n.IDMATIERE JOIN MODULES mo on m.IDMODULE = mo.IDMODULE WHERE IDETUDIANT = p_idEtudiant AND IDSEMESTRE = p_idSemestre;
    exist BOOLEAN := FALSE;
BEGIN
    FOR i IN cur LOOP
        DBMS_OUTPUT.PUT_LINE(i.NOMMATIERE || ' : ' || i.NOTE);
        exist := TRUE;
    END LOOP;
    IF NOT exist THEN
        DBMS_OUTPUT.PUT_LINE('Aucune note pour cet étudiant dans ce semestre');
    END IF;
END;
/

CALL affichageNotesEtudiantSemestre('E1', 'S4');

-- exo 12)
CREATE OR REPLACE PROCEDURE affichageToutEtudiantSemestre(
    p_idEtudiant IN Etudiants.idEtudiant%TYPE,
    p_idSemestre IN Semestres.idSemestre%TYPE
) IS
BEGIN
    AFFICHAGEINFOSETUDIANT(p_idEtudiant);
    AFFICHAGENOTESETUDIANTSEMESTRE(p_idEtudiant, p_idSemestre);
END;
/

CALL affichageToutEtudiantSemestre('E10', 'S3');


-- exo 13)
CREATE OR REPLACE PROCEDURE affichageAbsencesParPromotion(
    p_idPromotion IN Promotions.idPromotion%TYPE
) IS
CURSOR c_absences (p_idGroupe IN GROUPES.idGroupe%TYPE) IS
    SELECT e.NOMETUDIANT, e.PRENOMETUDIANT, COUNT(A.IDABSENCE) AS NBABSENCES
    FROM ABSENCES a 
    LEFT JOIN ETUDIANTS e ON a.IDETUDIANT = e.IDETUDIANT 
    WHERE e.IDGROUPE = p_idGroupe 
    GROUP BY e.IDETUDIANT, e.NOMETUDIANT, e.PRENOMETUDIANT, e.DATENAISSANCEETUDIANT, e.IDGROUPE
    ORDER BY NBABSENCES DESC;
    v_nbEtudiants NUMBER;
BEGIN
    FOR i IN (SELECT * FROM GROUPES WHERE IDPROMOTION = p_idPromotion ORDER BY IDGROUPE) LOOP
        SELECT COUNT(*) INTO v_nbEtudiants FROM ETUDIANTS WHERE IDGROUPE = i.IDGROUPE;
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('Groupe : ' || i.IDGROUPE || ' (' || v_nbEtudiants  || ' étudiants)');
        FOR j IN c_absences(i.IDGROUPE) LOOP
            DBMS_OUTPUT.PUT_LINE('-----> ' || j.NOMETUDIANT || ' ' || j.PRENOMETUDIANT || ' a été absent ' || j.NBABSENCES || ' fois');
        END LOOP;
    END LOOP;
END;

/

CALL affichageAbsencesParPromotion('A1');

-- exo 14)
CREATE OR REPLACE FUNCTION moyenneEtudiantModule(
    p_idEtudiant IN Etudiants.idEtudiant%TYPE,
    p_idModule IN Modules.idModule%TYPE
) RETURN NUMBER IS
    v_moyenne NUMBER;
BEGIN
    SELECT SUM(NOTE * M.COEFFICIENTMATIERE) / SUM(M.COEFFICIENTMATIERE) INTO v_moyenne 
    FROM NOTES n 
    JOIN MATIERES m ON n.IDMATIERE = m.IDMATIERE 
    WHERE IDETUDIANT = p_idEtudiant 
    AND IDMODULE = p_idModule;
    RETURN v_moyenne;
END;

/

SELECT moyenneEtudiantModule('E8', 'M113')
FROM DUAL;

SELECT NOTE  FROM NOTES n JOIN MATIERES m ON n.IDMATIERE = m.IDMATIERE where IDETUDIANT = 'E8' AND M.IDMODULE = 'M113';

-- exo 15)
CREATE OR REPLACE FUNCTION valideEtudiantModule(
    p_idEtudiant IN Etudiants.idEtudiant%TYPE,
    p_idModule IN Modules.idModule%TYPE
) RETURN NUMBER IS
BEGIN
    RETURN CASE 
        WHEN moyenneEtudiantModule(p_idEtudiant, p_idModule) >= 8 
        THEN 1 
        ELSE 0 
    END;
END;

/

SELECT valideEtudiantModule('E6', 'M112')
FROM DUAL;

-- exo 16)
-- consigne pas claire

-- exo 17)
CREATE OR REPLACE PROCEDURE affichageMoyEtudiantSemestre(
    p_idEtudiant IN Etudiants.IDETUDIANT%TYPE,
    p_idSemestre IN Semestres.IDSEMESTRE%TYPE
) IS
