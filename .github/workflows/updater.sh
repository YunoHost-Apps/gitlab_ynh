#!/bin/bash

#=================================================
# PACKAGE UPDATING HELPER
#=================================================

# This script is meant to be run by GitHub Actions
# The YunoHost-Apps organisation offers a template Action to run this script periodically
# Since each app is different, maintainers can adapt its contents so as to perform
# automatic actions when a new upstream release is detected.

#=================================================
# FETCHING LATEST RELEASE AND ITS ASSETS
#=================================================

current_version=$(yq ".version" manifest.toml | cut -d '~' -f 1 -)

# For the time being, let's assume the script will fail
echo "PROCEED=false" >> $GITHUB_ENV

/bin/bash ./upgrade-path.sh 16.9.0

version=$(yq ".version" manifest.toml | cut -d '~' -f 1 -)

echo "Current version: $current_version"
echo "Latest release from upstream: $version"
echo "VERSION=$version" >> "$GITHUB_ENV"
echo "REPO=$repo" >> "$GITHUB_ENV"
# For the time being, let's assume the script will fail
echo "PROCEED=false" >> "$GITHUB_ENV"

# Proceed only if the retrieved version is greater than the current one
if ! dpkg --compare-versions "$current_version" "lt" "$version" ; then
	echo "::warning ::No new version available"
	exit 0
# Proceed only if a PR for this new version does not already exist
elif git ls-remote -q --exit-code --heads https://github.com/$GITHUB_REPOSITORY.git ci-auto-update-v$version ; then
	echo "::warning ::A branch already exists for this update"
	exit 0
fi


#=================================================
# UPDATE SOURCE FILES
#=================================================


#=================================================
# SPECIFIC UPDATE STEPS
#=================================================

# Any action on the app's source code can be done.
# The GitHub Action workflow takes care of committing all changes after this script ends.

#=================================================
# GENERIC FINALIZATION
#=================================================

# No need to update the README, yunohost-bot takes care of it

# The Action will proceed only if the PROCEED environment variable is set to true
echo "PROCEED=true" >> $GITHUB_ENV
exit 0