require 'will_paginate/array'

module STATIC_TEXT
  FOUR_COLUMN_FEATURE_HOMEPAGE = [
    {   :icon_color => "text-primary", :icon_class => "icon-sitemap", :feature_title => "Groups" , :feature_content => "Lorem Ipsum is simply  dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."},
    {   :icon_color => "text-primary", :icon_class => "icon-money", :feature_title => "Expenses" , :feature_content => "Lorem Ipsum is simply  dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."},
    {   :icon_color => "text-primary", :icon_class => "icon-bar-chart", :feature_title => "Reports" , :feature_content => "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."},
    {   :icon_color => "text-primary", :icon_class => "icon-envelope-alt", :feature_title => "Reminders" , :feature_content => "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."}
  ]
end

module FLASH_METADATA
  FLASH_DATA =  {
                  :error => {:alert_class => "danger", :heading => "Error"},
                  :notice => {:alert_class => "info", :heading => "Success"}
                }
end

DEFAULT_START_DATE = "1000-01-01"
DEFAULT_END_DATE = "3000-01-01"