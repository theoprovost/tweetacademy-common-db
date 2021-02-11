-- Deploy twa_common_db:create_users to mysql

BEGIN;

USE twa_common_db;

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE, -- clé primaire : numéro d'identification d'un ensemble de données : la row
    name VARCHAR(255) NOT NULL, -- Nom d'affichage de l'utilisateur
    username VARCHAR(255) NOT NULL UNIQUE, -- Nom d'utilisateur : affiché au côté de son nom, utilisé pour se connecté pour remplacer/offire une alternative à l'email
    dob DATETIME NOT NULL, -- Format : YYYY-MM--DD
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- permets de stocker l'horodatage suivant la verification de l'email d'un utilisateur (envoi d'un email de verification). Fonctionnalité bonus
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL, -- Fonctionalité bonus : token lié au "remember me"
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE password_resets ( -- table bonus pour garder une trace des mdoficiations de mot de passe
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- NB : si vous avez cette erreur (You do not have the SUPER privilege and binary logging is enabled (you might want to use the less safe log_bin_trust_function_creators variable)) -> connectez vous en utilisateur root : et executez :
-- SET GLOBAL log_bin_trust_function_creators = 1;
-- Puis retentez !

delimiter $$ -- Permets d'ajouter une contrainte sur la table users, colonne dob (date of birth) : blocque l'insertion en BDD si la personne a moins de 13 ans. Attention, ne remplace pas les verifications à réaliser avant l'insertion en BDD : en front (via js) + back (via PHP)
CREATE TRIGGER date_check BEFORE INSERT ON users
FOR EACH ROW
    BEGIN
        IF NEW.dob >= (DATE_SUB(NOW(), INTERVAL 13 YEAR)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'You must be older than 13 to register';
        END IF;
    END;
$$

-- INSERT INTO users (name, dob, email, password) VALUES ('theo', '2007-02-09', 'theo@theo.fr', 'test');

COMMIT;
