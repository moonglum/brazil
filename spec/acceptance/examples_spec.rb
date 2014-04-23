# -*- encoding : utf-8 -*-
require 'acceptance/spec_helper'
require 'brazil'

def setup_characters_collection
  character = DATABASE.create_collection('characters')
  character.create_document(name: 'Sam Lawry', job: 'Goverment Employee')
  character.create_document(name: 'Archibald "Harry" Tuttle', job: 'Renegade Air Conditioning Specialist')
  character.create_document(name: 'Jill Layton')
  character.create_document(name: 'Jack Lint', job: 'Goverment Employee')
  character.create_document(name: 'Ida Lowry', job: 'Retired')
  character.create_document(name: 'Spoor', job: 'Goverment Certified Air Conditioning Specialist')
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

def send_query(query)
  DATABASE.query.execute(query.to_aql).to_a.map(&:to_h)
end

describe 'Usage Examples' do
  before :each do
    DATABASE.collections.each { |collection| collection.delete }
    setup_characters_collection
    setup_cast_collection
  end

  it 'should find all seven characters' do
    query = Query.for_all('character', in_collection: 'characters').return_as('character')
    result = send_query(query)
    expect(result.length).to be 7
  end

  describe 'return_as' do
    it 'should allow to only return the name of the actor as `name`' do
      query = Query.for_all('cast', in_collection: 'casting').return_as do |result|
        result['name'] = cast['actor']
      end
      result = send_query(query)
      expect(result.first.keys).to eq ['name']
      expect(result.map { |doc| doc['name'] }).to include 'Michael Palin'
    end

    it 'should allow to set attributes to a certain value' do
      query = Query.for_all('cast', in_collection: 'casting').return_as do |result|
        result['rating'] = 'awesome'
      end
      result = send_query(query)
      expect(result.first.keys).to eq ['rating']
      expect(result.map { |doc| doc['rating'] }).to include 'awesome'
    end
  end

  describe 'filter_by' do
    it 'should allow to filter for all Sam Lawrys in the collection' do
      query = Query.for_all('character', in_collection: 'characters')
        .filter_by { character['name'] == 'Sam Lawry' }
        .return_as('character')
      result = send_query(query)
      expect(result.length).to be 1
      expect(result.first['name']).to eq 'Sam Lawry'
    end
  end

  describe 'sort_by' do
    it 'should allow to sort all characters by name' do
      query = Query.for_all('character', in_collection: 'characters')
        .sort_by { character['name'] }
        .return_as('character')
      result = send_query(query)
      expect(result.first['name']).to eq 'Archibald "Harry" Tuttle'
    end

    it 'should allow to sort all characters by name in descending order' do
      query = Query.for_all('character', in_collection: 'characters')
        .sort_by { descending(character['name']) }
        .return_as('character')
      result = send_query(query)
      expect(result.first['name']).to eq 'Spoor'
    end

    it 'should allow to sort via two keys' do
      query = Query.for_all('character', in_collection: 'characters')
        .sort_by { [character['job'], character['name']] }
        .return_as('character')
      result = send_query(query)
      expect(result.last['name']).to eq 'Ida Lowry'
      result.keep_if { |character| character['job'] == 'Goverment Employee' }
      expect(result.first['name']).to eq 'Jack Lint'
    end
  end

  describe 'limit' do
    it 'should allow to limit the results to exactly two' do
      query = Query.for_all('character', in_collection: 'characters')
        .limit(2)
        .return_as('character')
      result = send_query(query)
      expect(result.length).to be 2
    end
  end
end
