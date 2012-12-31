require 'curses'
require 'yaml'
require 'cigarette/colors'
require 'cigarette/numeric'
require 'cigarette/rvm'

class Cigarette
  include Colors

  VERSION = "2.1"
  # Hope.
  CANCER_DO_NOT_APPEAR = 42

  def initialize
    begin
      cnf = YAML::load(File.open("#{Dir.pwd}/.cigarette"))
      unless cnf["rvm"].nil?
        @rubies = cnf["rvm"]
        raise "rvm error in yaml. You have to put a list. (-)" unless @rubies.is_a? Array
      else
        RVM.use_system!
        @rubies = [RUBY_VERSION]
      end
      @time = cnf['each'].to_i
      @next_check = Time.now.to_i + @time
      @command = cnf['command']
    rescue NoMethodError
      abort "Problem during .cigarette loading: 'each:' and 'command:' attributes are MANDATORY."
    rescue TypeError
      abort "Didn't you make a mistake in .cigarette file ?"
    rescue ArgumentError
      abort "Did you configure attribute like this: 'attribute: <value>'."
    rescue Exception => e
      abort "Problem during .cigarette loading: #{e.message}."
    end
    deploy_trap
    init_curses
    roll_baby_roll!
    lighter_please!
  end

  private

  def display_main_screen(status, output, time, color = DEFAULT)
    Curses.clear
    display_menu
    display(0,0, "cigarette - Version #{VERSION}")
    display(4, 8, status, color)
    padding_for_time = 8 + status.length
    display(4, padding_for_time," - #{time.strftime("%T")}")
    display(4, 0, "STATUS:")
    display(6, 0, output)
    Curses.refresh
  end

  def lighter_please!
    #initial position
    @pos = 0
    while CANCER_DO_NOT_APPEAR
      sleep 0.1
      case Curses.getch
        when Curses::Key::RIGHT then move_right
        when Curses::Key::LEFT then move_left
        when ?r then rebuild
        when ?q then onsig
      end
    end
  end

  def roll_baby_roll!
    @current_rb = @rubies.first
    @t_array = []
    @outputs = {}
    @rubies.each { |ruby|
      @t_array << Thread.new {
        # Run test(s) at cigarette start
        next_check = 0
        while CANCER_DO_NOT_APPEAR
          time = Time.now.to_i
          if time >= next_check
            @outputs[ruby.to_s] = RVM.run(ruby) { @command }
            next_check = time + @time
            if @current_rb.eql?(ruby)
              out = @outputs[ruby.to_s]
              display_main_screen(out[:status], out[:output],
                                  out[:time], out[:color])
            end
          end
          sleep 0.1
        end
      }
    }
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
    Curses.init_pair(Colors::RED, RED, BLACK)
    Curses.init_pair(GREEN, GREEN, BLACK)
    Curses.init_pair(MAGENTA, MAGENTA, WHITE)
    Curses.init_pair(CYAN, CYAN, BLACK)
    display(0,0, "WAIT, INITIALIZATION...")
    Curses.refresh
  end

  def deploy_trap
    for i in 1..15  # SIGHUP .. SIGTERM
      if trap(i, "SIG_IGN") != 0 then  # 0 for SIG_IGN
        trap(i) { |sig| onsig(sig) }
      end
    end
  end

  def display(line, column, text, color = DEFAULT)
    Curses.setpos(line, column)
    Curses.attron(Curses.color_pair(color | DEFAULT)) { Curses.addstr(text) }
  end

  def display_menu
    padding = 0
    @rubies.each { |ruby|
      if !@outputs[ruby.to_s].nil?
        color =  @outputs[ruby.to_s][:color]
      else
        color = RED
      end
      color = MAGENTA if ruby.eql?(@current_rb) && @rubies.length > 1
      display(2, padding, ruby, color)
      padding += 8
    }
  end

  def rebuild
    @current_rb = @rubies[@pos]
    @outputs[@current_rb] = RVM.run(@current_rb) { @command }
    out = @outputs[@current_rb]
    display_main_screen(out[:status], out[:output], out[:time], out[:color])
  end

  def move
    @current_rb = @rubies[@pos]
    out = @outputs[@rubies[@pos]]
    display_main_screen(out[:status], out[:output], out[:time], out[:color])
  end

  def inc_pos
    if @pos == @rubies.length - 1
      @pos = 0
    else
      @pos += 1
    end
  end

  def move_right
    inc_pos
    move
  end

  def dec_pos
    if @pos == 0
      @pos = @rubies.length - 1
    else
      @pos -= 1
    end
  end

  def move_left
    dec_pos
    move
  end

  def onsig(sig = nil)
    Curses.close_screen
    @t_array.each { |t| Thread.kill(t) } unless @t_array.nil?
    !sig.nil? ? exit(sig) : exit(0)
  end

end

