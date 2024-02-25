#!/usr/bin/env ruby
# frozen_string_literal: false

module Knowlecule
  module LLM
    class HF
      # Retry connecting to the model for 1 minute
      MAX_RETRY = 60

      HOST = "https://api-inference.huggingface.co/models"

      HEADERS = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{ENV.fetch('HUGGINGFACE_API_KEY', nil)}"
      }

      attr_reader :function, :model

      def initialize(model)
        @function = function || "generate_text"
        @model = $models["huggingface"]["#{model}"] || "meta-llama/Llama-2-70b-chat-hf"
        @api_url = "#{HOST}/#{@model}"
      end

      def create_json_object(question, context)
        {
          inputs: {
            question: question,
            context: context
          }
        }.to_json
      end

      # force an encoding and replace marks with nothing
      def fix_encoding(input)
        input.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "")
      end

      def inference(text, temperature=0.5, max_new_tokens=512)
        retries = 0

        data = {
          "inputs" => text,
          "parameters" => {
            "temperature" => temperature,
            "max_new_tokens" => max_new_tokens
          }
        }

        begin
          uri = URI.parse(@api_url)

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true # Use HTTPS

          request = Net::HTTP::Post.new(uri.path, HEADERS)

          request.body = data.to_json

          response = http.request(request)

          # Handle the response as needed
          JSON.parse(response.body)
        rescue StandardError => e
          p e
          if retries < MAX_RETRY
            retries += 1
            sleep 1
            retry
          else
            raise exception
          end
        end
      end

    end
  end
end

# User prompt
question = "In the training phase, a developer feeds their model a curated dataset so that it can “learn” everything it needs to about the type of data it will analyze. Then, in the inference phase, the model can make predictions based on live data to produce actionable results. What are the initial steps in this pipeline?"

context = "Document Processing with Ruby"

query = "We consult the popular Large Language Model interfaces of the day to help better understand the process through practical example. We apply this syntactic sugar to the 'text chunking' stage of the NLP pipeline to help "



hf = Knowlecule::LLM::HF.new("generation")

x = hf.inference("two turntables and a ")

pp x

# hf = Knowlecule::LLM::HF.new("question_answering:")

# x = hf.create_json_object(question,context)
# pp hf.inference(x)
