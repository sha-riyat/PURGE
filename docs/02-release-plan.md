# Séquence de release

## Release 0 — Inventaire et simulation (livrée ici)

**But :** rendre visibles les disques et les décisions sans toucher aux données.

Livrables : script PowerShell, manifeste JSON, simulation, politique, documentation.

Stop rule : aucune mutation de disque détectée dans les tests.

## Release 1 — Image WinPE et laboratoire virtuel

**But :** démarrer depuis une ISO et éprouver le parcours dans une VM Hyper-V.

Livrables : image WinPE reproductible, ISO, VHDX de test, script de test automatisé,
journaux de boot et capture des états.

Stop rule : tous les disques virtuels de test sont correctement classés et aucun disque
du poste hôte n'est visible comme cible.

## Release 2 — Adaptateurs d'effacement en mode laboratoire

**But :** intégrer des fournisseurs strictement contrôlés et vérifiables.

Livrables : adaptateur HDD, adaptateur SATA SSD, adaptateur NVMe, contrat de sortie commun,
tests de succès, d'échec, de coupure et de support non compatible.

Stop rule : un adaptateur qui ne peut pas produire une preuve vérifiable ne peut pas
retourner `PASS`.

## Release 3 — Pilote physique

**But :** valider le matériel réellement présent dans le parc.

Livrables : matrice modèle/firmware/méthode, procédure de blocage et rapport d'acceptation.

Stop rule : aucun modèle non couvert ne passe en production.

## Release 4 — Production contrôlée

**But :** usage plug-and-play par les équipes, avec journal et reprise d'erreur.

Livrables : clé signée, guide une page, formulaire d'asset, archive des rapports,
procédure de retrait/destruction des supports bloqués.

Stop rule : toute évolution de firmware, de WinPE ou d'un outil constructeur déclenche une
revalidation de la matrice.
