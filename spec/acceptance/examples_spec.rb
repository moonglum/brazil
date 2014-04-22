# -*- encoding : utf-8 -*-
require 'acceptance/spec_helper'

def setup_characters_collection
  character = DATABASE.create_collection('characters')
  character.create_document(name: 'Sam Lawry')
  character.create_document(name: 'Archibald "Harry" Tuttle')
  character.create_document(name: 'Jill Layton')
  character.create_document(name: 'Jack Lint')
  character.create_document(name: 'Ida Lowry')
  character.create_document(name: 'Spoor')
  character.create_document(name: 'Mr. Kurtzmann')
end

def setup_cast_collection
  casting = DATABASE.create_collection('casting')
  casting.create_document(actor: 'Jonathan Pryce', character: 'Sam Lawry')
  casting.create_document(actor: 'Robert De Niro', character: 'Archibald "Harry" Tuttle')
  casting.create_document(actor: 'Kim Greist', character: 'Jill Layton')
  casting.create_document(actor: 'Michael Palin', character: 'Jack Lint')
  casting.create_document(actor: 'Katherine Helmond', character: 'Ida Lowry')
  casting.create_document(actor: 'Bob Hoskins', character: 'Spoor')
  casting.create_document(actor: 'Ian Holm', character: 'Mr. Kurtzmann')
end

def send_query(query_string)
  DATABASE.query.execute(query_string).to_a.map(&:to_h)
end

describe 'Usage Examples' do
  before :each do
    DATABASE.collections.each { |collection| collection.delete }
    setup_characters_collection
    setup_cast_collection
  end

  it 'should find exactly one "Sam Lawry"' do
    result = send_query('FOR `character` IN `characters` FILTER `character`.`name` == "Sam Lawry" RETURN `character`')
    expect(result.length).to be 1
  end
end