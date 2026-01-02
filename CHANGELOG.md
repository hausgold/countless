### next

* Upgraded to Ubuntu 24.04 on Github Actions (#20)
* Migrated to hausgold/actions@v2 (#19)

### 2.4.0 (26 December 2025)

* Added Ruby 4.0 support ([#18](https://github.com/hausgold/countless/pull/18))
* Dropped Ruby 3.2 and Rails 7.1 support ([#17](https://github.com/hausgold/countless/pull/17))

### 2.3.0 (19 December 2025)

* Migrated to a shared Rubocop configuration for HAUSGOLD gems ([#16](https://github.com/hausgold/countless/pull/16))

### 2.2.0 (23 October 2025)

* Added support for Rails 8.1 ([#14](https://github.com/hausgold/countless/pull/14))
* Switched from `ActiveSupport::Configurable` to a custom implementation based
  on `ActiveSupport::OrderedOptions` ([#15](https://github.com/hausgold/countless/pull/15))

### 2.1.0 (17 October 2025)

* Removed the require of `rspec/core/rake_task` on our Rake tasks file, as it's
  no runtime dependency ([#13](https://github.com/hausgold/countless/pull/13))

### 2.0.0 (28 June 2025)

* Corrected some RuboCop glitches ([#11](https://github.com/hausgold/countless/pull/11))
* Drop Ruby 2 and end of life Rails (<7.1) ([#12](https://github.com/hausgold/countless/pull/12))

### 1.5.1 (21 May 2025)

* Corrected some RuboCop glitches ([#9](https://github.com/hausgold/countless/pull/9))
* Upgraded the rubocop dependencies ([#10](https://github.com/hausgold/countless/pull/10))

### 1.5.0 (30 January 2025)

* Added all versions up to Ruby 3.4 to the CI matrix ([#8](https://github.com/hausgold/countless/pull/8))

### 1.4.2 (17 January 2025)

* Added the logger dependency, see: https://bit.ly/3E8Zqg0 ([#7](https://github.com/hausgold/countless/pull/7))

### 1.4.1 (13 January 2025)

* Do not eager load the configuration ([#6](https://github.com/hausgold/countless/pull/6))

### 1.4.0 (3 January 2025)

* Raised minimum supported Ruby/Rails version to 2.7/6.1 ([#5](https://github.com/hausgold/countless/pull/5))

### 1.3.4 (15 August 2024)

* Just a retag of 1.3.1

### 1.3.3 (15 August 2024)

* Just a retag of 1.3.1

### 1.3.2 (9 August 2024)

* Just a retag of 1.3.1

### 1.3.1 (9 August 2024)

* Added API docs building to continuous integration ([#4](https://github.com/hausgold/countless/pull/4))

### 1.3.0 (8 July 2024)

* Moved the development dependencies from the gemspec to the Gemfile ([#2](https://github.com/hausgold/countless/pull/2))
* Dropped support for Ruby <2.7 ([#3](https://github.com/hausgold/countless/pull/3))

### 1.2.0 (24 February 2023)

* Added support for Gem release automation

### 1.1.0 (18 January 2023)

* Bundler >= 2.3 is from now on required as minimal version ([#1](https://github.com/hausgold/countless/pull/1))
* Dropped support for Ruby < 2.5 ([#1](https://github.com/hausgold/countless/pull/1))
* Dropped support for Rails < 5.2 ([#1](https://github.com/hausgold/countless/pull/1))
* Updated all development/runtime gems to their latest
  Ruby 2.5 compatible version ([#1](https://github.com/hausgold/countless/pull/1))

### 1.0.0 (11 January 2022)

* Initial gem implementation
* Documented the whole gem and all its features
