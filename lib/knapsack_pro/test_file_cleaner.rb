module KnapsackPro
  class TestFileCleaner
    def self.clean(test_file_path)
      test_file_path.sub(/^\.\//, '').chomp(",")
    end
  end
end
