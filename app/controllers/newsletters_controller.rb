class NewslettersController < ApplicationController
  def new
    @newsletter = Newsletter.new
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)

    if @newsletter.save
      redirect_to root_path, notice: 'Thank you for subscribing to our newsletter!'
    else
      render :new
    end
  end

  private

  def newsletter_params
    params.require(:newsletter).permit(:email)
  end
end
