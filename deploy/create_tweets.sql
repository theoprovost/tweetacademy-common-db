-- Deploy twa_common_db:create_tweet to mysql

BEGIN;

use twa_common_db;

CREATE TABLE tweets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- référence l'auteur du tweet + CASCADE : si l'utilisateur 1 est supprimé, tout les références à l'user 1 dans cette table seront supprimées
    body TEXT NULL, -- contient le corps du tweet : peut être NULL. Pourquoi ? On peut éventuellement tweeter uniquement des photos par example
    type VARCHAR(255) NOT NULL DEFAULT 'TWEET', -- Simple TWEET, RETWEET, QUOTE : pour plus de consistence, je vous conseille de formater vos type en majuscule comme cités précedemment (PS: il existe également la possibilité de reply, mais au final, un reply c'est seuelement un tweet qui a un parent direct)
    original_tweet_id BIGINT NOT NULL REFERENCES tweets(id) ON DELETE CASCADE, -- référence le tweet originel dans le cas d'un tweet de type QUOTE notamment
    parent_id BIGINT NOT NULL REFERENCES tweets(id) ON DELETE CASCADE, -- référence le tweet parent : utile pour développer la fonctionnalité de reply. Sur twitter on peut donc répondre directement à un tweet, mais aussi répondre spécifiquement à la réponse de la réponse d'un tweet ...etc

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

COMMIT;
