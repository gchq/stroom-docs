---
title: "curl (Windows)"
linkTitle: "curl (Windows)"
#weight:
date: 2022-01-13
tags: 
description: >
  Using Curl on Windows to send data to Stroom.

---

There is a version of curl for Windows

Windows 10 is the latest desktop OS offering from Microsoft.
From Windows 10 build 17063 and later, curl is now natively included - you can execute it directly from Cmd.exe or PowerShell.exe.
Curl.exe is located at c:\windows\system32 (which is included in the standard PATH environment variable) - all you need to do is run Command Prompt with administrative rights and you can use Curl. You can execute it directly from Cmd.exe or PowerShell.exe.
For older versions of Windows, the cURL project has Windows binaries.

```bash
curl -s -k --data-binary @file.dat "https://stroomp.strmdev00.org/stroom/datafeed" -H"Feed:TEST-FEED-V1_0" -H"System:EXAMPLE_SYSTEM" -H"Environment:EXAMPLE_ENVIRONMENT"
```
{{< image "user-guide/sending-data/curl_windows.png" >}}Windows curl CLI{{< /image >}}
