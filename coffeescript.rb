require 'rubygems'
require 'coffee-script'

module Jekyll
  class Site
    def coffee2js
      coffee_folder = self.config['coffeescript_folder'] || '**/*.coffee'
      compile_coffeescript(["*.coffee", coffee_folder], /\.coffee$/, '.js')
    end

    private

    def compile_coffeescript(files, input_regex, output_extension)
      Dir.glob(files).each do |f|
        begin
          origin = File.open(f).read
          result = CoffeeScript.compile(origin)
          raise CoffeeScriptException.new if result.empty?
          output_file_name = f.gsub!(input_regex,output_extension).gsub('coffee/', 'js/')
          puts "Rendering #{f} -> #{output_file_name}"
          File.open(output_file_name,'w') do |o|
            o.write(result) if !File.exists?(output_file_name) or (File.exists?(output_file_name) and result != File.read(output_file_name))
          end
        rescue CoffeeScriptException => e
        end
      end
    end
  end

  class CoffeeScriptException < Exception
  end

  AOP.before(Site, :render) do |site_instance, result, args|
    site_instance.coffee2js
  end

  AOP.around(Site, :filter_entries) do |site_instance, args, proceed, abort|
    result = proceed.call
    result.reject{ |entry| entry.match(/\.coffee$/)}
  end
end
