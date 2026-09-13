# PURGE WINDOWS

Outil Windows à parcours unique pour remettre un ordinateur à zéro avec le parcours
officiel de réinitialisation Windows.

## Parcours unique

Depuis le dossier du projet ou une clé de maintenance, lancer :

```text
Purge.cmd
```

Le programme :

1. vérifie l’édition et l’architecture de Windows ;
2. vérifie les droits administrateur ;
3. vérifie que Windows RE est disponible ;
4. inventorie les disques présents sans lire les fichiers utilisateurs ;
5. bloque si un support USB externe est connecté ou si le disque système n’est pas identifié de manière unique ;
6. demande la confirmation exacte `NETTOYER TOUS LES DISQUES` ;
7. ouvre le parcours officiel `Réinitialiser ce PC` ;
8. guide l’opérateur vers `Supprimer tout`, `Tous les lecteurs` et `Nettoyer complètement le lecteur` ;
9. laisse Windows redémarrer et terminer la réinitialisation ;
10. laisse la machine sur l’écran de première configuration, sans créer de compte.

Le dernier clic dans l’interface Windows reste volontaire : les libellés et options de
réinitialisation varient entre Windows 10 et Windows 11, et le script ne simule pas un clic
destructif à l’aveugle.

## Résultats

Chaque lancement produit un rapport JSON dans `output` avec un statut :

- `READY_FOR_OPERATOR_CONFIRMATION` : précontrôle terminé, aucune modification effectuée ;
- `RESET_PENDING` : confirmation reçue, le parcours Windows est ouvert ;
- `CANCELLED` : la confirmation exacte n’a pas été saisie ;
- `BLOCKED` : une condition de sécurité empêche le lancement.

Après la réinitialisation, l’écran attendu est l’écran de première configuration Windows.
Le programme ne crée pas le prochain compte utilisateur.

## Vérification sans lancer le parcours

Pour vérifier uniquement les préconditions :

```powershell
Set-Location 'C:\Users\shariyat\work\personal\PURGE'
.\scripts\Start-Purge.ps1 -CheckOnly
```

Cette commande ne modifie aucun disque et écrit seulement un rapport de précontrôle.

## Plusieurs disques internes

PURGE inventorie chaque disque interne avant le lancement. Si un disque interne
supplémentaire n’a aucun volume accessible, ou si son identité matérielle est incomplète,
le parcours est bloqué : la réinitialisation Windows ne peut alors pas garantir que ce disque
est couvert.

Quand plusieurs volumes internes accessibles sont présents, l’opérateur doit sélectionner
explicitement `Supprimer les fichiers de tous les lecteurs` / `Tous les lecteurs` dans les
paramètres de réinitialisation. Il doit aussi activer `Nettoyage des données` / `Nettoyer
complètement le lecteur`. Si Windows ne propose pas l’option `Tous les lecteurs`, il faut
annuler et ne pas poursuivre.

Les supports USB restent bloqués et ne sont jamais considérés comme des cibles de ce parcours.

## Limites

Cette version utilise le parcours Windows intégré et ne prétend pas fournir une preuve
forensic universelle pour tous les types de SSD/NVMe. Le nettoyage Windows est un parcours
grand public : il ne constitue pas une preuve d’effacement conforme à une norme gouvernementale
ou industrielle. Elle ne contourne pas UAC, BitLocker,
les politiques d’entreprise ou les restrictions de récupération. Si Windows RE est absent,
si un disque est ambigu ou si un support externe est connecté, le résultat est `BLOCKED`.

Les anciennes expériences WinPE/Hyper-V restent hors de ce parcours et ne sont pas requises
pour lancer ce flux Windows-native.

## Références

- Réinitialisation d’un PC Windows : <https://learn.microsoft.com/en-us/windows-hardware/service/desktop/resetting-the-pc>
- Push-button reset : <https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/push-button-reset-overview?view=windows-11>
- NIST SP 800-88 Rev. 2 : <https://csrc.nist.gov/pubs/sp/800/88/r2/final>
