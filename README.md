# Création de la base de donnée commune

```
Prérequis :
    - PHP^7.0
    - MYSQL^8.0
    - (PhpMyAdmin)
```
Attention : ce n'est apas une bonne chose de commit des informations sensibles. Donc faites en sorte de gitignore le dossier
Prochainement, nous travaillerons à la mise en place du base de donnée commune.

## Etapes à suivre pour mettre en place la BDD :

### Préparation et import
1. Cloner ce repo dans votre projet
2. Renommer ce dossier `mv ancien_nom nouveau_nom`
3. Se rendre dans le dossier `cd nom_du_dossier`

### Description
Vous remarquerez la présence de plusieurs fichiers et dossiers.
- Un fichier `create_database.sql` : il permet de créer une base de donnée locale MYSQL, l'user associé, et lui occtroyer les droits.
- Un dossier `deploy/` : il contient l'ensemble des fichiers qui seront à executer pour faire evoluer notre base de données.
- Un dossier `revert/` : qui contrairerment au précedent, contient tout les fichiers qui permettent d'annuler les actions d'un 'deploy' au nom analogue.
- Deux fichiers `sqitch.conf / sqitch.plan` qui sont en réalité des fichiers de configuration utilisés par Sqitch (un outil de versioning de BDD : [pour les curieux 🚀](https://sqitch.org/)). Vous pouvez les ignorer.

### Création de la base de donnée
4. Il faut maintenant créé une base de donnée locale sur votre machine. Pour ce faire, il suffit d'être positionné dans le bon répertoire (cf. étape précédente) et d'executer la commande suivante : `mysql -u root -p < create_database.sql`.
5. Si vous n'avez aucun retour, c'est que ça s'est bien passé. On peut néanmoins vérifier que c'est bien le cas en essayant de nous connecter à la base de données que nous venons de créer : `mysql -u twa_admin -p` <br>
Pour rappel, les crédentials sont les suivants : <br>
```
User : twa_admin
Password : 2f185889-9694-4b3c-8224-47e2993c432b

DB name : twa_common_db
DB host : localhost / 127.0.0.1
DB port : 3306
```

6. A cette étape, si tout est ok de votre côté, vous pouvez commencer à executer les différents fichiers de deploy. La seule spécificité à respecter, et d'appliquer ces fichiers **dans l'ordre chronologique** (la date est présente dans chaque fichier, é à défaut, vous pouvez regarder le `sqitch.plan` qui répertorie les fichiers dans leur ordre de création).

NB : Si vous souhaitez repartir depuis 0, le plus simple est de ré-excuter le premier fichier (`create_database.sql`). Néanmoins, si vous souhaitez revenir à l'étape n-1, il vous suffit d'utiliser le fichier correspondant disponible dans `revert/`.

## Comment utiliser ma BDD dans mon projet ?

Pour faire le lien entre une base de donnée et un projet PHP, on a de nombreuses possibilités. Les deux plus courrantes sont l'utilisation de l'extension [mysqli](https://www.php.net/manual/fr/book.mysqli.php) ou d'utiliser l'objet PHP Data Object : [PDO](https://www.php.net/manual/fr/book.pdo.php).
L'avantage de ce dernier est qu'il est cross-driver, si vous décidez de changer de DB demain - pour Postgres par exemple - il y aura peu de choses à changer dans votre code.

```
Attention tout fois, PDO nécessite parfois d'être manuellement chargé par PHP. Si vous avez des erreurs dès votre première tentative de connexion : vérifiier votre config PHP.
```

Maintenant, on va créer une connexion à notre DB, cette connexion sera stockée dans la fonction `getConnection()`. Le fait de la mettre dans une fonction peut être utilse plus tard - lors de la création de nos models - afin qu'ils héritent de cette méthode par le biais de `extends NomDuModelGenerique`.
```php
-- Version simple, de test :

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

-- Version POO :
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
NB: Il faudra utiliser un package externe ou passer les variables au moment du lancement du serveur. ⬇️ <br>
Ne tenez pas compte du procain paragraphe/encart si ça vous embrouille et utilisez la première version de `getConnection()`.

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

⚠️ Pas d'espace entre les "=", pas de ";", tout est collé, des retours à la lignes sont effectués pour chaque nouvelle variable.
```
Maintenant, testons notre connexion.
```php
// On stock la connexion qui nous est retournée par getConnection()
$connexion = getConnection($db_host, $db_name, $db_user, $db_password);

// On stock une query basique dont on sait qu'elle devrait nous retourner qqch
$sql = "SELECT * FROM users";

// Cf. la doc, on utilise les méthodes de PDO
$query = $connexion->prepare($sql);
$query->execute();
$data = $query->fetchAll(PDO::FETCH_ASSOC);

// On affiche à l'écran le résultat (ça suppose d'avoir un serveur qui tourne, via : php -S localhost:8000 par exemple)
var_dump($data);
```
Et voilà. ✌️
