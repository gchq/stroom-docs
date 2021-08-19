Find all image links

```bash
ag -c '!\['
```

Convert image links (with quoted titles)

```bash
sed -i -r 's/!\[(.*)\]\((.*) "(.*)"\)/{{< screenshot "\2" >}}\3{{< \/screenshot >}}/g' file.md
```


