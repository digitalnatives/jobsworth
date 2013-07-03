# encoding: UTF-8
require "csv"

# Massage the WorkLogs in different ways, saving reports for later access
# as well as CSV downloading.
#
class BillingsController < ApplicationController

  layout 'basic'

  def index
    sql_filter  = ""
    date_filter = ""

    @tags              = Tag.top_counts(current_user.company)
    @users             = User.order('name').where('users.company_id = ?', current_user.company_id).joins("INNER JOIN project_permissions ON project_permissions.user_id = users.id")
    @custom_attributes = current_user.company.custom_attributes.by_type("WorkLog")

    if options = params[:report]
      @worklog_report = WorklogReport.new(self, options)

      @column_headers   = @worklog_report.column_headers
      @column_totals    = @worklog_report.column_totals
      @rows             = @worklog_report.rows
      @row_totals       = @worklog_report.row_totals
      @total            = @worklog_report.total
      @generated_report = @worklog_report.generated_report
    end

    flash[:alert] = t('flash.alert.empty_report') if @column_headers.blank? && params[:report]
  end

  def get_csv
    @report = GeneratedReport.where(user_id: current_user, company_id: current_user.company_id).find(params[:id])

    send_data(@report.report,
              :type => 'text/csv; charset=utf-8; header=present',
              :filename => @report.filename)

  rescue ActiveRecord::RecordNotFound => e
    redirect_to :index
  end

end
