require 'yaml'
require 'cigarette/numeric.rb'

class Cigarette

  VERSION = "1.0"
  # Hope.
  CANCER_DO_NOT_APPEAR = 42

  def initialize
    begin
      cnf = YAML::load(File.open("#{Dir.pwd}/.cigarette"))
      @time = (cnf[:each] || cnf['each']).to_i
      @next_check = Time.now.to_i + @time
      @command = cnf[:command] || cnf['command']
    rescue TypeError
      abort "Didn't you make a mistake in .cigarette file ?"
    rescue ArgumentError
      abort "Did you configure attribute like this: 'attribute: <value>'"
    rescue Exception => e
      abort "Problem during .cigarette loading: #{e.message}"
    end
    puts "Cigarette launched - version #{VERSION}."
    lighter_please!
  end

  private

  def lighter_please!
    while CANCER_DO_NOT_APPEAR
      sleep 0.1
      if time_to_light_up?
        output = `#{@command} 2>&1`
        status = $?.success? unless defined? status
        current_status = $?.success?
        banner = ($?.success? ? "SUCCESS" : "ERROR(S)")
        puts "#{banner} - #{@current_time.strftime("at: %T")}"
        if status != current_status
          puts output
        end
        status = current_status
      end
    end
  end

  def time_to_light_up?
    @current_time = Time.now
    if @current_time.to_i >= @next_check
      @next_check = Time.now.to_i + @time
      true
    else
      false
    end
  end

end

