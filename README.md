# Création de la base de donnée commune

> 💃🏽 La V2 vient d'être publiée. N'hésitez pas y jeter un oeil. Elle est disponible sur le branche 'V2', pour y accèder :
> - vous avez n'avez pas encore cloné le repo une première fois : <br>
    - `git clone urlduprojet ` <br>
    - `git checkout V2`
    <br>
> - Vous avez déjà cloné une première fois : <br>
    - `git pull` <br>
    - `git checkout V2` <br><br>
>Je vous en remets à la documentation de git pour comprendre ces commandes.
<br><br>
> ➕ Des commentaires ont été ajoutés à la fin de ce fichier :) <br><br>
>NB: Suite à des problèmes de connexion à l'utilisateur root rencontré par certains,je vous laisse de la doc pour trouble-shoot tout ça : https://devanswers.co/how-to-reset-mysql-root-password-ubuntu/


```
Prérequis :
    - PHP^7.0
    - MYSQL^8.0
    - (PhpMyAdmin)
```

Attention : ce n'est pas une bonne chose de commit des informations sensibles. Donc faites en sorte de gitignore le dossier. <br>
Prochainement, nous travaillerons à la mise en place du base de donnée commune, hebergée sur un serveur - donc accessible à tous -.

## Etapes à suivre pour mettre en place la BDD :

### Préparation et import
1. Cloner ce repo dans votre projet
2. Renommer ce dossier `mv ancien_nom nouveau_nom`
3. Se rendre dans le dossier `cd nom_du_dossier`

