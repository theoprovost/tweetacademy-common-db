-- Deploy twa_common_db:create_entity to mysql

-- ATENTION: le fichier s'appelle create-entity.sql (au singulier). Néanmoins, par convention la table doit être au pluriel : ENTITIES

BEGIN;

use twa_common_db;

-- table contenant les entités (metnions, hashtags...)

CREATE TABLE entities (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    tweet_id BIGINT NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,
    body TEXT NOT NULL, -- eg. #abc / @abc
    body_plain TEXT NOT NULL, -- eg #abc/@abc -> abc
    type VARCHAR(255) NOT NULL,

    start INTEGER NOT NULL, -- start position of text
    end INTEGER NOT NULL, -- end position of text

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

COMMIT;
