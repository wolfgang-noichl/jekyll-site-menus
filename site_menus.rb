# encoding: utf-8
#
# Jekyll site menus.
# https://github.com/MrWerewolf/jekyll-site-menus
#
# Copyright (c) 2012 Ryan Seto <mr.werewolf@gmail.com>
# Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)
#
# Place this script into the _plugins directory of your Jekyll site.
#
require 'uri'

module Jekyll
  class SiteMenus < Liquid::Tag
    def initialize(tag_name, menu_name, tokens)
      super
      @menu_name = menu_name.strip!
    end

    def render(context)
      site = context.registers[:site]
      menu = site.data['menus'][@menu_name]
      level = 1

      renderMenu(context, menu, level)
    end

    def renderMenu(context, menu, level)
      indent = "  " * (level - 1)
      output = "#{indent}"
      isFirstLvl = level == 1

      # Give this menu an id attribute if we're on the first level.
      if (isFirstLvl)
        output += "<ul id=\"#{@menu_name}-menu\" class=\"menu level-#{level}\">\n"
      else
        output += "<div class=\"sub-menu level-#{level}\"><ul class=\"menu sub-menu level-#{level}\">\n"
      end

      indent = "  " * (level)
      menu.each do | item |
        item.each do | name, value |
          if (value.kind_of? String)
            # Render the menu item
            output += "#{indent}<li>\n"
            output += renderMenuItem(context, name, value, level)
            output += "#{indent}</li>\n"
          elsif (value.kind_of? Array and value.size > 0)
            output += "#{indent}<li>\n"
            if (value[0].kind_of? String)
              output += renderMenuItem(context, name, value[0], level)
              submenu = value [1..value.size]
            else
              output += renderMenuItem(context, name, false, level)
              submenu = value
            end
            # Render the sub-menu
            output += renderMenu(context, submenu, level + 1)
            output += "#{indent}</li>\n"
          end
        end
      end

      indent = "  " * (level - 1)

      if (isFirstLvl)
        output += "#{indent}</ul>\n"
      else
        output += "#{indent}</ul></div>\n"
      end
    end

    def renderMenuItem(context, name, value, level)
      # If value is false, don't render a link, but plain text.
      page_url = context.environments.first["page"]["url"]
      if (!!value)
        uri = URI(value)
      # Figure out if our menu item is currently selected.
      # If the item is just a "group" item without an own page,
      # it can't be selected.
      selected = false
      
      indent = "  " * level
      output = "#{indent}  "

        # unless (uri.absolute?)
          #base_path = uri.path[-1, 1] == '/' ? uri.path : File.dirname(uri.path)
          base_path = uri.path
          path_parts = base_path.split('/')
          if (path_parts.size > 0)
            selected = (/^#{base_path}/ =~ page_url) != nil
          elsif (value == '/' and page_url == '/index.html')
            selected = true
          else
            selected = value == page_url
          end
        # end
      
        output += "<a href=\"#{URI.escape(value)}\""
        if (selected)
         output += " class=\"selected\""
        end
        output += ">"
      end
      

      output += name
      if (!!value)
        output += "</a>\n"
      end
      output
    end
  end

  Liquid::Template.register_tag('menu', Jekyll::SiteMenus)
end
