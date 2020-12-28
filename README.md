# GitLab for YunoHost

[![Integration level](https://dash.yunohost.org/integration/gitlab.svg)](https://dash.yunohost.org/appci/app/gitlab) ![](https://ci-apps.yunohost.org/ci/badges/gitlab.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/gitlab.maintain.svg)    
[![Install GitLab with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=gitlab)

*[Lire ce readme en français.](./README_fr.md)*

> *This package allow you to install GitLab quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview

GitLab is a web-based Git-repository manager providing wiki, issue-tracking and CI/CD pipeline features, using an open-source license, developed by GitLab Inc.

**Shipped version:** 13.7.0

## Screenshots

![](https://upload.wikimedia.org/wikipedia/commons/9/9a/GitLab_running_11.0_%282018-07%29.png)

## Configuration

How to configure GitLab: 

- With the GitLab admin panel.
- By editing the configuration file `/etc/gitlab/gitlab-persistent.rb` (use `sudo gitlab-ctl reconfigure` after any modification of this file).

## Documentation

 * Official documentation: https://docs.gitlab.com/ce/README.html
 * YunoHost documentation: https://yunohost.org/#/app_gitlab

## YunoHost specific features

#### Multi-users support

* Are LDAP and HTTP auth supported? **Yes**
* Can the app be used by multiple users? **Yes**

#### Supported architectures

* x86-64 - [![Build Status](https://ci-apps.yunohost.org/ci/logs/gitlab%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/gitlab/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/gitlab%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/gitlab/)

## Limitations

* GitLab is not compatible with 32-bit architectures.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/gitlab_ynh/issues
 * App website: https://gitlab.com
 * Upstream app repository: https://gitlab.com/gitlab-org/omnibus-gitlab - https://gitlab.com/gitlab-org/gitlab-ce
 * YunoHost website: https://yunohost.org/

---

## Developers info

Please do your pull request to the [testing branch](https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
or
sudo yunohost app upgrade gitlab -u https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
```
