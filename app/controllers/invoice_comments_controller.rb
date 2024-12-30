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

class InvoiceCommentsController < ApplicationController
  default_search_scope :invoices
  model_object Invoice

  before_action :find_model_object
  before_action :find_project_from_association
  before_action :authorize

  accept_api_auth :create, :destroy

  def create
    raise Unauthorized unless @invoice.commentable?

    @comment = Comment.new
    @comment.safe_attributes = params[:comment]
    @comment.author = User.current
    @invoice.comments << @comment

    respond_to do |format|
      format.html { redirect_back_or_default(controller: 'invoices', action: 'show', id: @invoice) }
      format.api { @comment.persisted? ? render(:show, status: :created) : render_validation_errors(@comment) }
    end
  end

  def destroy
    @invoice.comments.find(params[:comment_id]).destroy
    respond_to do |format|
      format.html { redirect_to :controller => 'invoices', :action => 'show', :id => @invoice }
      format.api  {render_api_ok}
    end
  end

  private

  # ApplicationController's find_model_object sets it based on the controller
  # name so it needs to be overriden and set to @invoice instead
  def find_model_object
    super
    @invoice = @object
    @comment = nil
    @invoice
  end
end
