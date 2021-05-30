# GitLab pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/gitlab.svg)](https://dash.yunohost.org/appci/app/gitlab) ![](https://ci-apps.yunohost.org/ci/badges/gitlab.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/gitlab.maintain.svg)  
[![Installer GitLab avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=gitlab)

*[Read this readme in english.](./README.md)*
*[Lire ce readme en français.](./README_fr.md)*

> *This package allows you to install GitLab quickly and simply on a YunoHost server.
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Vue d'ensemble

Gestionnaire de dépôts Git proposant des fonctionnalités de wiki, suivi de bugs et de pipeline CI/CD.

**Version incluse:** 13.12.1~ynh1

**Démo :** https://gitlab.com/explore

## Captures d'écran

![](./doc/screenshots/GitLab_running_11.0_(2018-07).png)

## Documentations et ressources

* Site officiel de l'app : https://gitlab.com
* Documentation officielle utilisateur : https://yunohost.org/fr/app_gitlab
* Documentation officielle de l'admin : https://docs.gitlab.com/
* Dépôt de code officiel de l'app :  https://gitlab.com/gitlab-org/omnibus-gitlab - https://gitlab.com/gitlab-org/gitlab
* Documentation YunoHost pour cette app : https://yunohost.org/app_gitlab
* Signaler un bug: https://github.com/YunoHost-Apps/gitlab_ynh/issues

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
or
sudo yunohost app upgrade gitlab -u https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
```

**Plus d'infos sur le packaging d'applications:** https://yunohost.org/packaging_apps