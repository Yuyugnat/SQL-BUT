-- R10
-- l’identifiant des livres qui sont actuellement empruntés. 
SELECT idlivre
FROM emprunts
WHERE dateretour IS NULL;

-- R11
-- le nombre de livres qui sont ou ont été empruntés.
SELECT COUNT(DISTINCT idlivre)
FROM emprunts;

-- R12
--  le nom des livres qui sont ou ont été empruntés par l’adhérent Barbie Chette avec des JOIN
SELECT DISTINCT NOMLIVRE
FROM livres
JOIN emprunts ON livres.idlivre = emprunts.idlivre
JOIN adherents ON adherents.idadherent = emprunts.idadherent
WHERE NOMADHERENT = 'Chette'
AND PRENOMADHERENT = 'Barbie';

-- R13
-- le prix moyen des livres de la catégorie 'Informatique'
SELECT AVG(PRIXLIVRE)
FROM livres
WHERE CATEGORIELIVRE = 'Informatique';

-- R14
-- name of the less expensive livres from the Eyrolles editor
SELECT NOMLIVRE
FROM livres
WHERE IDEDITEUR IN (SELECT IDEDITEUR
                    FROM editeurs
                    WHERE NOMEDITEUR = 'Eyrolles')
AND PRIXLIVRE = (SELECT MIN(PRIXLIVRE)
                    FROM livres
                    WHERE IDEDITEUR IN (SELECT IDEDITEUR
                                        FROM editeurs
                                        WHERE NOMEDITEUR = 'Eyrolles'));

-- R15
-- le nom et le prénom des adhérents qui n’ont pas réalisé d’emprunt (pas de ligne dans la table emprunts)
SELECT NOMADHERENT, PRENOMADHERENT
FROM adherents
WHERE idadherent NOT IN (SELECT idadherent
                         FROM emprunts);

-- R16