### Description
Vous remarquerez la présence de plusieurs fichiers et dossiers.
- 🦸  Un fichier `create_database.sql` : il permet de créer une base de donnée locale MYSQL, l'user associé, et lui occtroyer les droits.
- 📝 Un dossier `deploy/` : il contient l'ensemble des fichiers qui seront à executer pour faire evoluer notre base de données.
- 🗑 Un dossier `revert/` : qui contrairerment au précedent, contient tout les fichiers qui permettent d'annuler les actions d'un 'deploy' au nom analogue.
- 🔒 Deux fichiers `sqitch.conf / sqitch.plan` qui sont en réalité des fichiers de configuration utilisés par Sqitch (un outil de versioning de BDD : [pour les curieux 🚀](https://sqitch.org/)). Vous pouvez les ignorer.

### Création de la base de donnée
4. Il faut maintenant créé une base de donnée locale sur votre machine. Pour ce faire, il suffit d'être positionné dans le bon répertoire (cf. étape précédente) et d'executer la commande suivante : `mysql -u root -p < create_database.sql`.
5. Si vous n'avez aucun retour, c'est que ça s'est (a priori) bien passé. On peut néanmoins vérifier que c'est bien le cas en essayant de nous connecter à la base de données que nous venons de créer : `mysql -u twa_admin -p` <br> <br>
Pour rappel, les crédentials sont les suivants : <br>
```
User : twa_admin
Password : 2f185889-9694-4b3c-8224-47e2993c432b

DB name : twa_common_db
DB host : localhost / 127.0.0.1
DB port : 3306
```

6. A cette étape, si tout est ok de votre côté, vous pouvez commencer à executer les différents fichiers de deploy. La seule spécificité à respecter es d'appliquer ces fichiers **dans l'ordre chronologique** (la date est présente dans chaque fichier, et à défaut, vous pouvez regarder le `sqitch.plan` qui répertorie les fichiers dans l'ordre de création).

NB : Si vous souhaitez repartir depuis 0, le plus simple est de ré-excuter le premier fichier (`create_database.sql` avec l'utilsateur **root**). Néanmoins, si vous souhaitez revenir à l'étape n-1, il vous suffit d'utiliser le fichier correspondant disponible dans `revert/` (avec l'user **twa_admin** cette fois ci).

## Comment utiliser ma BDD dans mon projet ?

Pour faire le lien entre une base de donnée et un projet PHP, on a de nombreuses possibilités. Les deux plus courrantes sont l'utilisation de l'extension [mysqli](https://www.php.net/manual/fr/book.mysqli.php) (dans le cas d'une DB en mysql) ou d'utiliser l'objet PHP Data Object : [PDO](https://www.php.net/manual/fr/book.pdo.php).
L'avantage de ce dernier est qu'il est cross-driver, si vous décidez de changer de DB demain - pour Postgres par exemple - il y aura peu de choses à changer dans votre code.

```
✋ Attention toute fois, PDO nécessite parfois d'être manuellement chargé par PHP. Si vous avez des erreurs dès votre première tentative de connexion : vérifiier votre config PHP.
```

Maintenant, on va créer une connexion à notre DB, cette connexion sera initialisée via la fonction `getConnection()`. Le fait de la mettre dans une fonction peut être utile plus tard - lors de la création de nos models notamment - afin qu'ils héritent de cette méthode (👋  `extends NomDuModelGenerique`).
```php
// Version simple, de test :

$db_host = 'localhost';
$db_name = 'twa_common_db';
$db_user = 'twa_admin';
$db_password = '2f185889-9694-4b3c-8224-47e2993c432b';

function getConnection($db_host, $db_name, $db_user, $db_password)
{
    try {
            return new PDO("mysql:host={$db_host};dbname={$db_name};charset=utf8", $db_user, $db_password);

        } catch(PDOException $exception) {
            echo "Erreur de connexion : " . $exception->getMessage();
        };
}

// Version POO :
in : [.../models/model]

public function getConnection()
{

        // Initialize empty connection
        $this->_connexion = null;

        try {
            $this->_connexion = new PDO("mysql:host={$_ENV["DB_HOST"]};dbname={$_ENV["DB_NAME"]};charset=utf8", $_ENV["DB_USER"], $_ENV["DB_PASSWORD"]);

        } catch(PDOException $exception) {
            echo "Erreur de connexion : " . $exception->getMessage();
        };
}
```
<br>
Ne tenez pas compte du prochain paragraphe/encart si ça vous embrouille et utilisez la première version de `getConnection()`. <br> <br>

La présence d'informations senseibles suppose la création d'un fichier `.env` à la racine de votre projet. Ce fichier contiendra les variables d'environnement nécessaire à votre programme. A commencer par les credentials nécessaire à la connexion à la base de donnée.
La syntaxe de ce fichier est la suivante :
```env
DB_HOST=monhost
DB_NAME=lenomdemabasededonnee

...

Donc très concrètement ça donne ça :

DB_HOST=localhost
DB_NAME=twa_common_db
DB_USER=twa_admin
DB_PASSWORD=2f185889-9694-4b3c-8224-47e2993c432b
```
⚠️ Pas d'espace entre les "=", pas de ";", tout est collé, des retours à la lignes sont effectués pour chaque nouvelle variable. <br> <br>
NB: Il faudra utiliser un package externe ou - sans `.env `- passer les variables au moment du lancement du serveur. <br> <br>
Maintenant, testons notre connexion (code ci-dessous valable uniquement si vous avez le code précedent sur la même page - à adapter en fonction, evidemment -).
```php
// On stock la connexion qui nous est retournée par getConnection()
$connexion = getConnection($db_host, $db_name, $db_user, $db_password);

// On stock une query basique dont on sait qu'elle devrait nous retourner qqch
$sql = "SELECT * FROM users";

// Cf. la doc, on utilise les méthodes de PDO (alors à la publication de la V1 : nous n'avons pas rentré de données : donc il n'y aura rien de retourner. L'inmportant ici est de ne pas avoir d'erreurs de la part de MySql)
$query = $connexion->prepare($sql);
$query->execute();
$data = $query->fetchAll(PDO::FETCH_ASSOC);

// On affiche à l'écran le résultat (ça suppose d'avoir un serveur qui tourne, via : php -S localhost:8000 par exemple, puis pour visualiser : http://localhost:8000/nomduscript.php)
var_dump($data);
```
Et voilà, vous avez une connexion établie, il ne vous reste plus qu'à vous en servir. ✌️
<br>

## Commentaires relatifs à la V2

PS : des colonnes ayant été ajoutées dans les tables de la V1, je vous conseille de DROP la DB compète et de refaire le processus depuis le début. Les credentials resteront les mêmes bien entendu, cela permet juste de s'assurer que la base de donnée que vous avez est bien en adéquation avec la dernière version sortie.

- Ajout de commentaires sur toutes les tables.
- Modifications de la table `users` : ajout d'une colonne `name`.
- Création de la table `followers` : cette table stock en son sein les relations qui unissent les utilisateurs entre eux (sous forme de pair : une personne peut suivre un nombre n d'utilisateur, un personne peut être suivi par n personnes).
- Création de la table `tweets` : c'est là ou sera stocké les tweets. Cette table sera sans doutes amené à évoluer pour intégrer son "type" (tweet simple, réponse, retweet...) et lui offir d'autres fonctionnalités (ajout de médias...). [UPDATE: alors non, les media ont été intégrés dans une table à part]

> Encore une fois, si vous avez la moindre question, n'hésitez pas !
<br>

#### **Note à moi-même**

- [x] rendre le body du tweet nullable <br>
- [x] offire la possibilié d'inclure des médias <br>
- [x] ajouter un type au tweet (default TWEET) : RETWEET + QUOTE <br>
- [x] ajout de la colonne 'original_tweet_id' <br>
- [x] ajout de la table likes <br>

## Commentaires V.2.5
Veuillez prendre en compte les ajouts cités ci-dessous (cf. Note à moi-même). Ils référencent la majorité des changements. Des commentaires ont été ajoutés directement sur les fichiers SQL. Veuillez les lire. A la suite de cela, si vous avez encore des intérogations, des remarques, j'y répondrais avec plaisir demain. <br><br>
N'oubliez pas que c'est un travail commun et qu'il est important que tout le monde soit capable de comprendre ces fichiers, ses raisons, son fonctionnement.


Bon courage à tous pour la suite de votre projet ! 🚀

## (Commentaires V.3)
Cette version n'est pas encore veritable finit mais voici quelques elements qui ont été ajoutés dans cette version.
- Création de la table `Entities` : cette table a pour but de stocker les entités (mentions, hasthags...)

N'hésitez pas si vous avez des besoins particuliers/des reflexions.. ou des problèmes ! :)