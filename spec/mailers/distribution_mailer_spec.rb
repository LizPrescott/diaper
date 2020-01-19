RSpec.describe DistributionMailer, type: :mailer do
  context 'Rendering the email' do
    before do
      @organization.default_email_text = "Default email text example"
      @distribution = create(:distribution, organization: @user.organization, comment: "Distribution comment")
    end

    let(:mail) { DistributionMailer.partner_mailer(@organization, @distribution, 'test subject') }

    it "renders the body with organizations email text" do
      expect(mail.body.encoded).to match("Default email text example")
      expect(mail.subject).to eq("test subject from DEFAULT")
    end

    it "renders the body with distributions text" do
      expect(mail.body.encoded).to match("Distribution comment")
      expect(mail.subject).to eq("test subject from DEFAULT")
    end
  end

  context 'Conditionally sending the email' do
    before do
      @organization.default_email_text = "Default email text example"
      @distribution = create(:distribution, organization: @user.organization, comment: "Distribution comment", issued_at: Time.zone.now - 1.week)
    end

    let(:future_distribution) { create(:distribution, organization: @user.organization, comment: "Distribution comment") }
    let(:mail) { DistributionMailer.partner_mailer(@organization, @distribution, 'test subject') }
    let(:reminder_mail) { DistributionMailer.reminder_email(@distribution) }
    let(:future_distro_mail) { DistributionMailer.partner_mailer(@organization, future_distribution, 'test subject') }
    let(:future_distro_reminder_mail) { DistributionMailer.reminder_email(distribution) }

    it 'sends email when future distributions are edited' do
      expect { future_distribution }.to change(ActionMailer::Base.deliveries, :count)
    end

    it 'does not send email for edits to past distributions' do
      expect { mail }.to_not change(ActionMailer::Base.deliveries, :count)
    end

    it 'does not send reminders for past distributions' do
      expect { reminder_mail }.to_not change(ActionMailer::Base.deliveries, :count)
    end
  end
end
