class ReportsController < ApplicationController
  def index
    @option = params[:option]
    @advanced = params[:advanced] || "false"
    if @option == "Custom Range"
      @start_date = params[:report_start_date] ? Time.new(params[:report_start_date][:year], params[:report_start_date][:month], params[:report_start_date][:day]) : nil
      @end_date = params[:report_end_date] ? Time.new(params[:report_end_date][:year], params[:report_end_date][:month], params[:report_end_date][:day]) : nil
    else
      @end_date = Date.today
      case(@option)
        when "Last Month" then @start_date = Date.today - 1.month
        when "Last Week" then @start_date = Date.today - 1.week
        else @start_date = nil
      end
    end
  end

  def spend_by_category
    render :json => {
      :type => 'PieChart',
      :cols => [['string', 'Category'], ['number', 'Spend']],
      :rows => Transaction.spend_by("category", current_user.id, params[:start_date], params[:end_date]).collect{|row| [row.category.capitalize, row.spend.to_f]},
      :options => {
        :chartArea => { :width => '90%', :height => '80%' },
        :legend => 'left',
        :is3D => true,
        :backgroundColor => 'WhiteSmoke'
      }
    }
  end

  def spend_by_account
    render :json => {
      :type => 'PieChart',
      :cols => [['string', 'Account'], ['number', 'Spend']],
      :rows => Transaction.spend_by("account_id", current_user.id, params[:start_date], params[:end_date]).collect{|row| [Account.find_by_id(row.account_id).name + " (" + Account.find_by_id(row.account_id).group.name + ")", row.spend.to_f]},
      :options => {
        :chartArea => { :width => '90%', :height => '80%' },
        :legend => 'left',
        :is3D => true,
        :backgroundColor => 'WhiteSmoke'
      }
    }
  end

  def spend_by_user
    render :json => {
      :type => 'PieChart',
      :cols => [['string', 'User'], ['number', 'Spend']],
      :rows => Transaction.spend_by("user_id", current_user.id, params[:start_date], params[:end_date]).collect{|row| [row.user_id == current_user.id ? "Myself" : User.find_by_id(row.user_id).name, row.spend.to_f]},
      :options => {
        :chartArea => { :width => '90%', :height => '80%' },
        :legend => 'right',
        :is3D => true,
        :backgroundColor => 'WhiteSmoke'
      }
    }
  end

  def transaction_count_by_category
    render :json => {
      :type => 'ColumnChart',
      :cols => [['string', 'Category'], ['number', 'No of Transactions']],
      :rows => Transaction.spend_by("category", current_user.id, params[:start_date], params[:end_date]).collect{|row| [row.category.capitalize, row.txn_count.to_i]},
      :options => {
        :chartArea => { :width => '80%', :height => '80%' },
        :legend => 'none',
        :is3D => true,
        :backgroundColor => 'WhiteSmoke'
      }
    }
  end

  def transaction_count_by_account
    render :json => {
      :type => 'ColumnChart',
      :cols => [['string', 'Account'], ['number', 'No of Transactions']],
      :rows => Transaction.spend_by("account_id", current_user.id, params[:start_date], params[:end_date]).collect{|row| [Account.find_by_id(row.account_id).name + " (" + Account.find_by_id(row.account_id).group.name + ")", row.txn_count.to_i]},
      :options => {
        :chartArea => { :width => '80%', :height => '80%' },
        :legend => 'none',
        :is3D => true,
        :backgroundColor => 'WhiteSmoke'
      }
    }
  end

  def avg_spend_by_category
    render :json => {
      :type => 'LineChart',
      :cols => [['string', 'Category'], ['number', 'Avg Spend/Transaction']],
      :rows => Transaction.spend_by("category", current_user.id, params[:start_date], params[:end_date]).collect{|row| [row.category.capitalize, (row.spend.to_f/row.txn_count.to_i).round(2)]},
      :options => {
        :chartArea => { :width => '80%', :height => '80%' },
        :legend => 'none',
        :is3D => true,
        :backgroundColor => 'WhiteSmoke'
      }
    }
  end

  def avg_spend_by_account
    render :json => {
      :type => 'LineChart',
      :cols => [['string', 'Account'], ['number', 'Avg Spend/Transaction']],
      :rows => Transaction.spend_by("account_id", current_user.id, params[:start_date], params[:end_date]).collect{|row| [Account.find_by_id(row.account_id).name + " (" + Account.find_by_id(row.account_id).group.name + ")", (row.spend.to_f/row.txn_count.to_i).round(2)]},
      :options => {
        :chartArea => { :width => '80%', :height => '80%' },
        :legend => 'none',
        :is3D => true,
        :backgroundColor => 'WhiteSmoke'
      }
    }
  end
end
