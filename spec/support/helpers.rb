# frozen_string_literal: true

# Fetch a file fixture by name/path.
#
# @param path [String, Symbol] the path to fetch
# @return [Pathname] the found file fixture
def file_fixture(path)
  Pathname.new(File.expand_path(File.join(__dir__,
                                          "../fixtures/files/#{path}")))
end
