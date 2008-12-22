require 'rake'

PKG_FILES = %w(init.rb Rakefile recurrence.gemspec History.txt License.txt README.markdown TODO.txt) + 
  Dir["lib/**/*"]

spec = Gem::Specification.new do |s|
  s.name = "recurrence"
  s.version = "0.0.5"
  s.summary = "A simples library that handles recurring events"
  s.authors = ["Nando Vieira"]
  s.email = ["fnando.vieira@gmail.com"]
  s.homepage = "http://github.com/fnando/recurrence"
  s.description = ""
  s.has_rdoc = false
  s.files = PKG_FILES
	
  s.add_dependency "rubigen"
  s.add_dependency "activesupport"
end

namespace :gem do
  # Thanks to the Merb project for this code.
  desc "Update Github Gemspec"
  task :update_gemspec do
    skip_fields = %w(new_platform original_platform specification_version loaded required_ruby_version rubygems_version platform )
    
    result = "# WARNING : RAKE AUTO-GENERATED FILE. DO NOT MANUALLY EDIT!\n"
    result << "# RUN : 'rake gem:update_gemspec'\n\n"
    result << "Gem::Specification.new do |s|\n"
    
    spec.instance_variables.each do |ivar|
      value = spec.instance_variable_get(ivar)
      name  = ivar.split("@").last
      next if name == "date"
      
      next if skip_fields.include?(name) || value.nil? || value == "" || (value.respond_to?(:empty?) && value.empty?)
      if name == "dependencies"
        value.each do |d|
          dep, *ver = d.to_s.split(" ")
          result <<  "  s.add_dependency #{dep.inspect}, #{ver.join(" ").inspect.gsub(/[()]/, "").gsub(", runtime", "")}\n"
        end
      else
        case value
        when Array
          value =  name != "files" ? value.inspect : value.inspect.split(",").join(",\n")
        when FalseClass
        when TrueClass
        when Fixnum
        when String
          value = value.inspect
        else
          value = value.to_s.inspect
        end
        result << "  s.#{name} = #{value}\n"
      end
    end
    
    result << "end"
    File.open(File.join(File.dirname(__FILE__), "#{spec.name}.gemspec"), "w"){|f| f << result}
  end
  
  desc "Build gem"
  task :build => [:update_gemspec] do
    system "gem build #{spec.instance_variable_get('@name')}.gemspec"
  end
  
  desc "Install gem"
  task :install => [:update_gemspec, :build] do
    system "sudo gem install #{spec.instance_variable_get('@name')}"
  end
end

desc "Execute specs"
task :spec do
  system "spec spec/recurrence_spec.rb -c -f s"
end