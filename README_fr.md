# GitLab pour YunoHost

[![Integration level](https://dash.yunohost.org/integration/gitlab.svg)](https://dash.yunohost.org/appci/app/gitlab) ![](https://ci-apps.yunohost.org/ci/badges/gitlab.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/gitlab.maintain.svg)    
[![Installer GitLab pour YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=gitlab)

*[Read this readme in english.](./README.md)* 

> *Ce package vous permet d'installer GitLab rapidement et simplement sur un serveur YunoHost.  
Si vous n'avez pas YunoHost, regardez [ici](https://yunohost.org/#/install) pour savoir comment l'installer et en profiter.*

## Vue d'ensemble

GitLab est un gestionnaire Web de dépôt Git fournissant des fonctionnalités de wiki, de rapports de bugs et de pipeline CI/CD. GitLab est une application open source développée par GitLab Inc.

**Version incluse :** 13.9.0

## Captures d'écran

![](https://upload.wikimedia.org/wikipedia/commons/9/9a/GitLab_running_11.0_%282018-07%29.png)

## Configuration

Comment configurer GitLab :

- Avec le panneau d'administration de GitLab.
- En éditant le fichier de configuration `/etc/gitlab/gitlab-persistent.rb` et en éxécutant la commande `sudo gitlab-ctl reconfigure` pour réactualiser la configuration.

## Documentation

 * Documentation officielle : https://docs.gitlab.com/ce/README.html
 * Documentation YunoHost : https://yunohost.org/#/app_gitlab_fr

## Caractéristiques spécifiques YunoHost

#### Support multi-utilisateurs

* L'authentification LDAP et HTTP est-elle prise en charge ? **Oui**
* L'application peut-elle être utilisée par plusieurs utilisateurs ? **Oui**

#### Architectures supportées

* x86-64 - [![Build Status](https://ci-apps.yunohost.org/ci/logs/gitlab%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/gitlab/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/gitlab%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/gitlab/)

## Limitations

* L'application GitLab n'est pas compatible avec les architectures 32-bit.

## Liens

 * Signaler un bug : https://github.com/YunoHost-Apps/gitlab_ynh/issues
 * Site de l'application : https://gitlab.com
 * Dépôt de l'application principale : https://gitlab.com/gitlab-org/omnibus-gitlab - https://gitlab.com/gitlab-org/gitlab-ce
 * Site web YunoHost : https://yunohost.org/

---

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
or
sudo yunohost app upgrade gitlab -u https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
```
