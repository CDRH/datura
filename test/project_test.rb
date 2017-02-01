require "logger"
require "minitest/autorun"
require "yaml"
require_relative "classes.rb"

class ProjectTest < Minitest::Test
  # start with empty tests and build them from yml files
  this_file_dir = File.dirname(__FILE__)
  all_tests = {}
  projects_dir = "#{this_file_dir}/../projects"

  # find and collect all of the project's test ymls
  projects = Dir.entries(projects_dir)
  projects.each do |project|
    test_dir = "#{projects_dir}/#{project}/test"
    if File.directory?(test_dir)
      Dir.glob("#{test_dir}/*.yml").each do |file|
        yml = YAML.load_file(file)
        if all_tests.has_key?(project)
          all_tests[project] += yml
        else
          all_tests[project] = yml
        end
      end
    end
  end

  # create the tests from the projects
  all_tests.each do |project, files|
    count = 0
    files.each do |file|
      filename = file["filename"]

      # create a minitest dynamically for each file
      define_method "test_#{project}_#{count}" do
        path = "#{projects_dir}/#{project}/#{file["type"]}/#{filename}"
        options = {
          "environment" => "test",
          "project" => project,
          "es_type" => project,
        }
        tei = FileTei.new(path, "#{projects_dir}/#{project}", options)
        res = tei.transform_es
        assert_equal res.length, file["count"]
        file["matches"].each do |tcase|
          doc = res.select {|d| d["cdrh:identifier"] == tcase["cdrh:identifier"] }[0]
          if doc && doc.length > 0
            assert_equal doc["cdrh:creator_sort"], tcase["cdrh:creator_sort"]
          else
            puts "could not find a doc matching test case"
            puts "in test case: #{tcase}"
            puts "res: #{res}"
            assert false
          end
        end
      end
      count += 1

    end
  end
end
