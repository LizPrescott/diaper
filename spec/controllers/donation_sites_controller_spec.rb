RSpec.describe DonationSitesController, type: :controller do
  let(:default_params) do
    { organization_id: @organization.to_param }
  end

  context "While signed in" do
    before do
      sign_in(@user)
    end

    describe "GET #index" do
      subject { get :index, params: default_params }
      it "returns http success" do
        expect(subject).to be_successful
      end
    end

    describe "GET #new" do
      subject { get :new, params: default_params }
      it "returns http success" do
        expect(subject).to be_successful
      end
    end

    describe "GET #edit" do
      subject { get :edit, params: default_params.merge(id: create(:donation_site, organization: @organization)) }
      it "returns http success" do
        expect(subject).to be_successful
      end
    end

    describe "POST #import_csv" do
      context "with a csv file" do
        let(:file) { Rack::Test::UploadedFile.new "spec/fixtures/donation_sites.csv", "text/csv" }
        subject { post :import_csv, params: default_params.merge(file: file) }

        it "invokes DonationSite.import_csv" do
          expect(DonationSite).to respond_to(:import_csv).with(2).arguments
        end

        it "redirects to :index" do
          expect(subject).to redirect_to(donation_sites_path(organization_id: @organization))
        end

        it "presents a flash notice message" do
          expect(subject.request.flash[:notice]).to eq "Donation sites were imported successfully!"
        end
      end

      context "without a csv file" do
        subject { post :import_csv, params: default_params }

        it "redirects to :index" do
          expect(subject).to redirect_to(donation_sites_path(organization_id: @organization))
        end

        it "presents a flash error message" do
          expect(subject.request.flash[:error]).to eq "No file was attached!"
        end
      end
    end

    describe "GET #show" do
      subject { get :show, params: default_params.merge(id: create(:donation_site, organization: @organization)) }
      it "returns http success" do
        expect(subject).to be_successful
      end
    end

    describe "DELETE #destroy" do
      subject { delete :destroy, params: default_params.merge(id: create(:donation_site, organization: @organization)) }
      it "returns http success" do
        expect(subject).to redirect_to(donation_sites_path)
      end
    end

    context "Looking at a different organization" do
      let(:object) { create(:donation_site, organization: create(:organization)) }
      include_examples "requiring authorization"
    end
  end

  context "While not signed in" do
    let(:object) { create(:donation_site) }

    include_examples "requiring authorization"
  end
end
