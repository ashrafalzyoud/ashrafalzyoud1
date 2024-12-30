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

class Redmine::ApiTest::InvoiceCommentsTest < Redmine::ApiTest::Base
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  RedmineInvoices::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_invoices).directory + '/test/fixtures/', [:invoices, :invoice_lines])

  def setup
    RedmineInvoices::TestCase.prepare
    Setting.rest_api_enabled = '1'
  end


  def test_post_invoice_comment
    invoice = Invoice.find(1)
    parameters = {
      id: invoice.id,
      comment: {comments: "API comment"}
    }

    assert_difference('Comment.count') do
      compatible_api_request :post, "/invoice_comments.json", parameters, credentials('admin')
    end

    comment = Comment.order('id DESC').first
    assert_equal "API comment", comment.comments
    assert_equal invoice.id, comment.commented_id

    assert_response :created
    assert_match 'application/json', @response.content_type
    response_json = ActiveSupport::JSON.decode(@response.body)
    assert_equal comment.id, response_json['comment']['id']
  end

  def test_post_invalid_invoice_comment
    invoice = Invoice.find(1)
    parameters = {
      id: invoice.id,
      comment: {comments: ""}
    }

    assert_no_difference('Comment.count') do
      compatible_api_request :post, "/invoice_comments.json", parameters, credentials('admin')
    end

    assert_response 422
    assert_match 'application/json', @response.content_type
    response_json = ActiveSupport::JSON.decode(@response.body)
    assert_equal 1, response_json['errors'].size
  end

  def test_delete_invoice_comment
    invoice = Invoice.first
    comment = Comment.new(content: "API comment", author_id: User.current.id)
    invoice.comments << comment

    assert_difference('Comment.count', -1) do
      compatible_api_request :delete, "/invoice_comments/#{invoice.id}.json", {comment_id: comment.id}, credentials('admin')
    end

    Redmine::VERSION.to_s >= '4.2' ? assert_response(:no_content) : assert_response(:success)
    assert_nil Comment.find_by_id(comment.id)
  end
end
