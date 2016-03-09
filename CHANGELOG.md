# Change Log

## [Unreleased](https://github.com/Houdini/two_factor_authentication/tree/HEAD)

[Full Changelog](https://github.com/Houdini/two_factor_authentication/compare/v1.1.5...HEAD)

**Merged pull requests:**

- Fix class detection in reset\_otp\_state\_for\(user\) [\#69](https://github.com/Houdini/two_factor_authentication/pull/69) ([monfresh](https://github.com/monfresh))
- Add ability to resend code [\#52](https://github.com/Houdini/two_factor_authentication/pull/52) ([iDiogenes](https://github.com/iDiogenes))

## [v1.1.5](https://github.com/Houdini/two_factor_authentication/tree/v1.1.5) (2016-02-01)
[Full Changelog](https://github.com/Houdini/two_factor_authentication/compare/v1.1.4...v1.1.5)

**Closed issues:**

- How should I integrate Devise two factor authentication with custom sessions controller? [\#60](https://github.com/Houdini/two_factor_authentication/issues/60)

**Merged pull requests:**

- added french translation [\#68](https://github.com/Houdini/two_factor_authentication/pull/68) ([qsypoq](https://github.com/qsypoq))
- Drop support for Ruby 1.9.3 & update .travis.yml [\#67](https://github.com/Houdini/two_factor_authentication/pull/67) ([monfresh](https://github.com/monfresh))
- Fix reset\_otp\_state specs [\#66](https://github.com/Houdini/two_factor_authentication/pull/66) ([monfresh](https://github.com/monfresh))
- Add a CHANGELOG.md [\#65](https://github.com/Houdini/two_factor_authentication/pull/65) ([monfresh](https://github.com/monfresh))
- Update bundler on Travis before installing gems [\#63](https://github.com/Houdini/two_factor_authentication/pull/63) ([monfresh](https://github.com/monfresh))
- Add support for OTP secret key encryption [\#62](https://github.com/Houdini/two_factor_authentication/pull/62) ([monfresh](https://github.com/monfresh))
- Allow executing code after sign in and before sign out [\#61](https://github.com/Houdini/two_factor_authentication/pull/61) ([monfresh](https://github.com/monfresh))

## [v1.1.4](https://github.com/Houdini/two_factor_authentication/tree/v1.1.4) (2016-01-01)
[Full Changelog](https://github.com/Houdini/two_factor_authentication/compare/v1.1.3...v1.1.4)

**Closed issues:**

- Old OTP can be used after a new one has been generated [\#59](https://github.com/Houdini/two_factor_authentication/issues/59)
- Do we have any two\_factor\_method like authenticate\_user! [\#58](https://github.com/Houdini/two_factor_authentication/issues/58)
- Configuration [\#57](https://github.com/Houdini/two_factor_authentication/issues/57)

**Merged pull requests:**

- Abstract logic for two factor success and fail into separate methods.… [\#56](https://github.com/Houdini/two_factor_authentication/pull/56) ([kpheasey](https://github.com/kpheasey))
- Move require rotp library to the file where it is used [\#55](https://github.com/Houdini/two_factor_authentication/pull/55) ([gkopylov](https://github.com/gkopylov))
- Add support for remembering a user's 2FA session in a cookie [\#54](https://github.com/Houdini/two_factor_authentication/pull/54) ([boffbowsh](https://github.com/boffbowsh))
- Test against Ruby 2.2 and Rails 4.2 [\#53](https://github.com/Houdini/two_factor_authentication/pull/53) ([boffbowsh](https://github.com/boffbowsh))
- Eliminates appended '?' to redirects that have no query string [\#46](https://github.com/Houdini/two_factor_authentication/pull/46) ([daveriess](https://github.com/daveriess))

## [v1.1.3](https://github.com/Houdini/two_factor_authentication/tree/v1.1.3) (2014-12-14)
[Full Changelog](https://github.com/Houdini/two_factor_authentication/compare/v1.1.2...v1.1.3)

**Closed issues:**

- rails g two\_factor\_authentication MODEL does not append .rb to end of migration [\#40](https://github.com/Houdini/two_factor_authentication/issues/40)

**Merged pull requests:**

- Allows length of OTP to be configured [\#44](https://github.com/Houdini/two_factor_authentication/pull/44) ([amoose](https://github.com/amoose))
- Missing translation. [\#43](https://github.com/Houdini/two_factor_authentication/pull/43) ([sadfuzzy](https://github.com/sadfuzzy))
- Preserve query parameters in \_return\_to for redirect. [\#42](https://github.com/Houdini/two_factor_authentication/pull/42) ([omb-awong](https://github.com/omb-awong))
- Add file extension to ActiveRecord generator [\#41](https://github.com/Houdini/two_factor_authentication/pull/41) ([jackturnbull](https://github.com/jackturnbull))

## [v1.1.2](https://github.com/Houdini/two_factor_authentication/tree/v1.1.2) (2014-07-14)
[Full Changelog](https://github.com/Houdini/two_factor_authentication/compare/v1.1.1...v1.1.2)

**Closed issues:**

- NoMethodError \(undefined method `scan' for nil:NilClass\) [\#37](https://github.com/Houdini/two_factor_authentication/issues/37)

**Merged pull requests:**

- Updated readme with rake task to update existing users with OTP secret k... [\#39](https://github.com/Houdini/two_factor_authentication/pull/39) ([Znow](https://github.com/Znow))
- Updated readme with view overriding [\#38](https://github.com/Houdini/two_factor_authentication/pull/38) ([Znow](https://github.com/Znow))

## [v1.1.1](https://github.com/Houdini/two_factor_authentication/tree/v1.1.1) (2014-05-31)
[Full Changelog](https://github.com/Houdini/two_factor_authentication/compare/v1.1...v1.1.1)

**Closed issues:**

- Override views [\#36](https://github.com/Houdini/two_factor_authentication/issues/36)
-  NoMethodError in Devise::TwoFactorAuthenticationController\#update [\#30](https://github.com/Houdini/two_factor_authentication/issues/30)

**Merged pull requests:**

- Use Strings and not Symbols for keys when storing variable in warden session [\#35](https://github.com/Houdini/two_factor_authentication/pull/35) ([karolsarnacki](https://github.com/karolsarnacki))
- Chore/extract reused hash key [\#34](https://github.com/Houdini/two_factor_authentication/pull/34) ([rud](https://github.com/rud))
- Pad OTP codes with less than 6 digits [\#31](https://github.com/Houdini/two_factor_authentication/pull/31) ([brissmyr](https://github.com/brissmyr))

## [v1.1](https://github.com/Houdini/two_factor_authentication/tree/v1.1) (2014-04-16)
**Closed issues:**

- Update [\#15](https://github.com/Houdini/two_factor_authentication/issues/15)
- Data in formats other than HTML left unprotected [\#6](https://github.com/Houdini/two_factor_authentication/issues/6)
- Wordlists [\#5](https://github.com/Houdini/two_factor_authentication/issues/5)
- devise - wrong number of arguments \(1 for 0\) [\#3](https://github.com/Houdini/two_factor_authentication/issues/3)
- gem? [\#1](https://github.com/Houdini/two_factor_authentication/issues/1)

**Merged pull requests:**

- added is\_fully\_authenticated helper for current version [\#28](https://github.com/Houdini/two_factor_authentication/pull/28) ([edg3r](https://github.com/edg3r))
- Adds integration spec to ensure authentication code is sent on sign in [\#27](https://github.com/Houdini/two_factor_authentication/pull/27) ([rossta](https://github.com/rossta))
- ensure return\_to location is properly stored [\#26](https://github.com/Houdini/two_factor_authentication/pull/26) ([rossta](https://github.com/rossta))
- travis badge in README [\#25](https://github.com/Houdini/two_factor_authentication/pull/25) ([rossta](https://github.com/rossta))
- Integration specs [\#24](https://github.com/Houdini/two_factor_authentication/pull/24) ([rossta](https://github.com/rossta))
- README updates [\#23](https://github.com/Houdini/two_factor_authentication/pull/23) ([rossta](https://github.com/rossta))
- extract method \#max\_login\_attempts [\#22](https://github.com/Houdini/two_factor_authentication/pull/22) ([rossta](https://github.com/rossta))
- extract method \#populate\_otp\_column [\#21](https://github.com/Houdini/two_factor_authentication/pull/21) ([rossta](https://github.com/rossta))
- specs for Model\#provisioning\_uri [\#20](https://github.com/Houdini/two_factor_authentication/pull/20) ([rossta](https://github.com/rossta))
- Provide options for \#provisioning\_uri [\#19](https://github.com/Houdini/two_factor_authentication/pull/19) ([rossta](https://github.com/rossta))
- Use time-based authentication codes [\#16](https://github.com/Houdini/two_factor_authentication/pull/16) ([mattmueller](https://github.com/mattmueller))
- Add ru locales and locales for max\_limit\_reached view [\#13](https://github.com/Houdini/two_factor_authentication/pull/13) ([edg3r](https://github.com/edg3r))
- Update README.md [\#11](https://github.com/Houdini/two_factor_authentication/pull/11) ([edg3r](https://github.com/edg3r))
- Changed route from user to admin\_user [\#10](https://github.com/Houdini/two_factor_authentication/pull/10) ([ilanstern](https://github.com/ilanstern))
- Changed :notice to :error when setting flash message on attempt failure. [\#9](https://github.com/Houdini/two_factor_authentication/pull/9) ([johnmichaelbradley](https://github.com/johnmichaelbradley))
- Typo and punctuation corrections. [\#8](https://github.com/Houdini/two_factor_authentication/pull/8) ([johnmichaelbradley](https://github.com/johnmichaelbradley))
- Respond with 401 for request non-HTML requests [\#7](https://github.com/Houdini/two_factor_authentication/pull/7) ([WojtekKruszewski](https://github.com/WojtekKruszewski))
- need\_two\_factor\_authentication? method should accept request param. [\#4](https://github.com/Houdini/two_factor_authentication/pull/4) ([VladimirMikhailov](https://github.com/VladimirMikhailov))
- Add generators to make it easier to install and fix deprecation warnings [\#2](https://github.com/Houdini/two_factor_authentication/pull/2) ([carvil](https://github.com/carvil))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
