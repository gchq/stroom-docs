# Stroom 6 Installation Guide [DRAFT] 

## Post-install hardening

### Change API tokens

  * `STROOM_SECURITY_API_TOKEN`
    * This is the API token for user `stroomServiceUser`. You'll need to generate a new API key for this user and paste it into the `.env` configuration file. You can generate a new API key using Stroom, under `Tools` -> `API Keys`.

### Change database password

  * `STROOM_DB_PASSWORD`
  * `STROOM_DB_ROOT_PASSWORD`

  * `STROOM_STATS_DB_ROOT_PASSWORD`
  * `STROOM_STATS_DB_PASSWORD`

  * `STROOM_AUTH_DB_PASSWORD`
  * `STROOM_AUTH_DB_ROOT_PASSWORD`

### Delete un-used users and API keys

  * If you're not using stats you can delete or disable:
    * the user `statsServiceUser`
    * the API key for `statsServiceUser`


