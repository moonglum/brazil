# Brazil

[![Build Status](https://secure.travis-ci.org/moonglum/brazil.png?branch=master)](http://travis-ci.org/moonglum/brazil)

> 'Ere I am, J.H. ...The ghost in the machine.   
  &mdash; Mr. Helpmann

Brazil is an experimental Ruby DSL for creating queries for the [AvocadoDB](https://github.com/triAGENS/AvocadoDB) in AQL (The Avocado Query Language). Brazil is also the fifth biggest producer of Avocados (according to Wikipedia) and an amazing movie.

Brazil is not intended to be a Object Document Mapper, but to be used by the ODM to build the queries. It is built for Ruby 1.9 only. The compatability with Ruby 1.9.2, 1.9.3, JRuby (1.9 Mode) and Rubinius (1.9 Mode) is tested by Travis.

## AvocadoDB

AvocadoDB is...

> [...] a document-store, which focuses on durability of the data taking advantage of new technologies like SSD, support for graph and geo algorithms needed in social networks, ease of use for the developer and minimal effort to operate for the administrator.

## Creating AQL Queries with Brazil

**Important Disclaimer: The AQL is still in development. Every part can change at any time.**

According to the [Avocado Wiki](https://github.com/triAGENS/AvocadoDB/wiki/AQL)...

> The purpose of AQL is somewhat similar to SQL, but the language has notable differences to SQL. This means that AQL queries cannot be run in an SQL database and vice versa.

An AQL query looks like that (optional parts are wrapped in square brackets):

    SELECT select_statement
    FROM from_statement [join_statements]
    [WHERE where_statement]
    [ORDER BY order_by_statement]
    [LIMIT limit_statement]
    [WITHIN within_statement]
    [NEAR near_statement]

A query like that is represented by a `Brazil::Query` in Brazil. Every query has to have exactly one `from_statement` – the `select_statement` defaults to returning all attributes:

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

If multiple where clauses are provided, they will be connected with the `&&` operator.

### join

There are three types of joins in AQL: Left, Right and Inner Join. In Brazil, the joins are added from left to right in the order you applied the methods. There are three methods on the Query object: `left_join`, `right_join` and `inner_join`. Each of them takes the right side of the join and the ON statement (which is again copied unmodified and not checked) as arguments. For example:

```ruby
query = Brazil::Query.new 
query.from "collection c"
query.left_join "collection d", :on => "c.id == d.id"
puts query.evaluate #=> "SELECT c FROM collection c LEFT JOIN collection d ON (c.id == d.id)"
```

### order and limit

The order statement influences the order of the data sets. In Brazil you can use the order setup only once per query object and it takes a list of order statements (each is an attribute with an optional `ASC` or `DESC`):

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

### Geo Coordinates

In Avocado you can find documents via geo coordinates (very fast). Brazil features the `find_by_geocoordinates` method which takes an array with the names of the attributes, an array with the coordinates of a reference point and either a radius (to find all documents within a certain range) or a maximum (to find the nearest x documents). If you don't assign the attributes it defaults to the attributes x and y of the collection in the from statement.

```ruby
query = Brazil::Query.new 
query.from "collection c"
query.find_by_geocoordinates attributes: ["c.x_coord", "c.y_coord"], reference: [37.331953, -122.029669], radius: 50
puts query.evaluate #=> "SELECT c FROM collection c WITHIN [c.x_coord, c.y_coord], [37.331953, -122.029669], 50"

second_query = Brazil::Query.new 
second_query.from "collection c"
second_query.find_by_geocoordinates reference: [37.331953, -122.029669], maximum: 20
puts second_query.evaluate #=> "SELECT c FROM collection c NEAR [c.x, c.y], [37.331953, -122.029669], 20"
```

# Development

Brazil is in a very early stage. It is far from being feature complete (You can see a list of upcoming features [here](https://github.com/moonglum/brazil/issues?labels=enhancement&sort=created&direction=desc&state=open&page=1)). It is developed in a strict Test-First manner using RSpec. If you find a bug, please file a ticket or send a pull request with a spec showing the bug (and optionally fix it ;) ). I'm also open for all kinds of feedback from finding spelling mistakes to disagrements on design choices.