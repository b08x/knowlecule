#!/usr/bin/env ruby
# frozen_string_literal: true

require "mimemagic"
require "ohm"
require "ohm/contrib"

Knowlecule::UI.say("Connected to Redis Host!")

module Knowlecule
  module Redis
    module_function

    def connect(host)
      begin
        Ohm.redis = Redic.new(host)
      rescue Ohm::Error => e
        Knowlecule::UI.say(:error, "Unable to connect to Redis Cache #{e}")
        exit
      end
    end

    def flush
      Ohm.redis.call "FLUSHDB"
      Knowlecule::UI.say("Redis Cache Flushed! host: #{ENV.fetch('REDIS')}")
      exit
    end
  end
end

class Subject < Ohm::Model
  attribute :name
  attribute :description
  attribute :vector

  collection :items, :Item

  collection :documents, :Document


  # collection :sections, :Sections

  unique :name
  index :name
end


# Within a section, you typically find a cohesive group of related content that is organized around a common theme or topic. Sections are commonly used in documents, articles, or books to structure and organize information. They often contain headings, subheadings, paragraphs, lists, tables, or other elements that help to present and explain the context within that section as well as the document as a whole.

class Section < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :uuid

  attribute :start_position  # Character position within the source item
  attribute :end_position

  attribute :content
  attribute :summary

  attribute :headings
  attribute :paragraphs, Type::Array
  attribute :sentences, Type::Array

  attribute :phrases, Type::Array # TODO: consider making seperate class?

  attribute :lists # bullet point or number lists, ordered|unordered

  attribute :figures # or :images
  attribute :tables

  attribute :embedding, :Embedding

  reference :document, :Document
  reference :subject, :Subject
  reference :item, :Item

  index :content
  index :summary
  index :uuid

  unique :uuid

  def before_create
    self.uuid = SecureRandom.uuid
  end
end

class Word < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :uuid

  # a term typically refers to a word or phrase that has a specific meaning within a particular context, domain, or subject area
  attribute :term

  list :tokens, :Token

  # attribute :part_of_speech
  # attribute :named_entity

  reference :chunk, :Part

  reference :document, :Document
  reference :item, :Item


  collection :embedding, :Embedding

  index :word

  unique :uuid
  def before_create
    self.uuid = SecureRandom.uuid
  end
end

class Token < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :character

  reference :word, :Word

  index :character

end




class Embedding < Ohm::Model
  include Ohm::DataTypes
  # include Ohm::Callbacks

  attribute :vector, Type::Array

  reference :chunk, :Part
  reference :topic, :Subject

  # def before_create
  #   self.id = SecureRandom.uuid
  # end
end



# related words to connect to
# class Synsets < Ohm::Model
# end
