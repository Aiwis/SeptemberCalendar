# SeptemberCalendar

**Objectif**

Créer une application qui enregistre dans la galerie du téléphone un calendrier du mois de septembre avec une photo en fond sélectionnée par l’utilisateur.

**Actions effectuées**

- Ayant consulté les applications de Pictarine pour les cartes de Noël/Halloween, j’ai accroché avec l’UX à écran unique. Je me suis donc basée sur ce même principe pour le test technique.
- Ajout d’une animation sur la vue du calendrier pour plus de confort lors de la sélection de la photo
- Pour l’image, j’ai décidé d’utiliser le crop proposé par le framework Photos (grâce à la taille souhaitée et au content mode). L’image sauvegardée est exactement la même quel que soit le device, et bien sûr la visualisation du calendrier dans l’app correspond à l’image finale.
- Après avoir fait tester mon app par des amis, j’ai rajouté les fonctionnalités suivantes :
    - Je me suis rendue compte que naturellement, ils tapaient sur le placeholder -> j’affiche la galerie full screen dans ce cas
    - On veut toujours voir le calendrier final après une action de sauvegarde -> j’ai rajouté la possibilité de lancer directement l’app Photos.
- J’ai fait le choix de n’utiliser aucune librairie

**Pour aller plus loin...**
- Résoudre le problème d’animation lorsqu’on tape sur le placeholder : toute l’animation étant basée sur le content offset de la collection view, je n’ai pas eu le temps de réadapter tout ce système pour faire disparaître le calendrier en restant avec un contentOffset de zéro.
- Optimisation des process de traitement d’image (comparer les possibilités offertes par CoreGraphics, Photos, CoreImage), mieux gérer un système de cache.
- Permettre à l’utilisateur de crop l’image comme il le souhaite
- Ajouter un color picker pour choisir la couleur de fond du calendrier, par exemple quand on tape sur le fond du calendrier on a une vue qui s’ouvre entre le calendrier et la galerie avec une palette de couleurs et qui permet de visualiser directement le rendu.
- Ajouter des tests d’UI sur l’animation et des tests unitaires si on va plus loin dans le traitement d’image.

![alt tag](https://raw.githubusercontent.com/Aiwis/SeptemberCalendar/master/IMG_1679.jpg)
