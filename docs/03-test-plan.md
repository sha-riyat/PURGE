# Plan de test

## Laboratoire virtuel

Hyper-V peut fournir une VM Windows et plusieurs VHDX de test. Cette phase vérifie le
logiciel de décision, pas la garantie physique d'une sanitization matérielle.

Scénarios :

1. un VHDX système et un VHDX de données ;
2. plusieurs VHDX dont un support de boot simulé ;
3. nom de modèle absent ;
4. capacité ou nombre de disques qui change entre deux inventaires ;
5. confirmation erronée ;
6. interruption et relance ;
7. journal inaccessible ;
8. simulation répétée : aucun secteur ne doit être modifié.

## Matrice physique minimale

- un HDD SATA de laboratoire ;
- un SSD SATA de laboratoire ;
- un SSD NVMe de laboratoire ;
- un modèle avec firmware différent ;
- un support verrouillé ou présentant une erreur contrôlée ;
- une machine avec deux disques internes ;
- au moins deux versions de firmware UEFI/stockage rencontrées dans le parc.

## Preuves à conserver

- version et hash de l'ISO ;
- modèle, numéro de série et firmware du support ;
- méthode choisie et outil exact ;
- sortie brute de l'outil, sans données utilisateur ;
- résultat de vérification ;
- rapport final signé ou hashé ;
- décision humaine en cas de `BLOCKED`.

## Tests négatifs obligatoires

Le produit doit refuser l'opération quand :

- seule une suppression de volume est possible ;
- un SSD ne supporte aucune méthode de purge approuvée ;
- une commande retourne un succès non vérifiable ;
- la clé USB apparaît parmi les cibles ;
- un disque est ajouté après confirmation ;
- l'opérateur tente de contourner la double confirmation.
