# frozen_string_literal: true

module LicenseFinder
  class ConanInfoParser
    def parse(info)
      @lines = info.lines.map(&:chomp)
      @state = :project_level # state of the state machine
      @projects = [] # list of projects
      @current_project = nil # current project being populated in the SM
      @current_vals = [] # current val list being populate in the SM
      @current_key = nil # current key to be associated with the current val
      while (line = @lines.shift)
        next if line == ''

        case @state
        when :project_level
          @current_project = {}
          @current_project['name'] = line.strip
          @state = :key_val
        when :key_val
          parse_key_val(line)
        when :val_list
          parse_val_list(line)
        end
      end
      wrap_up
    end

    private

    def parse_key_val(line)
      key, val = key_val(line)
      if val
        @current_project[key] = val
      elsif line.start_with?(' ')
        @current_key = key
        @current_vals = []
        @state = :val_list
      else
        change_to_new_project_state line
      end
    end

    def parse_val_list(line)
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

    def wrap_up
      @current_project[@current_key] = @current_vals if @current_vals.count && @current_key
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
      info.split(':', 2).map(&:strip!)
    end
  end
end
