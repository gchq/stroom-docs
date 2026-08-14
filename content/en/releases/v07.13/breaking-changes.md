---
title: "Breaking Changes"
linkTitle: "Breaking Changes"
weight: 30
date: 2026-08-13
tags: 
description: >
  Changes in Stroom version 7.13 that may break existing processing or ways of working.
---

{{% warning %}}
Please read this section carefully in case any of the changes affect you.
{{% /warning %}}

Most of the breaking changes in this release relate to authentication.
If you use an external identity provider, read [Audience Validation Is Now on by Default](#audience-validation-is-now-on-by-default) and [External Identity Provider Redirect URI](#external-identity-provider-redirect-uri) before upgrading.
If you use Stroom's internal identity provider, read [Duplicate Account Email Addresses](#duplicate-account-email-addresses) before upgrading, as the database migration will stop with an error if any are found.


## Stroom

Breaking changes relating to Stroom.

A number of configuration properties have been removed.
If any of these properties have been set in the YAML configuration file, Stroom will no longer boot.
Some properties have also had their default values changed.
See [Upgrade Notes]({{< relref "./upgrade-notes" >}}) for details.


### Authentication and Accounts

These changes affect Stroom's own sign-in and account handling.
Further authentication changes that affect Stroom-Proxy as well are in [Stroom & Stroom-Proxy](#stroom--stroom-proxy) below.


#### Duplicate Account Email Addresses

Account email addresses must now be unique, so that the 'Forgot password' flow can identify an account from the email address it is given.
An account may still have no email address at all, and any number of accounts may have none.

If two or more accounts currently share an email address then the database migration will stop with an error and Stroom will not start.
See [Upgrade Notes]({{< relref "./upgrade-notes#duplicate-account-email-addresses" >}}) for how to check for this before upgrading.


#### External Identity Provider Redirect URI

If you use an external identity provider, the client registered at that provider must now list Stroom's sign-in callback as an allowed redirect URI.
A provider that does not have it registered will reject the login.

See [Upgrade Notes]({{< relref "./upgrade-notes#external-identity-provider-redirect-uri" >}}).


#### Password Complexity Regex Removed

The internal identity provider no longer supports a character class complexity regex for passwords.
Password strength is now checked on the server using the same estimator the sign-in screen already showed, governed by `minimumPasswordStrength`, a score of 0 to 4 that defaults to 3.

If your configuration sets `passwordComplexityRegex` then remove it, as the property no longer exists and Stroom will not boot with it set.


#### Account Lockout Now Expires

An account locked by repeated failed sign-ins is now unlocked automatically after `stroom.security.identity.failedLoginLockDuration`, which defaults to 30 minutes, rather than staying locked until an administrator intervenes.
This removes a denial of service in which a few failed sign-ins could lock any named user out permanently.

Set the duration to `"PT0S"` if you need locks to be permanent.
Note that the duration governs locks that are already held rather than only new ones, so shortening it releases people who are already locked.

{{% see-also %}}
[User Accounts]({{< relref "docs/user-guide/security/user-accounts" >}})
{{% /see-also %}}


#### Administrators Can No Longer Lock Accounts

The three account states now have one owner each.
An administrator decides whether an account is _Enabled_, the sign-in process _Locks_ an account after repeated wrong passwords, and the account maintenance job marks an unused account _Inactive_.
An administrator can still undo the latter two, but can no longer apply them.

To prevent an account being used, disable it.

Two kinds of account are converted to disabled on upgrade, so review the accounts list afterwards.
See [Upgrade Notes]({{< relref "./upgrade-notes#review-disabled-accounts" >}}).


#### Account Fields Renamed

The account fields have been renamed in the REST API and in the accounts screen's quick filter.

| Was | Now |
| --- | --- |
| `loginFailures` | `failureCount` |
| `failureLocked` | `failureLockedMs`, the time the lock was applied |
| `status:Locked`, `status:Enabled`, `status:Inactive`, `status:Disabled` | `locked:true`, `enabled:true`, `inactive:true` |

The `status` term has been removed rather than renamed, as the three states are now independent of one another.
Update any saved quick filters or scripts that use `status:` or `loginFailures`.


#### Internal Identity Provider Request Validation

The internal identity provider's authorization endpoint now requires `response_type=code`, a `nonce` and the `openid` scope, and rejects a request that omits any of them.
Stroom's own sign-in sends all three, so no change is needed for a normal deployment.

If you have set `requestScopes` to an empty list then sign-in will now fail, as Stroom omits the `scope` parameter entirely.
Restore the default, or ensure the list contains `openid`.


#### Removed `email.allowPasswordResets` Property

This property has been removed, so Stroom will not boot if it is set.
Nothing read it, so if you set it to `false` believing it switched password reset emails off, it did not.
Password resets are governed by `allowPasswordResets` under the password policy section.


#### CSRF Checks on Browser Requests

Cross site request forgery checks now apply to state-changing requests whose credential was injected by an authenticating edge proxy, where previously only session cookie identities were checked.

An in-browser client that attaches its own bearer token must now send an `X-CSRF: 1` header on state-changing requests when `edgeAuthentication.enabled` is set.
Automation outside a browser, and traffic between cluster nodes, are unaffected.


### Other Changes

#### Removal of HBase Statistics

The HBase backed statistics store, i.e. `StroomStatsStore`, has been removed along with all of its configuration.
See [Upgrade Notes]({{< relref "./upgrade-notes" >}}) for the properties concerned.


#### Removal of the ScyllaDB State Store

The ScyllaDB backed state store has been removed, along with the whole `state` configuration branch.
Use a Plan B store instead.


#### Standard Annotation Comments

Standard annotation comments are now content rather than configuration.
Any comments previously configured in the `standardComments` property will need to be saved as annotation comments.


#### JSON Parser Limits

The `JSONParser` pipeline element now applies limits to protect Stroom from very large or deeply nested documents.

| Property | Default | Effect |
| --- | --- | --- |
| `stringTruncateLength` | 10,000 | String values longer than this are truncated. |
| `maxStringLength` | 100,000,000 | A string value longer than this is a fatal error. |
| `maxDepth` | 500 | Nesting deeper than this is a fatal error. |

If you parse JSON containing string values longer than 10,000 characters then they will now be truncated unless you raise `stringTruncateLength`.

The underlying JSON library has also been uplifted to a new major version, so the output of the `JSONParser` element should be checked to confirm it is still as expected.


## Stroom-Proxy

There are no Stroom-Proxy specific breaking changes in v7.13.
The authentication changes below apply to Stroom-Proxy as well as Stroom.


## Stroom & Stroom-Proxy

Breaking changes that are common to both Stroom and Stroom Proxy.


### Authentication

These apply wherever an external identity provider is used, so to Stroom and to Stroom-Proxy.


#### Audience Validation Is Now on by Default

The audience, i.e. `aud`, claim of a token from an external identity provider is now validated.
Previously, if `allowedAudiences` was not configured then no audience validation was performed at all, so a token minted for a different application at the same provider could be replayed against Stroom.
Where `allowedAudiences` is empty the audience is now validated against the configured `clientId` instead.

If your provider issues tokens to Stroom whose audience is not the `clientId`, e.g. an API or resource identifier, then list the expected values under `allowedAudiences`.

Stroom also now refuses to start with an external identity provider unless one of `allowedAudiences` or `clientId` is configured, so that validation cannot be silently skipped for lack of anything to validate against.

{{% see-also %}}
[Audience Validation]({{< relref "docs/install-guide/setup/open-id/external-idp/stroom-configuration#audience-validation" >}})
{{% /see-also %}}


#### An Audience Claim Is Now Required

`audienceClaimRequired` now defaults to `true`, so an access token from an external identity provider that carries no `aud` claim is rejected.

Some Cognito and Okta access token shapes have no `aud` claim.
If yours is one of them, set `audienceClaimRequired` to `false` to restore the previous behaviour.


#### Removal of the `TEST_CREDENTIALS` Identity Provider Type

This identity provider type has been removed, along with the publicly known credentials it shipped with.
Stroom and Stroom-Proxy will now fail validation on start if `identityProviderType` is set to it.
Use `INTERNAL_IDP` for Stroom, and `NO_IDP` or `EXTERNAL_IDP` for Stroom-Proxy.

A replacement is available for test and demonstration environments, but it is off unless deliberately enabled at runtime and must never be used in production.

{{% see-also %}}
[Insecure Test Credential]({{< relref "docs/install-guide/setup/open-id/test-credentials" >}})
{{% /see-also %}}
