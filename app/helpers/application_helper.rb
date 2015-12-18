# application helper
module ApplicationHelper
  def active_nav(page)
    path = request.path
    active = ' class="active"'.html_safe
    active2 = 'active'.html_safe

    if path == '/'
      active if page == 'Home'
    elsif path == '/admin'
      active if page == 'Admin'
    elsif path.include? '/analyses'
      active if page == 'Analyses'
    elsif path.include? '/units'
      active if page == 'Units'
    elsif path.include? '/metas'
      active if page == 'Metadata'
    elsif path.include? '/apidocs'
      active if page == 'API'
    end
  end
end
