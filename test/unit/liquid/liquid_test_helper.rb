# encoding: utf-8
#
# This file is a part of Redmine Invoices (redmine_contacts_invoices) plugin,
# invoicing plugin for Redmine
#
# Copyright (C) 2011-2024 RedmineUP
# https://www.redmineup.com/
#
# redmine_contacts_invoices is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_contacts_invoices is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_contacts_invoices.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../../test_helper', __FILE__)

class LiquidRender
  DATE_FORMAT = '%d.%m.%Y'.freeze

  def initialize(drops = {})
    @objects_hash = [
      { 'name' => 'one', "value" => 10 },
      { 'name' => 'two', "value" => 5 },
      { 'name' => 'three', "value" => 6 }
    ]
    @registers = {}
    @assigns = {}
    @assigns['objects_arr'] = @objects_hash
    @assigns['now'] = Time.now
    @assigns['today'] = Date.today.strftime(DATE_FORMAT)
    drops.each do |key, drop|
      @assigns[key] = drop
    end
  end

  def render(content)
    Liquid::Template.parse(content).render(Liquid::Context.new({}, @assigns, @registers)).html_safe
  rescue => e
    e.message
  end
end
