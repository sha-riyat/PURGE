# Préparation du laboratoire

## Pré-requis

- poste technicien Windows avec droits administrateur ;
- Windows ADK et module Windows PE correspondant à la version cible ;
- Hyper-V activé par l'équipe infrastructure ;
- une VM et des VHDX de test dédiés ;
- aucune donnée réelle dans les VHDX de test.

Avant toute installation, lancer le diagnostic non destructif :

```powershell
.\scripts\Test-HyperVReadiness.ps1 -OutputPath .\output\hyperv-readiness.json
```

Le verdict attendu pour poursuivre est `READY_FOR_HYPER_V_LAB`. Si le résultat est
`BLOCKED_OR_NEEDS_ADMIN_CHECK`, il faut ouvrir une console PowerShell administrateur et
vérifier la virtualisation matérielle, le firmware et les fonctionnalités Windows avant de
retenter.

## Image WinPE

La construction suivra la procédure Microsoft :

```text
copype amd64 C:\PURGE-WinPE
```

Le build reproductible du projet est préparé dans :

```powershell
.\scripts\Build-PurgeWinPE.ps1
```

Il doit être lancé depuis une console PowerShell administrateur. Il crée une image amd64,
ajoute WMI, Scripting, NetFX et PowerShell, copie les scripts PURGE dans l'image et produit
une ISO sous `output\PurgeWinPE.iso`. Le script ne cible aucun disque physique.

Le script d'inventaire sera ajouté à l'image, puis l'ISO sera produit avec
`MakeWinPEMedia`. Le hash de l'ISO doit être consigné dans le rapport de build.

La clé USB de production ne doit pas être construite depuis une machine qui contient des
outils non vérifiés. La construction doit être reproductible et le contenu de la clé doit
être comparé à l'empreinte attendue.

## VM headless

La VM sert à valider le boot, l'interface, la détection, la confirmation et les journaux.
Elle ne valide pas à elle seule les commandes de sanitization d'un vrai contrôleur SSD.

Hyper-V est maintenant activé sur l'hôte `RIYAT` et le contrôle administrateur a confirmé
qu'il n'y a encore aucune VM de test. Le script prévu pour créer le labo est :

```powershell
.\scripts\New-PurgeHyperVLab.ps1 -IsoPath .\output\PurgeWinPE.iso
```

Il crée uniquement des VHDX neufs, sans carte réseau et sans attachement de disque
physique. Il refuse de modifier une VM existante.

La construction de l'ISO est actuellement `BLOCKED` sur l'hôte de développement : DISM
monte bien `boot.wim`, mais l'ajout du premier composant `WinPE-WMI` échoue avec
`PEProvider 0x80070057` / code 87. Les versions ADK/WinPE sont revenues à la build
cohérente `10.0.26100.2454`, les chemins contenant `Program Files (x86)` sont cités, et le
montage temporaire court a été démonté proprement. La prochaine tentative doit être faite
depuis un hôte Windows supporté de la même génération que l'ADK, puis l'ISO et son hash
doivent être vérifiés avant de créer la VM.

## Critère avant ajout d'un fournisseur destructif

Un fournisseur ne peut être ajouté que si l'équipe dispose de :

- la documentation de la commande pour le modèle concerné ;
- un support de test dédié ;
- la sortie complète de succès et d'échec ;
- une vérification post-opération définie ;
- une procédure de reprise après coupure ;
- une décision explicite sur le niveau `Clear`, `Purge` ou `Destroy`.
