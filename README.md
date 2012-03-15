# Brazil

[![Build Status](https://secure.travis-ci.org/moonglum/Brazil.png?branch=master)](http://travis-ci.org/moonglum/Brazil)

> 'Ere I am, J.H. ...The ghost in the machine.   
  &mdash; Mr. Helpmann

Brazil is an experimental Ruby DSL for creating queries for the [AvocadoDB](https://github.com/triAGENS/AvocadoDB) in AQL (The Avocado Query Language). Brazil is also the fifth biggest producer of Avocados (according to Wikipedia) and an amazing movie.

## AvocadoDB

AvocadoDB is...

> [...] a document-store, which focuses on durability of the data taking advantage of new technologies like SSD, support for graph and geo algorithms needed in social networks, ease of use for the developer and minimal effort to operate for the administrator.

## Avocado Query Language (AQL)

**Important Disclaimer: The AQL is still in development. Every part can change at any time.**

According to the [Avocado Wiki](https://github.com/triAGENS/AvocadoDB/wiki/AQL):

> The purpose of AQL is somewhat similar to SQL, but the language has notable differences to SQL. This means that AQL queries cannot be run in an SQL database and vice versa.

An AQL query looks like that (optional parts are wrapped in square brackets):

    SELECT select_statement
    FROM from_statement [join_statements]
    [WHERE where_statement]
    [ORDER BY order_by_statement]
    [LIMIT limit_statement]
    [WITHIN within_statement]
    [NEAR near_statement]

An query like that is represented by an `Brazil::Query` in Brazil. Every query has to have exactly one `from_statement` – the `select_statement` defaults to returning everything:

```ruby
    query = Brazil::Query.new 
    query.from "collection c"
    puts query.evaluate #=> "SELECT c FROM collection c"
```

### where

The `WHERE` clause in AQL can be specified to restrict the result to documents that match certain criteria. In Brazil the statement is (currently) copied unmodified and not checked:

```ruby
    query = Brazil::Query.new 
    query.from "collection c"
	query.where "c.age < 40 && c.name == 'john'"
    puts query.evaluate #=> "SELECT c FROM collection c WHERE c.age < 40 && c.name == 'john'"
```

If multiple where clauses are provided, they will be connected with the and operator.

### join

There are three types of joins in AQL: Left, Right and Inner Join. In Brazil, the joins are added from left to right in the order you applied. There are three methods on the Query object: `left_join`, `right_join` and `inner_join`. Each of them takes the right side of the join and the ON statement (which is again copied unmodified and not checked) as arguments. For Example:

```ruby
    query = Brazil::Query.new 
    query.from "collection c"
	query.left_join "collection d", :on => "c.id == d.id"
    puts query.evaluate #=> "SELECT c FROM collection c LEFT JOIN collection d ON (c.id == d.id)"
```

### order and limit

The order statement influences the order of the data sets. In Brazil you can use the order setup only once per query object and it takes a list of order statements (each is a attribute with an optional `ASC` or `DESC`):

```ruby
    query = Brazil::Query.new 
    query.from "collection c"
	query.order "c.age ASC", "c.name"
    puts query.evaluate #=> "SELECT c FROM collection c ORDER BY c.age ASC, c.name"
```

The limit statement (again only one per query object) influences the number of records returned. You can either give it a maximum number of data sets or a from and to value (those two options can not be combined):

```ruby
    query = Brazil::Query.new 
    query.from "collection c"
	query.limit maximum: 5
    puts query.evaluate #=> "SELECT c FROM collection c LIMIT 5"

    second_query = Brazil::Query.new 
    second_query.from "collection c"
	second_query.limit from: 5, to: 10
    puts second_query.evaluate #=> "SELECT c FROM collection c LIMIT 5, 10"
```
