# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Test/Lint Commands
- Run tests: `bundle exec rspec [path_to_spec]`
- Run all tests: `bundle exec rspec`
- Run linter: `bundle exec rubocop`
- Security analysis: `bundle exec brakeman`
- Start development server: `bin/rails server`

## Code Style Guidelines
- Follow Ruby on Rails Omakase style guide
- Testing with RSpec using descriptive contexts and examples
- Use Factory Bot for test fixtures
- Model methods use verb_noun format
- Validations in models, error handling in controllers
- Use YARD-style type annotations in comments (e.g., `@return [ActiveRecord::Relation<Team>]`)
- Group requires by purpose
- Use meaningful validation error messages
- Transactional fixtures for tests
- Follow Rails naming conventions