# Guide opérateur — version pilote

## Parcours le plus simple

1. Brancher la clé USB.
2. Ouvrir `Purge.cmd`.
3. Choisir l'un des trois parcours affichés.
4. Lire la machine, le disque, le modèle et la capacité affichés.
5. Confirmer uniquement si l'asset ID et le numéro de série correspondent à l'ordre de travail.
6. Laisser la machine terminer ou remettre le rapport à l'équipe technique si le statut est
   `BLOCKED` ou `FAIL`.

Le mot “purge” ne doit pas être interprété comme “suppression de tous les fichiers depuis
Windows”. Le parcours peut redémarrer vers l'environnement de récupération Windows, car un
disque système ne peut pas être rendu vierge de manière fiable pendant que Windows l'utilise.

## Ce que l'opérateur peut faire

Cette version est une version d'observation. Elle peut choisir le parcours, inventorier et
simuler. Les fournisseurs destructifs restent désactivés jusqu'à validation du laboratoire.

## Procédure

1. Brancher la clé PURGE sur le PC de laboratoire ou sur le poste à diagnostiquer.
2. Lancer `Purge.cmd`.
3. Choisir `Inventaire et simulation` pour un diagnostic sans risque.
4. Vérifier le modèle, le numéro de série, la capacité et le statut de chaque disque.
5. Remettre le manifeste à l'équipe technique si une information est absente ou inattendue.

## Ce qui doit arrêter la procédure

- un disque USB apparaît comme cible ;
- le nombre de disques ne correspond pas à l'étiquette du poste ;
- le modèle ou le numéro de série ne sont pas lisibles ;
- le poste contient un support supplémentaire non documenté ;
- la machine n'est pas celle indiquée sur l'ordre de travail.

Dans tous ces cas, ne pas improviser avec `diskpart`, un formatage ou un outil tiers. Une
élévation UAC, un mot de passe administrateur ou une politique d'entreprise ne doivent pas
être contournés.
Le statut attendu est `BLOCKED` et le support doit être repris par un technicien.
