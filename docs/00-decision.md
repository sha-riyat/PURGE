# Décision d'architecture

## Besoin

Préparer des PC Windows destinés à un autre utilisateur sans laisser de données
confidentielles récupérables, avec une procédure compréhensible par une équipe non
technique mais contrôlée par l'équipe technique.

## Options étudiées

### A. Script lancé dans Windows

Rejeté comme solution principale. Le système est en cours d'exécution, certains fichiers
sont verrouillés, les autres disques peuvent être oubliés et la méthode de suppression
varie selon le support. Un script de suppression ne sait pas prouver que les blocs hors
zone adressable ont été traités.

### B. Reset this PC / réinstallation Windows

Acceptable pour une préparation standard de poste, mais insuffisant comme preuve unique
pour des données sensibles. Il peut aussi ne traiter que le disque ou le chemin prévu par
le scénario et ne remplace pas un inventaire de tous les supports physiques.

### C. Clé Linux générique avec overwrite

Utile pour certains disques magnétiques sous une politique `Clear`, mais inadaptée comme
méthode universelle pour SSD/NVMe. Elle risque aussi de ne pas connaître correctement les
commandes constructeur et les cas de verrouillage matériel.

### D. Clé WinPE PURGE avec adaptateurs de sanitization

Choisie. WinPE fournit un environnement hors ligne supporté par Microsoft et permet de
packager une interface et des journaux simples. L'outil ne prétend pas effacer un support
avec une technique qu'il ne sait pas vérifier. Les commandes de sanitization sont isolées
par type de support et peuvent être remplacées par un outil constructeur signé lorsque
nécessaire.

## Solution choisie

Le produit est une application de lancement depuis USB, et non une promesse de “clé
magique” qui contourne les protections Windows. L'utilisateur n'a pas à modifier le BIOS ou
l'UEFI dans le parcours normal, mais l'application ne peut pas supprimer les protections
du système sans autorisation.

### Menu utilisateur

Le menu expose seulement trois décisions :

| Choix affiché | Parcours | Limite annoncée |
| --- | --- | --- |
| Nettoyage Windows | ouvre la réinitialisation Windows | dépend de WinRE et traite le périmètre prévu par Windows |
| Support amovible | cible un disque non système confirmé | nécessite administrateur et méthode vérifiable pour le média |
| Purge complète du PC | redémarre hors ligne si le chemin est disponible | bloque si WinRE/WinPE, BitLocker, firmware ou support ne permettent pas une preuve |

Le lanceur doit être utilisable sans connaître le vocabulaire technique, mais il ne doit pas
masquer les blocages techniques à l'équipe responsable.

### Couche 1 — Lancement depuis Windows

- `Purge.cmd` appelle Windows PowerShell présent sur Windows 10/11 ;
- l'application détecte l'édition et la version de Windows ;
- l'application détecte si elle est élevée ;
- le mode diagnostic reste disponible sans mutation ;
- une opération nécessitant des droits demande l'élévation UAC normale ;
- aucun contournement d'UAC, AppLocker, BitLocker, Secure Boot ou politique d'entreprise.

### Couche 2 — Boot et sécurité opérateur

- WinPE x64, démarré en UEFI ;
- clé PURGE identifiable par son numéro de série et son hash de build ;
- réseau désactivé par défaut ;
- aucune action destructive au démarrage ;
- mode simulation disponible sans privilège d'effacement ;
- double confirmation avec saisie de l'identifiant du poste et du mot `PURGE` ;
- option future de validation à deux personnes pour les postes classifiés.

### Couche 3 — Inventaire

Le manifeste contient uniquement des métadonnées nécessaires à la décision : modèle,
fabricant, numéro de série, bus, type de média, capacité, état de verrouillage, volumes,
disque système et disque de démarrage. Les noms de fichiers et le contenu utilisateur ne
sont jamais collectés.

### Couche 4 — Politique par support

- **NVMe/SSD** : priorité aux commandes de sanitization du contrôleur (format avec User
  Data Erase ou Cryptographic Erase) ou à l'outil constructeur approuvé ; pas de
  déclaration `PURGE` sur la base d'un overwrite logiciel seul.
- **HDD** : commande d'effacement matériel si disponible ; sinon overwrite complet
  seulement si la politique de classification autorise le niveau `Clear`.
- **Support verrouillé, inconnu ou en erreur** : `BLOCKED`, retrait et destruction ou
  traitement par une filière spécialisée.
- **Clé PURGE et autres supports USB** : exclus par défaut ; une exception doit être
  explicitement configurée et affichée.

### Couche 5 — Vérification et preuve

Chaque support reçoit un résultat indépendant : `PASS`, `FAIL` ou `BLOCKED`. La preuve
comprend la méthode, le résultat fourni par le contrôleur ou l'outil, la vérification
post-opération et l'empreinte du build de l'outil. Un `PASS` n'est jamais déduit du seul
fait que Windows redémarre.

## Limite de garantie

Une clé logicielle ne peut pas garantir la récupération impossible si le support est
défectueux, si le constructeur ne documente pas la sanitization, si un composant de
stockage amovible a été oublié, ou si le niveau d'exigence impose la destruction physique.
Dans ces cas, la sortie correcte est `BLOCKED` et non un succès optimiste.
