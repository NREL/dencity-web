# Structure helper
module StructuresHelper
  def highlight_hit(hit, field)
    highlights = hit.highlights(field)

    if highlights.any?
      highlights.collect { |highlight| highlight.format { |fragment| content_tag(:strong, fragment) } }.join(' ... ').html_safe
    else
      if (stored = hit.stored(field))
        stored.join(' ')
      end
    end
  end

  def facet_sum_item(facet, title, options = {})
    sum = facet.rows.sum(&:count)
    row = Sunspot::Search::FacetRow.new(title, sum, facet)

    facet_item(facet.field_name, row, options)
  end

  def facet_item(facet_field, row, options = {})
    link_text = nil
    case (facet_field)
      when :building_id
        building = Building.where(_id: row.value.to_s).first
        link_text = building.name if building
      else
        if row.value.present?
          link_text = t(row.value.to_s, scope: [:views, :facets, facet_field], default: row.value.to_s)
        end
    end

    link_text = 'Unknown' if link_text.blank?

    # Deep copy the current params so we don't end up modifying the actual
    # params hash every time this method is called.
    facet_params = Marshal.load(Marshal.dump(params))
    facet_params[:f] ||= {}

    # Always reset to page 1 when applying facets. Otherwise, the page the user
    # was currently sitting on may not exist after applying further filtering.
    facet_params[:page] = 1 if facet_params[:page].present?

    value = row.value

    facet_params[:f].delete(facet_field) if options[:singular]

    active = (params[:f] && params[:f][facet_field] && params[:f][facet_field].include?(value))
    if options[:singular] && row.value == 'Everything'
      active = (!params[:f] || !params[:f][facet_field])
    end

    item_class = 'facet-item'
    if options[:singular]
      item_class << " facet-item-#{row.value.downcase}"
      link_text = %(<i class="facet-icon"></i> #{link_text})
    end

    if active
      item_class << ' facet-item-active'

      if !options[:singular] || row.value != 'Everything'
        facet_params[:f][facet_field] ||= []
        facet_params[:f][facet_field].delete(value)
      end
    else
      item_class << ' facet-item-inactive'

      if !options[:singular] || row.value != 'Everything'
        facet_params[:f][facet_field] ||= []
        facet_params[:f][facet_field] << value
      end
    end

    content_tag(:li, class: item_class) do
      if options[:singular]
        link_to("#{link_text} (#{number_with_delimiter(row.count)})".html_safe, url_for(facet_params))
      else
        "#{link_to(link_text, url_for(facet_params))} (#{number_with_delimiter(row.count)})".html_safe
      end
    end
  end
end
