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