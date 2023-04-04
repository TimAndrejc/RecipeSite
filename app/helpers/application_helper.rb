module ApplicationHelper
    def display_active_class(link_path)
        "active" if current_page?(link_path)
    end

    def display_navbar_options
        if user_signed_in?
            render 'dropdown_options'
        else
            render 'login_buttons'
        end
    end
end
