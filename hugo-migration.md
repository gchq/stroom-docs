Useful `sed` tester - https://sed.js.org#

Find all image links

```bash
ag -c '!\['
```

Convert image links (with quoted titles)



```bash
sed -i -r 's/!\[(.*)\]\((.*) "(.*)"\)/{{< screenshot "\2" >}}\3{{< \/screenshot >}}/g' file.md
```

Convert document links to short codes

```text
[title](../path/other.md#anchor "title") => [title]({{< relref "../path/other.md#anchor" >}})
```

```bash
sed -i --regexp-extended 's/\]\(([^)]+\.md(#[^")]+)?)( "[^"]+")?\)/]({{< relref "\1" >}})/g' file.md
```

