# Stroom 6 Installation Guide

We would welcome feedback on this documentation.

## Running on a single box

### Running a release

Download a [release](https://github.com/gchq/stroom-resources/releases), for example [Stroom Core v6.0 Beta 3](https://github.com/gchq/stroom-resources/releases/download/stroom_core-v6.0-beta.3/stroom_core_v6.0-beta.3.tar.gz), unpack it, and run the `start.sh` script. When you've given it some time to start up go to `http://localhost/stroom`. There's a `README.md` file inside the tar.gz with more information.

## Post-install hardening

### Before first run

#### Change database passwords

If you don't do this before the first run of Stroom then the passwords will already be set and you'll have to change them on the database manually, and then change the `.env`.

This change should be made in the `.env` configuration file. If the values are not there then this service is not included in your Stroom stack and there is nothing to change.

- `STROOM_DB_PASSWORD`
- `STROOM_DB_ROOT_PASSWORD`

- `STROOM_STATS_DB_ROOT_PASSWORD`
- `STROOM_STATS_DB_PASSWORD`

- `STROOM_AUTH_DB_PASSWORD`
- `STROOM_AUTH_DB_ROOT_PASSWORD`

- `STROOM_ANNOTATIONS_DB_PASSWORD`
- `STROOM_ANNOTATIONS_DB_ROOT_PASSWORD`

### On first run

#### Create yourself an account

After first logging in as `admin` you should create yourself a normal account (using your email address) and add yourself to the `Administrators` group. You should then log out of `admin`, log in with your new administrator account and then disable the `admin` account. 

If you decide to use the `admin` account as your normal account you might find yourself locked out. The `admin` account has no associated email address, so the Reset Password feature will not work if your account is locked. It might become locked if you enter your password incorrectly too many times.

#### Delete un-used users and API keys

- If you're not using stats you can delete or disable the following:
  - the user `statsServiceUser`
  - the API key for `statsServiceUser`

#### Change the API keys

First generate new API keys. You can generate a new API key using Stroom, under `Tools` -> `API Keys`. The following need to be changed:

- `STROOM_SECURITY_API_TOKEN`

  - This is the API token for user `stroomServiceUser`.

Then stop Stroom and update the API key in the `.env` configuration file with the new value.

## Troubleshooting

### I'm trying to use certificate logins (PKI) but I keep being prompted for the username and password!
You need to be sure of several things:
- When a user arrives at Stroom the first thing Stroom does is redirect the user to the authentication service. This is when the certificate is checked. If this redirect doesn't use HTTPS then nginx will not get the cert and will not send it onwards to the authentication service. Remember that all of this stuff, apart from back-channel/service-to-service chatter, goes through nginx. The env var that needs to use HTTPS is STROOM_AUTHENTICATION_SERVICE_URL. Note that this is the var Stroom looks for, not the var as set in the stack, so you'll find it in the stack YAML.
- Are your certs configured properly? If nginx isn't able to decode the incoming cert for some reason then it won't pass anything on to the service.
- Is your browser sending certificates?

