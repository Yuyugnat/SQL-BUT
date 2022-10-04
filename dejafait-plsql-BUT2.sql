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

CALL affichageToutEtudiantSemestre('E10', 'S3');

-- exo 13)
CREATE OR REPLACE PROCEDURE affichageAbsencesParPromotion(
    p_idPromotion IN Promotions.idPromotion%TYPE
) IS
    CURSOR c_absences IS
        SELECT g.IDGROUPE, nomEtudiant, prenomEtudiant, count(A.IDABSENCE) AS nbAbsences
        FROM Absences a 
        FULL JOIN Etudiants e ON a.idEtudiant = e.idEtudiant
        FULL JOIN GROUPES g ON e.idGroupe = g.idGroupe
        WHERE idPromotion = p_idPromotion
        GROUP BY a.idEtudiant, g.IDGROUPE, nomEtudiant, prenomEtudiant
        ORDER BY g.idGroupe ASC, nbAbsences DESC;
    -- cursor that count the number of student in each group
    CURSOR c_nbEtudiants IS
        SELECT count(e.idEtudiant) AS nbEtudiants
        FROM Etudiants e
        FULL JOIN GROUPES g ON e.idGroupe = g.idGroupe
        WHERE idPromotion = p_idPromotion
        GROUP BY g.IDGROUPE;
    v_nomEtudiant Etudiants.NOMETUDIANT%TYPE;
    v_prenomEtudiant Etudiants.PRENOMETUDIANT%TYPE;
    v_nbAbsences NUMBER;
    v_currentIdGroupe Groupes.IDGROUPE%TYPE;
    v_idGroupe Groupes.IDGROUPE%TYPE;
    v_nbEtudiants NUMBER;
BEGIN
    v_idGroupe := NULL;
    OPEN c_absences;
    OPEN c_nbEtudiants;
    LOOP
        FETCH c_absences INTO v_currentIdGroupe, v_nomEtudiant, v_prenomEtudiant, v_nbAbsences;
        EXIT WHEN c_absences%NOTFOUND;
        IF v_idGroupe != v_currentIdGroupe OR v_idGroupe IS NULL THEN
            FETCH c_nbEtudiants INTO v_nbEtudiants;
            IF v_idGroupe IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE(' ');
            END IF;
            DBMS_OUTPUT.PUT_LINE('Groupe : ' || v_currentIdGroupe || ' (' || v_nbEtudiants || ' étudiants)');
            v_idGroupe := v_currentIdGroupe;
        END IF;
        IF v_nomEtudiant IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('-----> ' || v_nomEtudiant || ' ' || v_prenomEtudiant || ' a été absent ' || v_nbAbsences || ' fois');
        END IF;
    END LOOP;
    CLOSE c_absences;
    CLOSE c_nbEtudiants;
END;

CALL affichageAbsencesParPromotion('A2');