# Gitlab for Yunohost

[![Integration level](https://dash.yunohost.org/integration/gitlab.svg)](https://dash.yunohost.org/appci/app/gitlab)  
[![Install gitlab with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=gitlab)

> *This package allow you to install gitlab quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview

GitLab is a web-based Git-repository manager providing wiki, issue-tracking and CI/CD pipeline features, using an open-source license, developed by GitLab Inc.

**Shipped version:** 12.6.2

## Screenshots

![](https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/GitLab_running_11.0_%282018-07%29.png/300px-GitLab_running_11.0_%282018-07%29.png)

## Configuration

How to configure this app: 
- An admin panel
- The file: `/etc/gitlab/gitlab-persistent.rb` (use `sudo gitlab-ctl reconfigure` after any modification of this file)

## Documentation

 * Official documentation: https://docs.gitlab.com/ce/README.html

## YunoHost specific features

#### Multi-users support

Yes with LDAP support.

#### Supported architectures

* x86-64b - [![Build Status](https://ci-apps.yunohost.org/ci/logs/gitlab%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/gitlab/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/gitlab%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/gitlab/)
* Jessie x86-64b - [![Build Status](https://ci-stretch.nohost.me/ci/logs/gitlab%20%28Apps%29.svg)](https://ci-stretch.nohost.me/ci/apps/gitlab/)

## Limitations

* Not compatible with a 32-bit architecture.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/gitlab_ynh/issues
 * App website: https://gitlab.com
 * Upstream app repository: https://gitlab.com/gitlab-org/omnibus-gitlab - https://gitlab.com/gitlab-org/gitlab-ce
 * YunoHost website: https://yunohost.org/

---

Developers info
----------------

**Only if you want to use a testing branch for coding, instead of merging directly into master.**
Please do your pull request to the [testing branch](https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
or
sudo yunohost app upgrade gitlab -u https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
```

**More information on the documentation page:**  
https://yunohost.org/packaging_apps
