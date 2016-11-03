# Variables

A variable is added to Data Splitter using the `<var>` element. A variable is used to store matches from a parent expression for use in a reference elsewhere in the configuration, see [variable reference](3-2-variable-reference.md#sec_3_2).

The most recent matches are stored for use in local references, i.e. references that are in the same match scope as the variable. Multiple matches are stored for use in references that are in a separate match scope. The concept of different variable scopes is described in [scopes](3-2-variable-reference.md#sec_3_2_2).

## <a id="sec_2_3_1"></a>The &lt;var&gt; element

The `<var>` element is used to tell Data Splitter to store matches from a parent expression for use in a reference.

### <a id="sec_2_3_1_1"></a>Attributes

The `<var>` element has the following attributes:

* [id](#sec_2_3_1_1_1)

#### <a id="sec_2_3_1_1_1"></a>id

Mandatory attribute used to uniquely identify it within the configuration (see [id](2-1-content-providers.md#sec_2_1_2_1_1)) and is the means by which a variable is referenced, e.g. `$VAR_ID$`.