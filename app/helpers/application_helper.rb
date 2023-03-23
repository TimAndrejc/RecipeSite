module ApplicationHelper
    def display_active_class(link_path)
        "active" if current_page?(link_path)
    end
end
