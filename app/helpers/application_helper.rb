module ApplicationHelper
  def markdown(content)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, space_after_headers: true, fenced_code_blocks: true)
    @markdown.render(content)
  end
  def fractal_path actn, args={}
    name = case controller_name
    when 'ifs_chains'
      "ifs_chain"
    when 'iterated_function_systems'
      "iterated_function_system"
    else
      "fractal"
    end
    if %i[new edit].include? actn.try(:to_sym)
      try("#{actn}_#{name}_path".to_sym, args)
    else
      try("#{actn.blank? ? '' : actn.to_s + '_'}#{name}s_path".to_sym, args)
    end
  end
  def can_i_like fractal
    return false unless user_signed_in?
    return false if fractal.user_id == current_user.id
    @can_i_like[fractal.id]
  end
end
