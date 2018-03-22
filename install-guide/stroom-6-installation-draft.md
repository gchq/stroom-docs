# Stroom 6 Installation Guide [DRAFT] 

## Post-install hardening

### Before first run

#### Change database passwords

This change should be made in the `.env` configuration file.

  * `STROOM_DB_PASSWORD`
  * `STROOM_DB_ROOT_PASSWORD`

  * `STROOM_STATS_DB_ROOT_PASSWORD`
  * `STROOM_STATS_DB_PASSWORD`

  * `STROOM_AUTH_DB_PASSWORD`
  * `STROOM_AUTH_DB_ROOT_PASSWORD`

### On first run

#### Change the admin password

Change the admin password using Stroom, under `User` -> `Change password`. In a future release you will be required to change the admin password on first run.

#### Delete un-used users and API keys

  * If you're not using stats you can delete or disable the following:
    * the user `statsServiceUser`
    * the API key for `statsServiceUser`


#### Change the API keys

First generate new API keys. You can generate a new API key using Stroom, under `Tools` -> `API Keys`. The following need to be changed:

  * `STROOM_SECURITY_API_TOKEN`
    * This is the API token for user `stroomServiceUser`. 
    
Then stop Stroom and update the API key in the `.env` configuration file with the new value.