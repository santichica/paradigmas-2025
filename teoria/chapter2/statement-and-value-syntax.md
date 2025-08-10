### 2.3 Kernel Language

The declarative model defines a simple kernel language. All programs in the model can be expressed in this language. We first define the kernel language syntax and semantics. Then we explain how to build a full language on top of the kernel language.

#### 2.3.1 Syntax

The kernel syntax is given in tables 2.1 and 2.2. It is carefully designed to be a subset of the full language syntax, i.e., all statements in the kernel language are valid statements in the full language.

**Table 2.1: The declarative kernel language.**

| Statement Syntax | Description |
|---|---|
| `skip` | Empty statement |
| `s1 s2` | Statement sequence |
| `local x in s end` | Variable creation |
| `x1=x2` | Variable-variable binding |
| `x=v` | Value creation |
| `if x then s1 else s2 end` | Conditional |
| `case x of pattern then s1 else s2 end` | Pattern matching |
| `{x y1 ... yn}` | Procedure application |

**Table 2.2: Value expressions in the declarative kernel language.**

| Value Syntax | Description |
|---|---|
| `v ::= number\|record\|procedure` | Top-level value categories |
| `number ::= int\|float` | Integers and floats |
| `record, pattern ::= literal \| literal(feature1: x1 ... featuren: xn)` | Structured values and patterns |
| `procedure ::= proc { $ x1 ... xn} s end` | Procedure definition |
| `literal ::= atom\|bool` | Atoms or booleans |
| `feature ::= atom\|bool\|int` | Record keys |
| `bool ::= true \| false` | Boolean values |

**Explanation:**

The declarative kernel language serves as a foundational subset of Oz. It defines the core operations and data types from which all more complex features of the language are built.

* **Statements** are the actions a program performs, ranging from simple variable creation and binding to powerful operations like pattern matching and procedure application.
* **Values** are the data types the program manipulates, including basic numbers, structured records, and even procedures themselves, which are first-class citizens in Oz.

This design ensures that the formal semantics of the language can be defined using a small, well-understood set of rules, while still allowing the full language to offer a rich and expressive syntax for programmers.
