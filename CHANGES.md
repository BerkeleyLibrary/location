# 4.1.0 (2025-01-10)

- Fixed token refresh function and test

# 4.0.0 (2025-01-08)

- Update from Worldcat API v1 to API v2
- Changed some of the tests from mocks to use VCR

# 3.0.0 (2023-10-10)

- Support duplicate OCLC numbers

# 2.0.0 (2023-06-06)

- Rename from "holdings" to "location"

# 2.0.0 (2023-06-06)

- Rename from "holdings" to "location"

# 1.0.5 (2023-06-01)

- Update to `berkeley_library-util` 0.1.9 to handle non-ASCII OCLC numbers
- Fix issue where locating blank columns could fail on spreadsheets with nil rows

# 1.0.4 (2023-04-28)

- Escape OCLC numbers before constructing query URIs
  (not an issue for correct OCLC numbers, but can be an issue in the event of bad data)

# 1.0.3 (2023-04-27)

- Fix issue requiring RubyXL extensions to be explicitly required 

# 1.0.2 (2023-04-27)

- Overwrite existing blank columns when writing results to spreadsheet

# 1.0.1 (2023-04-26)

- First working RubyGems release

# 1.0.0 (2023-04-25)

- Initial (broken) RubyGems release

# 0.1.0 (2023-02-24)

- Initial release
