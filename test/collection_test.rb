require "logger"
require "minitest/autorun"
require "yaml"
require_relative "classes.rb"

# commented out until we decide how we want to test collection transformation
# in the future

# class CollectionTest < Minitest::Test
#   # start with empty tests and build them from yml files
#   this_file_dir = File.dirname(__FILE__)
#   all_tests = {}
#   collections_dir = "#{this_file_dir}/../collections"

#   # find and collect all of the collection's test ymls
#   collections = Dir.entries(collections_dir)
#   collections.each do |collection|
#     test_dir = "#{collections_dir}/#{collection}/test"
#     if File.directory?(test_dir)
#       Dir.glob("#{test_dir}/*.yml").each do |file|
#         yml = YAML.load_file(file)
#         if all_tests.has_key?(collection)
#           all_tests[collection] += yml
#         else
#           all_tests[collection] = yml
#         end
#       end
#     end
#   end

#   # create the tests from the collections
#   all_tests.each do |collection, files|
#     if files
#       count = 0
#       files.each do |file|
#         filename = file["filename"]

#         # create a minitest dynamically for each file
#         define_method "test_#{collection}_#{count}" do
#           path = "#{collections_dir}/#{collection}/#{file["type"]}/#{filename}"
#           options = {
#             "environment" => "test",
#             "collection" => collection,
#           }
#           tei = FileTei.new(path, "#{collections_dir}/#{collection}", options)
#           res = tei.transform_es
#           assert_equal res.length, file["count"]
#           file["matches"].each do |tcase|
#             doc = res.select {|d| d["identifier"] == tcase["identifier"] }[0]
#             if doc && doc.length > 0
#               tcase.each do |key, value|
#                 assert_equal value, doc[key], "Problem with #{key}"
#               end
#             else
#               puts "could not find a doc matching test case"
#               puts "in test case: #{tcase}"
#               puts "res: #{res}"
#               assert false
#             end
#           end
#         end
#         count += 1
#       end
#     end
#   end
# end
