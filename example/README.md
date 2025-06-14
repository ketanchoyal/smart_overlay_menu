# Focused Overlay Example

Cette application d'exemple démontre l'utilisation du composant `FocusedOverlayHolder`, un widget générique qui permet d'afficher des overlays personnalisés au-dessus et/ou en-dessous d'un widget principal.

## Fonctionnalités démontrées

- **Widget au-dessus uniquement** : Affichage d'un widget au-dessus du widget principal
- **Widget en-dessous uniquement** : Affichage d'un widget en-dessous du widget principal
- **Widgets multiples** : Affichage simultané de widgets au-dessus et en-dessous
- **Contrôle programmatique** : Ouverture de l'overlay via un contrôleur
- **Repositionnement automatique** : Le widget principal se repositionne automatiquement si les overlays dépassent les bords de l'écran

## Lancement de l'exemple

```bash
cd example
flutter run
```

## Instructions d'utilisation

- **Long press** sur les widgets colorés pour afficher les overlays
- **Appuyez sur le bouton** "Ouvrir overlay programmatiquement" pour tester le contrôle via contrôleur
- **Testez le repositionnement** en faisant un long press sur le widget orange en bas de l'écran

L'exemple montre comment le composant `FocusedOverlayHolder` peut remplacer l'ancien système de menus par des widgets totalement personnalisables.
