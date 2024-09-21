<!--
Ohart ongi: README hau automatikoki sortu da <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>ri esker
EZ editatu eskuz.
-->

# GitLab YunoHost-erako

[![Integrazio maila](https://dash.yunohost.org/integration/gitlab.svg)](https://ci-apps.yunohost.org/ci/apps/gitlab/) ![Funtzionamendu egoera](https://ci-apps.yunohost.org/ci/badges/gitlab.status.svg) ![Mantentze egoera](https://ci-apps.yunohost.org/ci/badges/gitlab.maintain.svg)

[![Instalatu GitLab YunoHost-ekin](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=gitlab)

*[Irakurri README hau beste hizkuntzatan.](./ALL_README.md)*

> *Pakete honek GitLab YunoHost zerbitzari batean azkar eta zailtasunik gabe instalatzea ahalbidetzen dizu.*  
> *YunoHost ez baduzu, kontsultatu [gida](https://yunohost.org/install) nola instalatu ikasteko.*

## Aurreikuspena

Git-repository manager providing wiki, issue-tracking and CI/CD pipeline features

**Paketatutako bertsioa:** 17.4.0~ynh1

**Demoa:** <https://gitlab.com/explore>

## Pantaila-argazkiak

![GitLab(r)en pantaila-argazkia](./doc/screenshots/GitLab_running_11.0_(2018-07).png)

## Dokumentazioa eta baliabideak

- Aplikazioaren webgune ofiziala: <https://gitlab.com>
- Administratzaileen dokumentazio ofiziala: <https://docs.gitlab.com/>
- Jatorrizko aplikazioaren kode-gordailua: <https://gitlab.com/gitlab-org/omnibus-gitlab - https://gitlab.com/gitlab-org/gitlab>
- YunoHost Denda: <https://apps.yunohost.org/app/gitlab>
- Eman errore baten berri: <https://github.com/YunoHost-Apps/gitlab_ynh/issues>

## Garatzaileentzako informazioa

Bidali `pull request`a [`testing` abarrera](https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing).

`testing` abarra probatzeko, ondorengoa egin:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
edo
sudo yunohost app upgrade gitlab -u https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
```

**Informazio gehiago aplikazioaren paketatzeari buruz:** <https://yunohost.org/packaging_apps>
