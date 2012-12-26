require 'curses'
require 'yaml'
require 'cigarette/numeric.rb'

class Cigarette

  DEFAULT = Curses::A_NORMAL
  BLACK   = 0
  RED     = 1
  GREEN   = 2
  YELLOW  = 3
  BLUE    = 4
  MAGENTA = 5
  CYAN    = 6
  WHITE   = 7

  VERSION = "1.2"
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
    init_curses
    deploy_trap
    lighter_please!
  end

  private

  def display_main_screen
    Curses.clear
    display(0,0, "cigarette - Version #{VERSION}")
    display(2, 10, "#{@banner} - #{@current_time.strftime("at: %T")}")
    display(2, 2, "STATUS:")
    display(4, 0, @output)
    Curses.refresh
  end

  def lighter_please!
    while CANCER_DO_NOT_APPEAR
      sleep 0.1
      if @current_time.nil? || time_to_light_up?
        @current_time = Time.now if @current_time.nil?
        @output = `#{@command} 2>&1`
        status = $?.success? unless defined? status
        current_status = $?.success?
        @banner = ($?.success? ? "SUCCESS" : "ERROR(S)")
        display_main_screen
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

  def init_curses
    Curses.noecho # do not show typed keys
    Curses.init_screen
    Curses.stdscr.keypad(true) # enable arrow keys
    Curses.start_color
    Curses.init_pair(RED, RED, BLACK)
    Curses.init_pair(GREEN, GREEN, BLACK)
    Curses.init_pair(MAGENTA, MAGENTA, WHITE)
    Curses.init_pair(CYAN, CYAN, BLACK)
    display(2, 2, "STATUS:")
    display(2, 10, "WAITING")
    Curses.refresh
  end

  def deploy_trap
    for i in 1 .. 15  # SIGHUP .. SIGTERM
      if trap(i, "SIG_IGN") != 0 then  # 0 for SIG_IGN
        trap(i) {|sig| onsig(sig) }
      end
    end
  end

  def display(line, column, text, color = DEFAULT)
    Curses.setpos(line, column)
    Curses.attron(Curses.color_pair(color | DEFAULT)) { Curses.addstr(text) }
  end

  def onsig(sig)
    Curses.close_screen
    exit sig
  end

end

