class NewsletterMailer < ApplicationMailer
    def send_newsletter(newsletter)
      @newsletter = newsletter
      mail to: newsletter.email, subject: 'Newsletter from MyApp'
    end
  end
  