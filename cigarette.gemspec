t = Time.now
Gem::Specification.new do |s|
  s.name        = "cigarette"
  s.version     = "2.0"
  s.date        = t.strftime("%Y-%m-%d")
  s.summary     = "Tiny test tool"
  s.description = "Tiny test tool"
  s.authors     = ["Thibaut Deloffre"]
  s.email       = 'tib@rocknroot.org'
  s.files       = ["lib/cigarette.rb",
                   "lib/cigarette/numeric.rb",
                   "lib/cigarette/rvm.rb",
                   "lib/cigarette/colors.rb"]
  s.executables = ["cigarette"]
  s.extra_rdoc_files = ["LICENSE.txt"]
  s.homepage    = 'https://github.com/TibshoOT/cigarette'
  s.licenses    = ["BSD"]
end
