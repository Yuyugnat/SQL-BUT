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
BEGIN
FOR i IN (SELECT * FROM NOTES n JOIN MATIERES m ON n.idMatiere = m.idMatiere JOIN MODULES mod ON mod.idModule = m.idModule WHERE idEtudiant = p_idEtudiant AND idSemestre = p_idSemestre)
LOOP
DBMS_OUTPUT.PUT_LINE(i.nomMatiere || ' ' || i.note);
END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('Aucune note pour cet étudiant dans ce semestre');
END affichageNotesEtudiantSemestre;

CALL affichageNotesEtudiantSemestre('E1', 'S2');