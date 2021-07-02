# Rounding Functions
These functions require a value, and an optional decimal places.
If the decimal places are not given it will give you nearest whole number.

<!-- vim-markdown-toc GFM -->

* [Ceiling](#ceiling)
* [Floor](#floor)
* [Round](#round)

<!-- vim-markdown-toc -->

## Ceiling
```
ceiling(value, decimalPlaces<optional>)
```

Examples
```
ceiling(8.4234)
> 9
ceiling(4.56, 1)
> 4.6
ceiling(1.22345, 3)
> 1.223
```

## Floor
```
floor(value, decimalPlaces<optional>)
```

Examples
```
floor(8.4234)
> 8
floor(4.56, 1)
> 4.5
floor(1.2237, 3)
> 1.223
```

## Round
```
round(value, decimalPlaces<optional>)
```

Examples
```
round(8.4234)
> 8
round(4.56, 1)
> 4.6
round(1.2237, 3)
> 1.224
```

