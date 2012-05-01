module ReportsHelper
  def chart_tag (action, height, params = {})
    params[:format] ||= :json
    path = url_for({:controller => 'reports', :action => action}.merge(params))      
    content_tag(:div, :'data-chart' => path, :style => "height: #{height}px;") do
      image_tag('icons/spinner.gif', :class => 'spinner')
    end
  end
end
