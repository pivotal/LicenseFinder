# [6.14.1] / 2021-06-25

# [6.13.0] / 2021-04-27

### Fixed
* Ignore packages with nil modules - [4eca0ec1](https://github.com/pivotal/LicenseFinder/commit/4eca0ec15dc6266afa48b74b3742278351246eb8) 

# [6.12.2] / 2021-04-14

### Changed
* exit when go mod list command fails - [fcf1f707](https://github.com/pivotal/LicenseFinder/commit/fcf1f7076dee2ff730e3c8b608381aca22de0e92) - Jeff Jun

# [6.12.1] / 2021-04-12

# [6.12.0] / 2021-03-05

### Added
* Provide homepage information for GoDep and Go15Vendor package managers - [bae1bda9](https://github.com/pivotal/LicenseFinder/commit/bae1bda9d76cb922405d7efca9c67e2583db70d4) - Jeff Jun

# [6.11.0] / 2021-03-04

### Added
* Add homepage for go_modules package manager - [912394a8](https://github.com/pivotal/LicenseFinder/commit/912394a8a6ab4c31b6918a21da9f37d5b368ed6b) 

# [6.10.1] / 2021-01-08

# [6.10.0] / 2020-11-27

# [6.9.0] / 2020-10-05

### Changed
* to recognize permitted licenses with AND in the name [#173997648] - [eab14250](https://github.com/pivotal/LicenseFinder/commit/eab14250d188153f8c2b0b5c0191fec19bcddf55) - Raymond Lee

# [6.8.2] / 2020-09-08

# [6.8.1] / 2020-08-13

# [6.8.0] / 2020-08-06

# [6.7.0] / 2020-07-23

# [6.6.2] / 2020-07-09

### Added
* support for rebar3 - [b20e7444](https://github.com/pivotal/LicenseFinder/commit/b20e7444c147d8dbfa46eb4e8e549e03be751e02) - Jeff Jun
* Support for Go modules projects outside of the current working directory - [56b3bec6](https://github.com/pivotal/LicenseFinder/commit/56b3bec632b3884ce4cad538742b4a13c55fd7c5)

### Changed
* Change Go modules to only report imported packages (as with other Go package managers) - [34361fda](https://github.com/pivotal/LicenseFinder/commit/34361fdab2dc3f197f7aec6408175018dee3b453) and [dffae4ab](https://github.com/pivotal/LicenseFinder/commit/dffae4ab95e34115b6a54bf681fc0966a8611f01)
* Detect Go modules based on `go.mod` (instead of `go.sum`) - [667f6be7](https://github.com/pivotal/LicenseFinder/commit/667f6be716504a53ccc2824daae08af085566546)

### Fixed
* handle empty case for mix dependencies [#173637843] - [fc34b281](https://github.com/pivotal/LicenseFinder/commit/fc34b2813925a709addde675849e199b05fc4a23) - Jeff Jun

### Removed
* support for rebar2 [#173637980] - [b20e7444](https://github.com/pivotal/LicenseFinder/commit/b20e7444c147d8dbfa46eb4e8e549e03be751e02) - Jeff Jun
* Removed the unnecessary prepare command for Go modules - [284cc5c8](https://github.com/pivotal/LicenseFinder/commit/284cc5c821270a6e56275e32bac836a3e451f46b)

# [6.6.1] / 2020-06-30

### Changed
* Handle multiple solution files for nuget [#173021333] - [040d9559](https://github.com/pivotal/LicenseFinder/commit/040d9559a4bda07490255cc34c1a7891081bc511) 
* matches license names from pypi api call with known licenses to avoid returning misformatted licenses [#173421573] - [6b96d746](https://github.com/pivotal/LicenseFinder/commit/6b96d74600034abcacee6ed2b322aa3abfaa0992) - Jeff Jun
* Update Nuget Package Manager prepare command - [6ac07066](https://github.com/pivotal/LicenseFinder/commit/6ac070668955bc034da1647658440ce5bb0d9bd2) - Jason Smith

# [6.6.0] / 2020-06-22

# [6.5.0] / 2020-06-01

### Added
* Support legacy nuget projects [#172950097] - [0cccbcf9](https://github.com/pivotal/LicenseFinder/commit/0cccbcf9aa92f4297ef0174242bdb19da1babc65) 

### Changed
* Upgrade to golang 1.14.3. Update dotnet-sdk to 3.1 - [0969e98f](https://github.com/pivotal/LicenseFinder/commit/0969e98fde4a82f8931601baa4dd96dc01300a14) 

# [6.4.0] / 2020-05-22

Big shout out to @forelabs for introducing many new features and improvements for this release. Thanks again!!

### Added
* Introducing new inherited_decisions command - [3453feb](https://github.com/pivotal/LicenseFinder/commit/3453feb659a6c3c6e5aa444e3755ddd5d32f3664) - Sven Dunemann
* Decision Applier: Merge manual and system packages - [c690532](https://github.com/pivotal/LicenseFinder/commit/c690532ec8addab16bef4edd390f05ceb353435f) - Sven Dunemann
* Introduce package_url to packages - [18972f7](https://github.com/pivotal/LicenseFinder/commit/18972f7b3a04340e1b7bb560780130b68696b8a2) - Sven Dunemann
* Add --write-headers option for csv exports - [18e01f8](https://github.com/pivotal/LicenseFinder/commit/18e01f8728a9dc525d7567292cc1e2f390ec854d) - Sven Dunemann
* Yarn: Add authors & install_path - [08a0f67](https://github.com/pivotal/LicenseFinder/commit/08a0f67837a218231217767561f2282c1b3a890a) - Sven Dunemann
* install path for nuget dependencies [#172251374] - [ad73c946](https://github.com/pivotal/LicenseFinder/commit/ad73c946113846f8f548adfc73542aebb3763175) - Jeff Jun
* new Rubocop cops - [c4cc6b8b](https://github.com/pivotal/LicenseFinder/commit/c4cc6b8b13273db17b65cecaf24c9053e4989ea1) - Jeff Jun

### Fixed
* Separate lines in license text with LF when exported to JSON - [baddb976](https://github.com/pivotal/LicenseFinder/commit/baddb976e7a8683c5cc320eddc8c2712dfb16c15) - Robert Huitl

### Changed
* Go15VendorExperiment: Detect go only if vendor includes go files - [0f8e609](https://github.com/pivotal/LicenseFinder/commit/0f8e609f0921937c6187deccd80e4bc4b7d67ee4) - Sven Dunemann
* Bump PHP version to 7.4 - [cbe45c5](https://github.com/pivotal/LicenseFinder/commit/cbe45c5cdb3ec200ea215086a3b3eb879e83222a) - Yivan
* Significantly improve the license text matching file to be more dynamic - [acf5705](https://github.com/pivotal/LicenseFinder/commit/acf570573b4a2414d9c43212dea5d4ecb157319e)
* Update Ruby version to 2.7.1 [#172295831] - [475e2948](https://github.com/pivotal/LicenseFinder/commit/475e2948ec1ad859aee59e77aa9ce2a51e1a5029) 

# [6.3.0] / 2020-05-06

### Added
* OFL License - [d475bbb1](https://github.com/pivotal/LicenseFinder/commit/d475bbb1380e217f154f262caaa73c12f5b9792b) - Sven Dunemann
* WTFPL License - [ec629170](https://github.com/pivotal/LicenseFinder/commit/ec6291702c28789a33478041dbf6524d603c12ff) - Sven Dunemann

* Find the install path for sbt, cargo and composer [#171649609] - [0d525cbf](https://github.com/pivotal/LicenseFinder/commit/0d525cbf5208db5a977f2f3d922d07b5ea6a8b16) 

### Changed
* Bump PHP version to 7.3 - [1c3c3271](https://github.com/pivotal/LicenseFinder/commit/1c3c3271b977a6c8d24e4159a6b8098a51086522) 
* Remove +compatible in Go package versions [#171754392] - [5cba5801](https://github.com/pivotal/LicenseFinder/commit/5cba5801f4f276482f01bfeea46fde0dbbcce7b1) 

### Fixed
* Fixed Maven Package manager Groups check - [5058d90](https://github.com/pivotal/LicenseFinder/commit/5058d90246a25ca15c72e0eed8e19ebbf7e39998) - Ravi Soni 
* GoModules: fix compute with vendor mod - [067eb19](https://github.com/pivotal/LicenseFinder/commit/067eb1916ce024039631bdbd4114ababa6c02c3a) - forelabs
* Do not set Bundle path. Bundler will figure it out. - [6319a7a](https://github.com/pivotal/LicenseFinder/commit/6319a7a281bd9cc997c08c903674ab51fcc6545e) - mvz

# [6.2.0] / 2020-04-07

### Fixed
* Break dependency of specs on released license_finder gem - [ef69fa00](https://github.com/pivotal/LicenseFinder/commit/ef69fa00deb7a8f8ebd74312afa9f130be2d9fda) - Matijs van Zuijlen
* Replace toml parser with tomlrb - [8b9b34b4](https://github.com/pivotal/LicenseFinder/commit/8b9b34b48d5bdadc679c0d072117b092d080fb81) - Matijs van Zuijlen

### Changed
* Run glide install in folder containing glide.lock - [cec3ff47](https://github.com/pivotal/LicenseFinder/commit/cec3ff4759f1c06df2cd0c39ac8004fcd156a6e6) - Jeff Jun
* specify path for bundle install [#168042947] - [431355dc](https://github.com/pivotal/LicenseFinder/commit/431355dc1d0172c65444d2f4bcb5b4416fc52af7) 

# [6.1.2] / 2020-03-16

# [6.1.0] / 2020-02-21

### Fixed
* Testing dsl now correctly creates gem project - [6158d767](https://github.com/pivotal/LicenseFinder/commit/6158d76758f4232f3efd652729a83aa632a67dee) - Jeff Jun

### Changed
* Upgrade golang version to 1.13.3 - [51ecbcbc](https://github.com/pivotal/LicenseFinder/commit/51ecbcbc7992366c1baed2e8b805a7f820f70160) 
* Uses correct package management command for pip based on options that are passed in - [3f4034ab](https://github.com/pivotal/LicenseFinder/commit/3f4034ab3479da23088174ad8cf56828b3cda9ad) 

# [6.0.0] / 2020-01-22

### Added
* License Finder now recognizes pip requirement markers - [99fbc184](https://github.com/pivotal/LicenseFinder/commit/99fbc18463ef45f920ad506a72dc0b3a93d0f5bf) - Jason Smith
* Add ruby 2.7.0 and update to latest patch levels - [65efe96](https://github.com/pivotal/LicenseFinder/commit/65efe96aeef600a398f1465c01ed28b51bda456a) - mokhan
* Add support for Pipfile.lock - [566fb39c](https://github.com/pivotal/LicenseFinder/commit/566fb39c4077fb5271707a94894998a585cde8dd) - mokhan

### Fixed
* Bundler ignored groups failure - [bf2c03e3](https://github.com/pivotal/LicenseFinder/commit/bf2c03e375e91e8418967a593362313487f2f0d0) 
* No longer crashes when python package requirement is missing - [80e4b360](https://github.com/pivotal/LicenseFinder/commit/80e4b360b95de126e7dc139c25de56c948a01f1e) - Jason Smith
* Longest common paths returning incorrect single directory [#169276334] - [f1d5423b](https://github.com/pivotal/LicenseFinder/commit/f1d5423b04f892d1d1e0595993c9bebb0a7c1b6d) 
* python 2 projects using incorrect CLI command - [5655f60e](https://github.com/pivotal/LicenseFinder/commit/5655f60e671dc4c247bb05138ed35b05cda9cdc7) 

### Changed
* Bump jdk version to 13 - [74c9aca6](https://github.com/pivotal/LicenseFinder/commit/74c9aca6358c9dd9262790edbba2e42e84b58bd9) - Debbie Chen
* Bump sbt version to 1.3.3 with java 12 - [d825599a](https://github.com/pivotal/LicenseFinder/commit/d825599a9b1ac12d874eda66c17bc877bb9af555) - Debbie Chen
* Bump to openjdk 11 - [499f8ab3](https://github.com/pivotal/LicenseFinder/commit/499f8ab3af7cd8ca37e429f2ed78323ad796d123) - Debbie Chen
* Bump to openjdk 12 - [09c781a7](https://github.com/pivotal/LicenseFinder/commit/09c781a70787d9461722d5d03d1bc624b644311a) - Debbie Chen
* Bundler prepare commands with now exclude dependencies in the ignored groups [#169611326] - [e58b2870](https://github.com/pivotal/LicenseFinder/commit/e58b2870b64d2c88be7027b152a423fdb921baca) 
* Change version to be required for dependency add and updated cli options [#168705017] - [b10383d3](https://github.com/pivotal/LicenseFinder/commit/b10383d3d1990b6ad0d608044511352f13924be3) - Debbie Chen
* Ensure composer always installs the packages - [70b5e7a](https://github.com/pivotal/LicenseFinder/commit/70b5e7a42943c85bbd1d2825b2ffe94eec89020f) - kaystrobach 

* **BREAKING:** Replaced whitelist/blacklist terminology with permitted_licenses/restricted_licenses - [a40b22f](https://github.com/pivotal/LicenseFinder/commit/a40b22fda11b3a0efbb3c0a021381534bc998dd9) - grantbdev  

### Deprecated
* Remove support for jruby 9.1* [#169590215] - [81e75f8c](https://github.com/pivotal/LicenseFinder/commit/81e75f8cd61ca35e30562352dee2579b1b6c991e) 

# [5.11.1] / 2019-11-05

### Fixed
* Crash when gradle runs with project roots recursive [#169465210] - [08e0df85](https://github.com/pivotal/LicenseFinder/commit/08e0df857c7fa4273eb6e2e4a7c01bb46550a91f) 

### Changed
* Bump docker ruby version to 2.6.5 [#169539985] - [26b6d4b2](https://github.com/pivotal/LicenseFinder/commit/26b6d4b25133fa50dbf92265a20bed2350305245) 
* Gradle version updated to 5.6.4 - [9e32228f](https://github.com/pivotal/LicenseFinder/commit/9e32228fae3dacae38e7827946a0e0412a20ccb0) 

# [5.11.0] / 2019-10-24

### Fixed
* Fix crash in LF for null deps in godep - [aec335e5](https://github.com/pivotal/LicenseFinder/commit/aec335e574b65c1e9927787e88fb95f1296cdd26) 

### Changed
* Exclude Gradle subprojects from project roots - [4efea4c8](https://github.com/pivotal/LicenseFinder/commit/4efea4c8892f48c24ed6ec46a4be85cb06dc6672) - Jason Smith
* project_roots will skip maven subprojects - [61b88513](https://github.com/pivotal/LicenseFinder/commit/61b885135bd02cf2b5c6be4bc1fba85020d42f6a) - Peter Tran

# [5.10.2] / 2019-09-03

### Added
* Added bzr app to image - [8fd43f01](https://github.com/pivotal/LicenseFinder/commit/8fd43f01a5de575596c92bcfc38a5e9ba7bf6b3d) 

# [5.10.1] / 2019-08-28

### Fixed
* Mix bailing early when elixir is not installed - [13b120e](https://github.com/pivotal/LicenseFinder/commit/13b120ed7c121243be987f449cc29d00ec6e6450) 

# [5.10.0] / 2019-08-26

### Changed
* Dotnet projects only detected if csproj is at root level - [b9f810d](https://github.com/pivotal/LicenseFinder/commit/b9f810d96f92f458fcfe4855307fdddfb7f1082b) 
* sha for composer-setup.php - [64b782a](https://github.com/pivotal/LicenseFinder/commit/64b782a137a287980a317fcb48f595b6e93f85d0) - Debbie Chen

# [5.9.2] / 2019-07-02

### Changed
* Bump ruby version to 2.6.3 - [dcdcc1c](https://github.com/pivotal/LicenseFinder/commit/dcdcc1c3e4fd29ec4d180a54fb67b2aa07e932de) 

# [5.9.1] / 2019-06-10

# [5.9.0] / 2019-06-10

### Added
* composer PHP support - [c671309](https://github.com/pivotal/LicenseFinder/commit/c671309d89c54a4dfac3ac40aab1bf70e3c3f6a2) 
* composer support - [13ecaab](https://github.com/pivotal/LicenseFinder/commit/13ecaab7ee55c95ca973b74950fb10c3daea0784) - Zachary Knight
* --homepage option to `dependencies add` - [b7f7ef8](https://github.com/pivotal/LicenseFinder/commit/b7f7ef8b81d193b5535cb3c48b9244ecd446057f) 

### Fixed
* 'dotnet restore' failing - [dee1045](https://github.com/pivotal/LicenseFinder/commit/dee104517e0cf8ce769405910f46607a66017f40) 
* Reporting extra paths for gvt projects - [ba7d1bd](https://github.com/pivotal/LicenseFinder/commit/ba7d1bdd90282e7d127c3ddaf68b51f98b402000) 

### Changed
* Fix license definition tests - [15b524f](https://github.com/pivotal/LicenseFinder/commit/15b524fa52f63e04a82d160a7fc3d49c288d01e8) 

# [5.8.0] / 2019-05-22

### Added
* Trash Package Manager - [3a3d854](https://github.com/pivotal/LicenseFinder/commit/3a3d8541c4ea64607df6b120111aff324f93778d) 

### Fixed
* Prefer to use `origin` over `path` for govendor - [31c6041](https://github.com/pivotal/LicenseFinder/commit/31c6041926a27b61c35c05c6433a87d0af78c1e5) 

# [5.7.1] / 2019-03-08

# [5.7.0] / 2019-03-01

### Added
* Ruby 2.6.1 support - [8d60ed1](https://github.com/pivotal/LicenseFinder/commit/8d60ed13f99b830cc1352900f90e2b298105f518) 

### Changed
* Conan version is locked to 1.11.2 to avoid breaking changes - [72b766a](https://github.com/pivotal/LicenseFinder/commit/72b766a948be5b0f8eade75e716796f50ea9ebf3) 

# [5.6.2] / 2019-01-28

# [5.6.1] / 2019-01-25

### Changed
* Updated GOLANG to 1.11.4 in Docker image [#163424880] - [67e5e1f](https://github.com/pivotal/LicenseFinder/commit/67e5e1ffef19acf3a63cac55c5aa3626fb4c7491)

# [5.6.0] / 2018-12-19

### Added
* Add support for JSON reports [#161595251] - [5a1f735](https://github.com/pivotal/LicenseFinder/commit/5a1f73515c83cbf8ce17275c4c9d1af43d0db772) 
* Removed the removal of nested projects - [6e1941c](https://github.com/pivotal/LicenseFinder/commit/6e1941c4d06676988ff8bdad81bd83a4bb5c17e9) 
* Show verbose errors from prepare commands [#161462746] - [2b14299](https://github.com/pivotal/LicenseFinder/commit/2b142995d06572f772104c39437d0b64f9569f79) 

* Support to find gradle.kts files [#161629958] - [f7cb587](https://github.com/pivotal/LicenseFinder/commit/f7cb587787f4de282c34afe66c0a2d0c1c72a84f) 

### Fixed
* Go modules reports incorrect install paths - [9ab5aa9](https://github.com/pivotal/LicenseFinder/commit/9ab5aa9aadc9432c5359ed2af2cb32e28fac277a) 
Revert "* Go modules reports incorrect install paths" - [fcead98](https://github.com/pivotal/LicenseFinder/commit/fcead980ae2cc24f7193a1f38944f4df60a8c3fc) 

* Fix install_paths for go mod now accurately report dependency installation directories  [#161943322 finish] - [ea28c06](https://github.com/pivotal/LicenseFinder/commit/ea28c06898964043f5849b64b4043bde81a2d7cd) 
* Handle log file names created with whitespaces and slashes - [7d6f9da](https://github.com/pivotal/LicenseFinder/commit/7d6f9da5006e1e7bbb71f594188ab87ee76ddfbb) 

### Changed
* Updated go-lang to 1.11.2 in the Docker - [d720f9c](https://github.com/pivotal/LicenseFinder/commit/d720f9c16f82044b5024213bec41b8e9f34cf306) 

# [5.5.2] / 2018-10-17

### Fixed
* go mod prepare command being incorrect - [480c465](https://github.com/pivotal/LicenseFinder/commit/480c4654cde7342456318ed4e28b6cebd4a09e4b) 

# [5.5.1] / 2018-10-16

### Added
* Documentation for asterisks being added to license names [#158960018] - [154b727](https://github.com/pivotal/LicenseFinder/commit/154b7273b1c18e64afa48799b50588251f99e982) 
* Document the prepare option on the command line - [c283a38](https://github.com/pivotal/LicenseFinder/commit/c283a38d9e8b9feefc5afe32f1df55b357a33333) 

### Fixed
* Go modules are forced to be enabled on go mod package managers - [cf9123d](https://github.com/pivotal/LicenseFinder/commit/cf9123d654b98cdef872d3b21631e69960abe365) 

# [5.5.0] / 2018-10-11

### Added
* Go Module support - [8a20210](https://github.com/pivotal/LicenseFinder/commit/8a202109e942316434978befd33854aa985dd872)

### Changed
* Lowering gemspec ruby requirement to support jruby 9.1.x - [279bd25](https://github.com/pivotal/LicenseFinder/commit/279bd25bbebbd3851dcc0062c3c47f7c7063dad8)
* Bumps rubocop to 0.59.2 - [291d335](https://github.com/pivotal/LicenseFinder/commit/291d3358921dbb47bc612b77656353da07e71a2b)

### Fixed
* 'dlf' with no-args should get a login shell - [2b019fb](https://github.com/pivotal/LicenseFinder/commit/2b019fb1126ec2fcb9cafa092cad6d27b875e5f9) - Kim Dykeman
* Do not include godep dependencies with common paths - [23e951f](https://github.com/pivotal/LicenseFinder/commit/23e951fae56a43abde52ecefa73e8a5ff73bb688) 
* Remove uneeded bundle install in dlf [#160758436] - [f44c73f](https://github.com/pivotal/LicenseFinder/commit/f44c73f6c06838a29ff9a75932e08fb1445557ca) 

* dlf gemfile directory issues [#160758436 finish] - [2db3972](https://github.com/pivotal/LicenseFinder/commit/2db397261654bca89771e85984b4ae6819274e55) 
Revert "* dlf gemfile directory issues [#160758436 finish]" - [6b17ddc](https://github.com/pivotal/LicenseFinder/commit/6b17ddc4202518ffd167c8d38a2045a36eb00144) 

# [5.4.1] / 2018-09-18

### Fixed
* Extra dependencies showing up for some go projects [#160438065] - [dfb1367](https://github.com/pivotal/LicenseFinder/commit/dfb136724721843c1196e74a6b4c762538af62ba) 
* remove workspace-aggregator as a yarn dependency [#159612717 finish] - [4e0afd0](https://github.com/pivotal/LicenseFinder/commit/4e0afd0ba79623f5bb4c055d42a76ba77ce1c785) 

# [5.4.0] / 2018-08-20

### Added
* NuGet + mono installation to Dockerfile
* Add An all caps version of the 'LICENCE' spelling as a candidate file

### Changed
* Upgrades Dockerfile base to Xenial

# [5.3.0] / 2018-06-05

### Added
* Experimental support for Rust dependencies with Cargo - [2ef3129](https://github.com/pivotal/LicenseFinder/commit/2ef31290f7abf51db5b7173302d1e535508bbd7a)
* Add project roots command to list paths to scan - [b7a22ea](https://github.com/pivotal/LicenseFinder/commit/b7a22eacfac0e1b9334998de606df69ec3156f77)

### Removed
* Remove HTTParty dependency - [c52d014](https://github.com/pivotal/LicenseFinder/commit/c52d014df1ca9cd3838d03c60daa6fad954c5579) 

# [5.2.3] / 2018-05-14

# [5.2.1] / 2018-05-14

### Changed
* Updated go-lang to 1.10.2 in the Docker * Updated Maven to 3.5.3 in the Docker - [1decf6a](https://github.com/pivotal/LicenseFinder/commit/1decf6ad27c9edf96b4f5cccd9a7ca0955fed9f2) - Mark Fioravanti

# [5.2.0] / 2018-05-09

### Fixed
* Support for pip 10.0.1 - [286f679](https://github.com/pivotal/LicenseFinder/commit/286f6790dc71c97c0e93ecdfe0c6fddad75165cc)

# [5.1.1] / 2018-05-08

### Added
* CC License detection

### Fixed
* Yarn package manager now handles non-ASCII characters
* in_umbrella: true dependencies for Mix
* Pivotal Repo Renamed to pivotal

# [5.1.0] / 2018-04-02

### Added
* Support for Ruby 2.5.1 - [9c82a84](https://github.com/pivotal/LicenseFinder/commit/9c82a84a3cff0765a45fa28dc2b05ab32880fb00) 
* Support for Scala build Tool (sbt ) - [2115ddf](https://github.com/pivotal/LicenseFinder/commit/2115ddfe9481d17e6b1d0ac63d6ae1c6143f370c) - Bradford D. Boyle
* Condense gvt paths with identical shas into their common path - [9e1071d](https://github.com/pivotal/LicenseFinder/commit/9e1071d3c92405a8605727ad1164d6581dc50533)

### Fixed
* Added back the pip prepare commands [#156376451 finish] - [fdd63fb](https://github.com/pivotal/LicenseFinder/commit/fdd63fb38332230e0cce0ee1b47aa5ccd0eebc36) 
* Govendor not consolidating common paths from the same SHA - [bdd23c9](https://github.com/pivotal/LicenseFinder/commit/bdd23c94ae6ff09a2466c8875e554de60db6603c) 

### Deprecated
* Support for Ruby 2.1 
* Support for Ruby 2.2 
* Support for jruby - [9c82a84](https://github.com/pivotal/LicenseFinder/commit/9c82a84a3cff0765a45fa28dc2b05ab32880fb00) 

# [5.0.3] / 2018-02-13

### Changed
* Add the -vendor-only flag to dep-ensure calls - [e305bd1](https://github.com/pivotal/LicenseFinder/commit/e305bd1d5b2d9653f828c3940b59a12903904699) 
* Update detected paths for Nuget - [3fe8995](https://github.com/pivotal/LicenseFinder/commit/3fe89955d82c3467628abbd2ca9ba159bfeb7df6)

# [5.0.2] / 2018-02-06

### Fixed
* Add conditional production flag to npm - [533f9b8](https://github.com/pivotal/LicenseFinder/commit/533f9b8fda250655f3613444da49fdce60215237) 
* conan install & info commands - [322e64c](https://github.com/pivotal/LicenseFinder/commit/322e64c402f4e45d97c6f3bf67c3ffdaabbb359f) 
* Duplicate approvals in decisions file - [a8e6141](https://github.com/pivotal/LicenseFinder/commit/a8e6141cd7ac7ed2aa10b35c55954a48bacf3523) 
* log path issues - [9f1bae1](https://github.com/pivotal/LicenseFinder/commit/9f1bae12c88771229e0a919876f4de6bcad31677) 

* Fix yarn not working with --project_path option - [c6ed08d](https://github.com/pivotal/LicenseFinder/commit/c6ed08dd8342dec9fcc3e6377f88d5ef01600928) 

# [5.0.0] / 2018-01-15

### Added
* NPM prepare - [e7a0d30](https://github.com/pivotal/LicenseFinder/commit/e7a0d30cb77e5503b5a934b26dbd3dc272dc5605) 
* Specify log directory for prepare - [b9a5991](https://github.com/pivotal/LicenseFinder/commit/b9a599171f3fda2affa9381d998e2158a2bf7fac) 

* Added prepare step for elixir projects - [38b08ea](https://github.com/pivotal/LicenseFinder/commit/38b08eae23b6b0c2bbaa3aea7845ab6a8d9b028b) 

### Fixed
* Action_items resolves decisions file path - [c2a92ab](https://github.com/pivotal/LicenseFinder/commit/c2a92ab62203efb890dfeb1798d377c8d835feb6) 

* Bower prepare step - [bb11d7f](https://github.com/pivotal/LicenseFinder/commit/bb11d7f07cc5e436381f01245a46033af6bb2d3b) 

### Changed
* Package Manager will now log if prepare step fails. Instead of erroring out - [54da71e](https://github.com/pivotal/LicenseFinder/commit/54da71e98f14cd199c39dfd7b762030fcac60ccb) 

# [4.0.2] / 2017-11-16

### Fixed

* Fixed --quiet not being available on the report task
* Fixed --recursive not being available on the action_items task

# [4.0.1] / 2017-11-14

### Fixed

* Add missing toml dependency to gemspec

# [4.0.0] / 2017-11-10

### Changed

* CLI output has been altered to be clear about active states and installed states.
* option `--subprojects`have been renamed to `--aggregate_paths` in order to be clear about its functionality

### Fixed

* Fixed issue where dangling symbolic link would cause License Finder to crash and not continue. Instead, License Finder will now warn about the issue and continue.

# [3.1.0] / 2017-11-10

### Added

* Added support for [Carthage](https://github.com/Carthage/Carthage) 
* Added support for [gvt](https://github.com/FiloSottile/gvt)
* Added support for [yarn](https://yarnpkg.com/en/)
* Added support for [glide](https://github.com/Masterminds/glide)
* Added support for [GoVendor](https://github.com/kardianos/govendor)
* Added support for [Dep](https://github.com/golang/dep)
* Added support for [Conan](https://conan.io/)
* Added `--prepare` option
  * `--prepare`/`-p` is an option which can now be passed to the `action_items` or `report` task of `license_finder`
  * `prepare` will indicate to License Finder that it should attempt to prepare the project before running in a License scan.

### Changed

* Upgrade `Gradle` in Dockerfile
* Clean up some CLI interaction and documentation

### Fixed

* `build-essential` was added back into the Dockerfile after accidentally being removed
* Ignore leading prefixes such as 'The' when looking for licenses

# [3.0.4] / 2017-09-14

### Added
* Added concourse pipeline file for Docker image process (#335, #337)
* Add status checks to pull requests
* Allow Custom Pip Requirements File Path (#328, thanks @sam-10e)

### Fixed
* Fixed NPM stack too deep issue (#327, #329)

# [3.0.3] / Skipped because of accidentally yanking gem

# [3.0.2] / 2017-07-27:

### Added

* Add CI status checks to pull requests (#321)

### Fixed

* Support NPM packages providing a string for the licenses key (#317)
* Use different env-var to indicate ruby version for tests (#303)
* Resolve NPM circular dependencies (#306, #307, #311, #313, #314, #319, #322)

# [3.0.1] / 2017-07-12:

### Added

* Add --maven-options to allow options for maven scans (#305, thanks @jgielstra!)

### Fixed:

* Restore the original GOPATH after modifying it (#287, thanks @sschuberth!)
* LF doesn't recognize .NET projects using 'packages' directory (#290, #292, thanks @bspeck!)
* Use glob for finding acknowledgements path for CocoaPods (#177, #288, thanks @aditya87!)
* Fix some failing tests on Windows (#294, thanks @sschuberth!)
* Add warning message if no dependencies are recognized (#293, thanks @bspeck!)
* Switch to YAJL for parsing the json output from npm using a tmp file rather than an in-memory string (#301, #304)
* Fix dockerfile by explicitly using rvm stable (#303)
* Report multiple versions of the same NPM dependency (#310)

# [3.0.0] / 2016-03-02

### Added

* Changed dependencies to be unique based on name _and_ version (#241)
* Enable '--columns' option with text reports (#244, thanks @raimon49!)
* Flag maven-include-groups adds group to maven depenency information (#219, #258, thanks @dgodd!)
* Package managers determine their package management command (#250, Thanks @sschuberth!)
* Support --ignored_groups for maven
* Support `homepage` column for godeps dependencies, and dependencies from go workspaces using `.envrc`
* Support `license_links` column for csv option (#281, Thanks @lbalceda!)
* Added a Dockerfile for [licensefinder/license_finder](https://hub.docker.com/r/licensefinder/license_finder/)
* Switched from Travis to Concourse

### Fixed

* Gradle works in CI containers where TERM is not set (revert and fix of c15bdb7, which broke older versions of gradle)
* Check for the correct Ruby Bundler command: `bundle` (#233. Thanks, @raimon49!)
* Uses settings.gradle to determine the build file name (#248)
* Fix detecting the Gradle wrapper if not scanning the current directory (#238, Thanks @sschuberth!)
* Use maven wrapper if available on maven projects
* Check golang package lists against standard packages instead of excluding short package paths (#243)
* Update the project_sha method to return the sha of the dependency, not the parent project
* Change Maven wrapper to call mvn.cmd and fall back on mvn.bat (#263, Thanks @sschuberth!)
* Allow bower to run as root
* Fix packaging errors scanning pip based projects
* Add JSON lib attribute to handle deeply nested JSON (#269. Thanks, @antongurov!)
* Use the fully qualified name of the license-maven-plugin (#284)

# 2.1.2 / 2016-06-10

Bugfixes:

* NuGet limits its recursive search for .nupkg packages to the `vendor` subdirectory. (#228)


# 2.1.1 / 2016-06-09

Features:

* GoWorkspace now detects some non-standard package names with only two path parts. (#226)

Bugfixes:

* NuGet now appropriately returns a Pathname from #package_path (previously was a String) (#227)
* NuGet now correctly chooses a directory with vendored .nupkg packages


# 2.1.0 / 2016-04-01

* Features
  * support a `groups` in reports (#210) (Thanks, Jon Wolski!)
  * GoVendor and GoWorkspace define a package management tool, so they won't try to run if you don't have `go` installed
  * PackageManagers are not activated if the underlying package management tool isn't installed
  * detect GO15VENDOREXPERIMENT as evidence of a go workspace project
  * provide path-to-dependency in recursive mode (#193)
  * dedup godep dependencies (#196)
  * add support for MPL2 detection
  * detect .envrc in a parent folder (go workspaces) (#199)
  * miscellaneous nuget support improvements (#200, #201, #202)
  * miscellaneous go support improvements (#203, #204)
  * add support for Golang 1.5 vendoring convention (#207)
  * return the package manager that detected the dependency (#206)
  * Add support for including maven/gradle GroupIds with `--gradle-include-groups`
  * Godep dependencies can display the full commit SHA with `--go-full-version`
  * specific versions of a dependency can be approved (#183, #185). (Thanks, @ipsi!)
  * improved "go workspace" support by looking at git submodules. (Thanks, @jvshahid and @aminjam!)
  * added an "install path" field to the report output. (Thanks, @jvshahid and @aminjam!)
  * Licenses can be blacklisted.  Dependencies which only have licenses in the blacklist will not be approved, even if someone tries.
  * Initial support for the Nuget package manager for .NET projects
  * Experimental support for `godep` projects
  * Experimental support for "golang workspace" projects (with .envrc)
  * Improved support for multi-module `gradle` projects
  * Gradle 2.x support (experimental)
  * Experimental support for "composite" projects (multiple git submodules)
  * Experimental support for "license diffs" between directories

* Bugfixes
  * `rubyzip` is now correctly a runtime dependency
  * deep npm dependency trees no longer result in some packages having no metadata (#211)
  * columns fixed in "recursive mode" (#191)
  * gradle's use of termcaps avoided (#194)


# 2.0.4 / 2015-04-16

* Features

  * Allow project path to be set in a command line option (Thanks, @robertclancy!)


# 2.0.3 / 2015-03-18

* Bugfixes

  * Ignoring subdirectories of a LICENSE directory. (#143) (Thanks, @pmeskers and @yuki24!)


# 2.0.2 / 2015-03-14

* Features

  * Show requires/required-by relationships for pip projects
  * Expose homepage in CSV reports
  * Support GPLv3

* Bugfixes

  * license_finder works with Python 3; #140
  * For pip projects, limit output to the distributions mentioned in
    requirements.txt, or their dependencies, instead of all installed
    distributions, which may include distributions from other projects. #119


# 2.0.1 / 2015-03-02

* Features

  * Support for rebar projects


# 2.0.0 / 2015-03-02

* Features

  * Stores every decision that has been made about a project's dependencies,
    even if a decision was later reverted.  These decisions are kept in an
    append-only YAML file which can be considered an audit log.
  * Stores timestamps and other optional transactional metadata (who, why)
    about every kind of decision.
  * When needed, applies those decisions to the list of packages currently
    reported by the package managers.
  * Removed dependencies on sqlite and sequel.
  * The CLI never writes HTML or CSV reports to the file system, only to
    STDOUT. So, users have more choice over which reports to generate, when to
    generate them, and where to put them. See `license_finder report`.  If you
    would like to update reports automatically (e.g., in a rake task or git
    hook) see this gist: https://gist.github.com/mainej/1a4d61a92234c5cebeab.
  * The configuration YAML file is no longer required, though it can still be
    useful.  Most of its functionality has been moved into the decisions
    infrastructure, and the remaining bits can be passed as arguments to the
    CLI.  Most users will not need these arguments.  If the file is present, the
    CLI arguments can be omitted.  The CLI no longer updates this file.
  * Requires pip >= 6.0

* Bugfixes

  * `license_finder` does not write anything to the file system, #94, #114, #117


# 1.2.1 / unreleased

* Features

  * Can list dependencies that were added manually


# 1.2 / 2014-11-10

* Features

  * Adding support for CocoaPods >= 0.34. (#118)
  * For dependencies with multiple licenses, the name of each license is
    listed, and if any are whitelisted, the dependency is whitelisted
  * Added `--debug` option when scanning, to provide details on
    packages, dependencies and where each license was discovered.


# 1.1.1 / 2014-07-29

* Bugfixes

  * Process incorrectly-defined dependencies.
    [Original issue.](https://github.com/pivotal/LicenseFinder/issues/108)
  * Allow license_finder to process incorrectly-defined dependencies.


# 1.0.1 / 2014-05-28

* Features

  * For dependencies with multiple licenses, the dependency is listed as
    'multiple licenses' along with the names of each license
  * Added 'ignore_dependencies' config option to allow specific
    dependencies to be excluded from reports.

* Bugfixes

  * Dependency reports generate when license_finder.yml updates
  * Dependency reports generate when config is changed through the command line


# 1.0.0.1 / 2014-05-23

* Bugfixes

  * LicenseFinder detects its own license


# 1.0.0 / 2014-04-03

* Features

  * When approving a license, can specify who is approving, and why.
  * Remove `rake license_finder` task from Rails projects.  Just include
    'license_finder' as a development dependency, and run `license_finder` in
    the shell.


# 0.9.5.1 / 2014-01-30

* Features

  * Adds homepage for Bower, NPM, and PIP packages


# 0.9.5 / 2014-01-30

* Features

  * Add more aliases for known licenses
  * Drop support for ruby 1.9.2
  * Large refactoring to simply things, and make it easier to add new package managers

* Bugfixes

  * Make node dependency json parsing more robust
  * Clean up directories created during test runs


# 0.9.4 / 2014-01-05

* Features

  * Add detailed csv report
  * Add markdown report
  * Add support for "licenses" => ["license"] (npn)
  * Add basic bower support
  * Allow adding/removing multiple licenses from whitelist

* Bugfixes

  * Use all dependencies by default for npm as bundler does


# 0.9.3 / 2013-10-01

* Features

  * New Apache 2.0 license alias

* Bugfixes

  * Fix problem which prevented license finder from running in rails < 3.2


# 0.9.2 / 2013-08-17

* Features

  * Support for python and node.js projects

* Bugfixes

  * Fix HTML output in firefox


# 0.9.1 / 2013-07-30

* Features

  * Projects now have a title which can be configured from CLI
  * JRuby officially supported. Test suite works against jruby, removed 
    warnings
  * Internal clean-up of database behavior
  * Updated documentation with breakdown of HTML report

* Bugfixes

  * dependencies.db is no longer modified after license_finder runs and finds
    no changes
  * Fix more CLI grammar/syntax errors
  * HTML report now works when served over https (PR #36 - bwalding)
  * dependencies.txt is now dependencies.csv (It was always a csv in spirit)


# 0.9.0 / 2013-07-16

* Features

  * Clarify CLI options and commands in help output
  * Can manage whitelisted licenses from command line
  * Improved New BSD license detection

* Bugfixes

  * Fix CLI grammar errors
  * Using license_finder in a non-RVM environment now works (Issue #35)


# 0.8.2 / 2013-07-09

* Features

  * Switch to thor for CLI, to support future additions to CLI
  * Restore ability to manage (add/remove) dependencies that Bundler can't find
  * Can maintain ignored bundler groups from command line

* Bugfixes

  * Fix bug preventing manual approval of child dependencies (Issue #23)
  * Fix issue with database URI when the absolute path to the database file
    contains spaces.
  * Upgrading from 0.7.2 no longer removes non-gem dependencies (Issue #20)


# 0.8.1 / 2013-04-14

* Features

  * JRuby version of the gem.
  * Official ruby 2.0 support.
  * CLI interface for moving dependencies.* files to `doc/`.

* Bugfixes

  * Fix ruby 1.9.2 support.


# 0.8.0 / 2013-04-03

* Features

  * Add spinner to show that the binary is actually doing something.
  * Add action items to dependencies.html.
  * Add generation timestamp to dependencies.html.
  * Default location for dependencies.* files is now `doc/`.
  * Temporarily remove non-bundler (e.g. JavaScript) dependencies. This will
    be readded in a more sustainable way soon.
  * Use sqlite, not YAML, for dependencies.
  * Officially deprecate rake tasks.

* Bugfixes

  * Don't blow away manually set licenses when dependencies are rescanned.
  * Ignore empty `readme_files` section in dependencies.yml.
  * Clean up HTML generation for dependencies.html.
  * Add an option to silence the binary's spinner so as not to fill up log
    files.


# 0.7.2 / 2013-02-18

* Features

  * Dependency cleanup.


# 0.7.1 / 2013-02-18

* Features

  * Add variants to detectable licenses.
  * Remove README files from data persistence.


# 0.7.0 / 2012-09-25

* Features

  * Dependencies can be approved via CLI.
  * Dependencies licenses can be set via CLI.


# 0.6.0 / 2012-09-15

* Features

  * Create a dependencies.html containing a nicely formatted version of
    dependencies.txt, with lots of extra information.
  * All rake tasks, and the binary, run the init task automatically.
  * Simplify dependencies.txt file since more detail can now go into
    dependencies.html.
  * Promote binary to be the default, take first steps to deprecate rake task.

* Bugfixes

  * Fix formatting of `rake license:action_items` output.


# 0.5.0 / 2012-09-12

* Features

  * `rake license:action_items` exits with a non-zero status if there are
    non-approved dependencies.
  * New binary, eventual replacement for rake tasks.
  * Initial implementation of non-gem dependencies.
  * Support BSD, New BSD, and Simplified BSD licenses.
  * Improve ruby license detection.
  * Add dependency's bundler group to dependencies.txt output.
  * Add description and summary to dependencies.txt output.

* Bugfixes

  * Create `config/` director if it doesn't exist, don't blow up.
  * Better support for non-US word spellings.


# 0.4.5 / 2012-09-09

* Features

  * Allow dependencies.* files to be written to a custom directory.
  * Detect LGPL licenses
  * Detect ISC licenses

* Bugfixes

  * Fix blow up if there's not `ignore_groups` setting in the config file.


[Unreleased]: https://github.com/pivotal/LicenseFinder/compare/v4.0.2...HEAD
[4.0.2]: https://github.com/pivotal/LicenseFinder/compare/v4.0.1...v4.0.2
[4.0.1]: https://github.com/pivotal/LicenseFinder/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/pivotal/LicenseFinder/compare/v3.1.0...v4.0.0
[3.1.0]: https://github.com/pivotal/LicenseFinder/compare/v3.0.4...v3.1.0
[3.0.4]: https://github.com/pivotal/LicenseFinder/compare/v3.0.2...v3.0.4
[3.0.2]: https://github.com/pivotal/LicenseFinder/compare/v3.0.1...v3.0.2
[3.0.1]: https://github.com/pivotal/LicenseFinder/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/pivotal/LicenseFinder/compare/v2.1.2...v3.0.0
[5.0.0]: https://github.com/pivotal/LicenseFinder/compare/v4.0.2...v5.0.0
[5.0.2]: https://github.com/pivotal/LicenseFinder/compare/v5.0.0...v5.0.2
[5.0.3]: https://github.com/pivotal/LicenseFinder/compare/v5.0.2...v5.0.3
[5.1.0]: https://github.com/pivotal/LicenseFinder/compare/v5.0.3...v5.1.0
[5.1.1]: https://github.com/pivotal/LicenseFinder/compare/v5.1.0...v5.1.1
[5.1.1]: https://github.com/pivotal/LicenseFinder/compare/v5.1.0...v5.1.1
[5.2.0]: https://github.com/pivotal/LicenseFinder/compare/v5.1.1...v5.2.0
[5.2.1]: https://github.com/pivotal/LicenseFinder/compare/v5.2.0...v5.2.1
[5.2.3]: https://github.com/pivotal/LicenseFinder/compare/v5.2.1...v5.2.3
[5.3.0]: https://github.com/pivotal/LicenseFinder/compare/v5.2.3...v5.3.0
[5.4.0]: https://github.com/pivotal/LicenseFinder/compare/v5.3.0...v5.4.0
[5.4.1]: https://github.com/pivotal/LicenseFinder/compare/v5.4.0...v5.4.1
[5.5.0]: https://github.com/pivotal/LicenseFinder/compare/v5.4.1...v5.5.0
[5.5.1]: https://github.com/pivotal/LicenseFinder/compare/v5.5.0...v5.5.1
[5.5.2]: https://github.com/pivotal/LicenseFinder/compare/v5.5.1...v5.5.2
[5.6.0]: https://github.com/pivotal/LicenseFinder/compare/v5.5.2...v5.6.0
[5.6.1]: https://github.com/pivotal/LicenseFinder/compare/v5.6.0...v5.6.1
[5.6.2]: https://github.com/pivotal/LicenseFinder/compare/v5.6.1...v5.6.2
[5.7.0]: https://github.com/pivotal/LicenseFinder/compare/v5.6.2...v5.7.0
[5.7.1]: https://github.com/pivotal/LicenseFinder/compare/v5.7.0...v5.7.1
[5.8.0]: https://github.com/pivotal/LicenseFinder/compare/v5.7.1...v5.8.0
[5.9.0]: https://github.com/pivotal/LicenseFinder/compare/v5.8.0...v5.9.0
[5.9.1]: https://github.com/pivotal/LicenseFinder/compare/v5.9.0...v5.9.1
[5.9.2]: https://github.com/pivotal/LicenseFinder/compare/v5.9.1...v5.9.2
[5.10.0]: https://github.com/pivotal/LicenseFinder/compare/v5.9.2...v5.10.0
[5.10.1]: https://github.com/pivotal/LicenseFinder/compare/v5.10.0...v5.10.1
[5.10.2]: https://github.com/pivotal/LicenseFinder/compare/v5.10.1...v5.10.2
[5.11.0]: https://github.com/pivotal/LicenseFinder/compare/v5.10.2...v5.11.0
[5.11.1]: https://github.com/pivotal/LicenseFinder/compare/v5.11.0...v5.11.1
[6.0.0]: https://github.com/pivotal/LicenseFinder/compare/v5.11.1...v6.0.0
[6.1.0]: https://github.com/pivotal/LicenseFinder/compare/v6.0.0...v6.1.0
[6.1.2]: https://github.com/pivotal/LicenseFinder/compare/v6.1.0...v6.1.2
[6.2.0]: https://github.com/pivotal/LicenseFinder/compare/v6.1.2...v6.2.0
[6.3.0]: https://github.com/pivotal/LicenseFinder/compare/v6.2.0...v6.3.0
[6.4.0]: https://github.com/pivotal/LicenseFinder/compare/v6.3.0...v6.4.0
[6.5.0]: https://github.com/pivotal/LicenseFinder/compare/v6.4.0...v6.5.0
[6.6.0]: https://github.com/pivotal/LicenseFinder/compare/v6.5.0...v6.6.0
[6.6.1]: https://github.com/pivotal/LicenseFinder/compare/v6.6.0...v6.6.1
[6.6.2]: https://github.com/pivotal/LicenseFinder/compare/v6.6.1...v6.6.2
[6.7.0]: https://github.com/pivotal/LicenseFinder/compare/v6.6.2...v6.7.0
[6.8.0]: https://github.com/pivotal/LicenseFinder/compare/v6.7.0...v6.8.0
[6.8.1]: https://github.com/pivotal/LicenseFinder/compare/v6.8.0...v6.8.1
[6.8.2]: https://github.com/pivotal/LicenseFinder/compare/v6.8.1...v6.8.2
[6.9.0]: https://github.com/pivotal/LicenseFinder/compare/v6.8.2...v6.9.0
[6.10.0]: https://github.com/pivotal/LicenseFinder/compare/v6.9.0...v6.10.0
[6.10.1]: https://github.com/pivotal/LicenseFinder/compare/v6.10.0...v6.10.1
[6.11.0]: https://github.com/pivotal/LicenseFinder/compare/v6.10.1...v6.11.0
[6.12.0]: https://github.com/pivotal/LicenseFinder/compare/v6.11.0...v6.12.0
[6.12.1]: https://github.com/pivotal/LicenseFinder/compare/v6.12.0...v6.12.1
[6.12.2]: https://github.com/pivotal/LicenseFinder/compare/v6.12.1...v6.12.2
[6.13.0]: https://github.com/pivotal/LicenseFinder/compare/v6.12.2...v6.13.0
[6.14.1]: https://github.com/pivotal/LicenseFinder/compare/v6.13.0...v6.14.1
