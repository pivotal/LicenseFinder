module LicenseFinder
  class ConanInfoParser

    def parse(info)
      @lines = info.lines.map(&:chomp)
      @state = :project_level # state of the state machine
      @projects = [] # list of projects
      @current_project = nil # current project being populated in the SM
      @current_vals = [] # current val list being populate in the SM
      @current_key = nil # current key to be associated with the current val
      while line = @lines.shift()
          if line == '' then next end
          case @state
            when :project_level
              @current_project = {}
              @current_project['name']=line.strip
              @state = :key_val
            when :key_val
              key, val = key_val(line)
              if val
                @current_project[key] = val
              else
                if line.start_with?(' ')
                  @current_key = key
                  @current_vals = []
                  @state = :val_list
                else
                  change_to_new_project_state line
                end
              end
            when :val_list
              if val_list_level(line)
                @current_vals << line.strip
              else
                @current_project[@current_key] = @current_vals
                if line.start_with?(' ')
                  @state = :key_val
                  @lines.unshift(line)
                else
                  change_to_new_project_state line
                end
              end
          end
      end
      wrap_up
    end

    def wrap_up
      if @current_vals.count and @current_key then @current_project[@current_key] = @current_vals end
      @projects << @current_project
    end

    def val_list_level(line)
      line.start_with?('        ')
    end

    def change_to_new_project_state(line)
      @state = :project_level
      @projects << @current_project
      @lines.unshift(line)
    end

    def key_val(info)
      info.split(':', 2).map { |c| c.strip! }
    end
  end
end