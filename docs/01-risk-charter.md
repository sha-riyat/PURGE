# Cahier de risques et critères de qualité

## Utilisateurs

- opérateur non technique qui suit l'écran et le guide papier ;
- technicien qui prépare la clé et examine les rapports ;
- responsable sécurité ou conformité qui accepte le risque résiduel ;
- repreneur du PC, qui ne doit pas recevoir les données de l'ancien utilisateur.

## Risques prioritaires

| ID | Risque | Conséquence | Garde-fou |
| --- | --- | --- | --- |
| R1 | Mauvais disque ciblé | Perte irrécupérable d'un poste ou de la clé | inventaire, exclusion USB, confirmation par numéro de série |
| R2 | SSD traité par overwrite naïf | résidus récupérables hors zone adressable | commande contrôleur/constructeur ou blocage |
| R3 | disque absent de l'inventaire | données oubliées sur un second support | comparaison bus/capacité/firmware, revue opérateur |
| R4 | résultat non vérifié | faux certificat de purge | états distincts `PASS`/`FAIL`/`BLOCKED` |
| R5 | clé ou firmware altéré | outil non fiable | hash de build, signature, version affichée |
| R6 | coupure de courant pendant l'opération | support dans un état inconnu | reprise sûre, résultat final `FAIL` jusqu'à nouvelle vérification |
| R7 | journal contenant des données sensibles | fuite secondaire | métadonnées uniquement, pas de chemins ni de contenu |
| R8 | utilisateur lance l'outil sur son propre PC | perte non intentionnelle | mode simulation par défaut et confirmation hors du simple clic |

## Définition de “bon assez pour pilote”

- aucun appel destructif en mode `Inventory` ou `Simulate` ;
- l'outil détecte et affiche tous les supports visibles dans le laboratoire ;
- la clé d'amorçage est exclue automatiquement ;
- les tests de confirmation empêchent les fautes de frappe et les identifiants incohérents ;
- les scénarios d'échec produisent `BLOCKED` ou `FAIL`, jamais `PASS` ;
- les rapports sont lisibles sur une autre machine et ne contiennent pas de fichier utilisateur ;
- les opérations réelles restent désactivées tant que la matrice physique n'est pas validée.

## Définition de “bon assez pour production”

- build WinPE reproductible et signé ;
- test VM complet de l'interface, de la politique et de la reprise ;
- test physique HDD, SATA SSD et NVMe avec supports de laboratoire ;
- méthode approuvée par modèle ou par famille de modèles, pas seulement par interface ;
- rapport archivé avec l'asset ID et l'opérateur ;
- parcours de blocage documenté : retrait, destruction ou outil constructeur ;
- acceptation formelle du risque résiduel par le responsable désigné.

## Règles d'arrêt

On arrête et on marque `BLOCKED` si :

- le disque de la clé n'est pas identifiable ;
- le nombre de supports change après l'inventaire initial ;
- le fabricant/modèle ou la capacité ne correspondent pas à l'inventaire confirmé ;
- le support signale un verrouillage, une erreur SMART critique ou une commande non supportée ;
- l'alimentation, le contrôleur ou l'outil d'effacement retourne un état ambigu ;
- l'opérateur ne peut pas produire un rapport final vérifiable.
