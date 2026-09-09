# Parcours Windows-native unique

## Objectif

Remettre un ordinateur Windows à zéro avec un seul parcours opérateur : supprimer les
comptes, applications, paramètres et données précédents, puis laisser Windows afficher son
écran de première configuration sans créer de compte.

## Parcours

```text
Purge.cmd
  -> précontrôle
  -> inventaire des disques
  -> confirmation NETTOYER
  -> Windows Reset / Remove everything
  -> nettoyage des données lorsque l’option est proposée
  -> redémarrages Windows
  -> écran de première configuration
```

## Garde-fous internes

- console administrateur obligatoire pour continuer ;
- Windows RE doit être confirmé comme activé ;
- le disque système doit être identifié de manière unique ;
- les supports USB externes connectés bloquent le parcours ;
- aucune lecture des noms ou du contenu des fichiers utilisateur ;
- aucun compte n’est créé par le programme ;
- aucune simulation de clic destructif dans les paramètres Windows ;
- un rapport JSON est écrit avant l’ouverture du parcours Windows.

## Résultats avant redémarrage

| Statut | Signification |
| --- | --- |
| `READY_FOR_OPERATOR_CONFIRMATION` | Précontrôle terminé, aucune modification effectuée |
| `CANCELLED` | Confirmation exacte absente, aucune modification effectuée |
| `BLOCKED` | Une précondition de sécurité n’est pas satisfaite |
| `RESET_PENDING` | Confirmation reçue et parcours Windows ouvert |

## Résultat attendu après Windows Reset

Le résultat attendu est l’écran de première configuration Windows. Le programme ne doit pas
créer de compte, ouvrir une session ou continuer l’assistant à la place du prochain
utilisateur.

## Limite de preuve

Le parcours Windows intégré est approprié pour remettre un PC à zéro, mais son option de
nettoyage ne constitue pas une garantie forensic universelle pour chaque contrôleur SSD ou
NVMe. Une politique imposant une sanitization matérielle doit être traitée par un fournisseur
adapté ; cette version ne la simule pas.
