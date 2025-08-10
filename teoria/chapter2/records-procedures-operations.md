### 2.3.4 Records and Procedures

#### The Power of Records

Records are the fundamental building blocks for structuring data in Oz, serving as the basis for more complex data structures like lists and trees. The language provides strong support for records, which makes them a powerful tool.

* **Creation and Deconstruction:** Records are easy to create with a compact syntax and to take apart using pattern matching.
* **Manipulation:** There are many built-in operations to manipulate records, such as adding, removing, or selecting fields, and converting to lists and back.
* **Advanced Techniques:** Strong record support is crucial for advanced techniques like object-oriented programming (where records can represent messages and methods), graphical user interface (GUI) design (where they can represent widgets), and component-based programming.
* Languages that provide this level of support for records are often called **symbolic languages**.

#### Operations

The following table summarizes some of the basic operations available for records, numbers, and procedures.

| Operation | Description | Argument Type |
|---|---|---|
| `A == B` | Equality comparison | Any Value |
| `A \= B` | Inequality comparison | Any Value |
| `A >= B` | Greater than or equal | Number or Atom |
| `A > B` | Greater than | Number or Atom |
| `A + B` | Addition | Number |
| `A - B` | Subtraction | Number |
| `A * B` | Multiplication | Number |
| `A div B` | Integer division | Int |
| `A mod B` | Modulo | Int |
| `A / B` | Float division | Float |
| `{IsProcedure P}` | Test if procedure | Any Value |
| `{Arity R}` | Returns features as a list | Record |
| `{Label R}` | Returns the label | Record |
| `R.F` | Field selection | Record |

#### Examples of Record Operations

For a record `X = person(name:"George" age:25)`, you can use the following operations:

* `{Label X}` returns the atom `person`.
* `{Arity X}` returns the list of features `[age name]` (features are sorted alphabetically).
* `X.age` returns the integer `25`.

#### Comparison Operations

* `==` and `\=` can compare any two values for equality.
* Comparisons like `=>`, `<`, `>=`, `>` work on numbers and atoms. When comparing atoms, the order is based on the lexicographic order of their text representation.
* The `if` statement has syntactic sugar that allows a comparison expression as its condition.

### Procedure Operations

There are three main operations related to procedures:

* **Defining:** A procedure is defined using the `proc` statement.
* **Calling:** A procedure is executed using the curly brace notation `{x y1 ... yn}`.
* **Testing:** The function `{IsProcedure P}` returns `true` if its argument `P` is a procedure, and `false` otherwise.