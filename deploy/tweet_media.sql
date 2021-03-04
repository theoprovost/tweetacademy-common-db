-- Deploy twa_common_db:tweet_media to mysql

BEGIN;

use twa_common_db;

CREATE TABLE media (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    tweet_id BIGINT NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,
    media_id UUID NOT NULL, -- reference au nom sous forme de UUID tel que stocké sur le disque : l'UUID permet de - relativement - garantir l'unicité des ressources

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

COMMIT;
