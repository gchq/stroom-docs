---
title: "Response Codes"
linkTitle: "Response Codes"
weight: 30
date: 2021-07-27
tags:
  - http
description: >
  The HTTP response codes returned by stroom.
---

Stroom will return a HTTP response code to indicate success or failure.
An additional response Header "Stroom-Status" will indicate a more precise error message code.
A user readable message will appear in the response body.

| HTTP Status | Stroom-Status | Message                           | Reason                                                                                                          |
| ---         | ---           | ---                               | ---                                                                                                             |
| 200         | 0             | OK                                | Post of data successful                                                                                         |
| 406         | 100           | Feed must be specified            | You must provide Feed as a header argument in the request                                                       |
| 406         | 110           | Feed is not set to receive data   | The feed you have provided is not setup to receive data (maybe does not exist or is set to reject)              |
| 406         | 200           | Unknown compression               | Compression argument must be one of ZIP, GZIP and NONE                                                          |
| 401         | 300           | Client Certificate Required       | The feed you have provided requires a client HTTPS certificate to send data                                     |
| 403         | 310           | Client Certificate not authorised | The feed you have provided does not allow your client certificate to send data                                  |
| 500         | 400           | Compressed stream invalid         | The stream of data sent does not form a valid compressed file.  Maybe it terminated unexpectedly or is corrupt. |
| 500         | 999           | Unknown error                     | An unknown unexpected error occurred                                                                            |

In the event that data is not successfully received by Stroom, i.e. the response code is not 200, the client system should buffer data and keep trying to re-send it.
Data should only be removed from the client system when it has been sent successfully.
