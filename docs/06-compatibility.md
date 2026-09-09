# Compatibilité réellement visée

## Ce qui est raisonnablement portable

| Élément | Cible | Condition |
| --- | --- | --- |
| Lanceur USB | Windows 10/11 x64 | PowerShell Windows présent et exécution autorisée |
| Inventaire | Windows 10/11 x64 | accès WMI/CIM disponible |
| Ouverture du parcours Reset | Windows 10/11 client | page Recovery disponible |
| Diagnostic WinRE | Windows 10/11 client | `reagentc.exe` disponible |
| Nettoyage support non système | dépend du média | administrateur et fournisseur validé |
| Purge disque système | dépend du PC | WinRE/WinPE, BitLocker et méthode vérifiable |

## Ce qui ne peut pas être promis

- exécution avec un compte standard sans élévation lorsque l'opération modifie un disque ;
- contournement d'AppLocker, WDAC, antivirus, UAC ou politique d'entreprise ;
- fonctionnement si l'exécution depuis USB est interdite ;
- purge d'un disque système sans redémarrage ou environnement hors ligne ;
- traitement universel de tous les SSD sans tenir compte du modèle et du firmware ;
- résultat `Purge` à partir de `diskpart clean all` sur n'importe quel SSD ;
- création ou activation d'Hyper-V sans droits administrateur et sans virtualisation disponible.

## Expérience à présenter à l'équipe non technique

Le produit peut rester très simple à l'écran :

```text
1  Réinitialiser Windows pour donner le PC
2  Nettoyer une clé ou un disque externe
3  Purger tout le PC
4  Vérifier seulement
```

La complexité reste dans le diagnostic et dans le rapport. Elle ne doit pas être cachée par
un bouton qui promet un résultat impossible sur une machine non compatible.
