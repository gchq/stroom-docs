# Date Functions

<!-- vim-markdown-toc GFM -->
* [Parse Date](#parse-date)
* [Format Date](#format-date)
<!-- vim-markdown-toc -->

## Parse Date
Parse a date and return a long number of milliseconds since the epoch.
```
parseDate(aString)
parseDate(aString, pattern)
parseDate(aString, pattern, timeZone)
```

Example
```
parseDate('2014 02 22', 'yyyy MM dd', '+0400')
> 1393012800000
```

## Format Date
Format a date supplied as milliseconds since the epoch.
```
formatDate(aLong)
formatDate(aLong, pattern)
formatDate(aLong, pattern, timeZone)
```

Example
```
formatDate(1393071132888, 'yyyy MM dd', '+1200')
> '2014 02 23'
```