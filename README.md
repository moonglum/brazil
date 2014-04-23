# Brazil

| Project         | Brazil
|:----------------|:--------------------------------------------------
| Homepage        | ...
| Documentation   | [RubyDoc](http://www.rubydoc.info/gems/brazil)
| CI              | [![Build Status](http://img.shields.io/travis/moonglum/brazil.svg)](http://travis-ci.org/moonglum/brazil)
| Code Metrics    | [![Code Climate](http://img.shields.io/codeclimate/github/moonglum/brazil.svg)](https://codeclimate.com/github/moonglum/brazil) [![Code Climate Coverage](http://img.shields.io/codeclimate/coverage/github/moonglum/brazil.svg)](https://codeclimate.com/github/moonglum/brazil)
| Gem Version     | [![Gem Version](http://img.shields.io/gem/v/brazil.svg)](http://rubygems.org/gems/brazil)
| Dependencies    | [![Dependency Status](http://img.shields.io/gemnasium/moonglum/brazil.svg)](https://gemnasium.com/moonglum/brazil)

![Cover Image](http://neverbesocial.com/wp-content/uploads/2011/09/brazil-dvd1.jpg)

> 'Ere I am, J.H. ...The ghost in the machine.   
  &mdash; Mr. Helpmann

**This is a spike to see how the DSL should look like.**

Brazil is an experimental Ruby DSL for creating queries for the [ArangoDB](https://www.arangodb.org) in the the [Arango Query Language](https://www.arangodb.org/manuals/2/Aql.html). Brazil is also the fifth biggest producer of Avocados (according to Wikipedia) and an amazing movie. As chance would have it, the spike of this gem was done on my way to Brazil. Brazil is not intended to be a Object Document Mapper, but to be used by the ODM to build the queries. The DSL is inspired by both the Sequel and the ActiveRecord gems.

## ArangoDB

[ArangoDB](http://www.arangodb.org) is...

> [...] a distributed open-source database with a flexible data model for documents, graphs, and key-values. Build high performance applications using a convenient sql-like query language or JavaScript extensions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brazil'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install brazil
```

## Usage

In our examples we will use a collection of characters and their cast from the movie 'Brazil'. We will work our way through AQL using Brazil to generate the queries.

## The basic form

When you're querying using Brazil each of the queries needs at least two things: One or more `for_all` calls and exactly one `return_as` call. You can imagine that a query always iterates over each of the documents in a collection (there are of course indexes etc. that allow a lot of shortcuts, but for a basic mental model you can imagine it like this). For all the documents you selected, you have to specify what exactly you want to return. In the simplest case this is the entire document.

* `for_all('variable_name', in_collection: 'collection_name')`: Iterate over all documents in the collection with the name `collection_name` – in each iteration call the current document `variable_name`.
* `return_as`: In its basic form it takes the name of a variable as a String. This will return the entire document denoted by the variable.

If, for example, you want to iterate over all characters in the `characters` collection and return each one of them, you could do that as follows:

```ruby
query = Query.for_all('character', in_collection: 'characters').return_as('character')
```

## A more sophisticated `return_as` or: Projections

In a lot of cases, you may want to influence the form of each of the returned documents. In relational algebra this is known as a projection. With Brazil you can do this by providing a block to the `return_as` statement instead of a String. This block will be provided with a document on which you can then define the attributes you want. Typically the value for these attributes will be an attribute from one of the variables you defined. For this purpose, all variables you define in a `for_all` statement will be made available in the context of the block. You can access their attributes to set the attributes of your result document. If for example you want to iterate over all documents in the `casting` collection and return a document with a `name` attribute for each which has the value of the `actor` attribute of the document, you could do it like this:

```ruby
query = Query.for_all('cast', in_collection: 'casting').return_as do |result|
  result['name'] = cast['actor']
end
```

You can also set the result to a fixed value:

```ruby
query = Query.for_all('cast', in_collection: 'casting').return_as do |result|
  result['rating'] = 'awesome'
end
```

## Filtering the results

You probably don't want all of the documents in a collection. AQL allows you to filter your results. In Brazil you can do that by chaining a `filter` statement into your query builder. In this statement you can use different operators to check if you want this document to be in your collection. Let us start with the equality operator. In the following statement we want to get all characters that have the name "Sam Lawry" and return the according document:

```ruby
query = Query.for_all('character', in_collection: 'characters')
  .filter { character['name'] == 'Sam Lawry' }
  .return_as('character')
```

## Sorting

If you want to sort the result via certain criteria, use the `sort_by` function in Brazil. Sort takes a block where you can give an attribute name of a variable to sort. If for example you want to sort all characters using their name in ascending order, you could do it as follows:

```ruby
query = Query.for_all('character', in_collection: 'characters')
  .sort_by { character['name'] }
  .return_as('character')
```

If instead you want to sort in descending order, you could do that as follows:

```ruby
query = Query.for_all('character', in_collection: 'characters')
  .sort_by { descending(character['name']) }
  .return_as('character')
```

It is also possible to sort via multiple criteria. In this case you need to provide a block with the criteria in order from most significant to least significant:

```ruby
query = Query.for_all('character', in_collection: 'characters')
  .sort_by { [character['job'], character['name']] }
  .return_as('character')
```

## Contributing

If you want to contribute to the project, see CONTRIBUTING.md for details. It contains information on our process and how to set up everything. The following people have contributed to this project:
