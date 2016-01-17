module ApplicationHelper
  def youtube_video(url)
    render :partial => 'shared/video', :locals => { :url => url }
  end

  def active_class(link_path)
    current_page?(link_path) ? "active" : ""
  end
end
