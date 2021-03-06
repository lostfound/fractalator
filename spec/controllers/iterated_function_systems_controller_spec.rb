require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe IteratedFunctionSystemsController, type: :controller do
  render_views

  # This should return the minimal set of attributes required to create a valid
  # IteratedFunctionSystem. As you add validations to IteratedFunctionSystem, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    #skip("Add a hash of attributes valid for your model")
    {name: 'LSD'}
  }

  let(:invalid_attributes) {
    #skip("Add a hash of attributes invalid for your model")
    {name: "Глебпарад"}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # IteratedFunctionSystemsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "User is logged in" do
    login
    describe "GET #index" do
      it "assigns all iterated_function_systems as @fractals" do
        iterated_function_system = create :ifs, user: @user
        get :index, {}, valid_session
        expect(assigns(:fractals)).to eq([iterated_function_system])
      end
      it "assigns all ''named'' iterated_function_systems as @fractals" do
        create :ifs, name: '', user: @user
        iterated_function_system = create :ifs, user: @user
        get :index, {}, valid_session
        expect(assigns(:fractals)).to eq([iterated_function_system])
      end
    end
    describe "GET #index/:user_id" do
      before(:each) do
        @my_fractals = []
        @my_fractals<<create(:ifs, user: @user)
        @my_fractals.unshift create(:ifs, user: @user, name: '')
        @somebody = create :user
        @smb_fractals=[]
        @smb_fractals<<create(:ifs, user: @somebody)
        create(:ifs, user: @somebody, name: '')
      end
      it "assigns all itself fractals as @fractals" do
        get :index, {id: @user.id}, valid_session
        expect(assigns(:fractals)).to eq(@my_fractals)
      end
      it "assigns smb. else's named fractals as @fractals" do
        get :index, {id: @somebody.id}, valid_session
        expect(assigns(:fractals)).to eq(@smb_fractals)
      end
    end

    describe "GET #show" do
      it "assigns the requested iterated_function_system as @fractal" do
        iterated_function_system = create :ifs, user: @user
        get :show, {:id => iterated_function_system.to_param}, valid_session
        
        expect(assigns(:fractal)).to eq(iterated_function_system)
      end
      it "redirects to previous page if requested fractal has other owner and has not the name" do
        @somebody = create :user
        fractal = create :ifs, user: @somebody, name: ''
        reffer= "/god_is_dog"
        @request.env['HTTP_REFERER'] = reffer.clone
        #reffer = @request.host.to_s + '/' + reffer
        get :show, {:id => fractal.to_param}, valid_session
        expect(response).to redirect_to(reffer)
      end
    end

    describe "GET #new" do
      it "assigns a new iterated_function_system as @fractal" do
        get :new, {}, valid_session
        expect(assigns(:fractal)).to be_a_new(IteratedFunctionSystem)
      end
    end
    describe "GET #fork" do
      before(:each) do
        @somebody = create :user
        @fractal = create :ifs, transforms: "[]", user: @somebody, rec_number: 13, base_shape: 1
        @private_fractal = create :ifs, transforms: "[]", user: @somebody, name: ''
      end
      it "assigns a new iterated_function_system as @fractal with inherited parametrs" do
        get :fork, {id: @fractal.to_param}, valid_session
        fractal = assigns(:fractal)
        expect(assigns(:fractal)).to be_a(IteratedFunctionSystem)
        expect(fractal.id).to be_nil
        expect(fractal.parent).to eq(@fractal)
        expect(fractal.transforms).to eq(@fractal.transforms)
        expect(fractal.rec_number).to eq(@fractal.rec_number)
        expect(fractal.base_shape).to eq(@fractal.base_shape)
      end
      it "assigns a new user's nonamed iterated_function_system as @fractal" do
        @private_fractal.update user: @user
        get :fork, {id: @private_fractal.to_param}, valid_session
        fractal = assigns(:fractal)
        expect(assigns(:fractal)).to be_a(IteratedFunctionSystem)
        expect(fractal.parent).to eq(@private_fractal)
      end
      it "redirects to previous page if cloned fractal has other owner and has not the name" do
        reffer= "/god_is_dog"
        @request.env['HTTP_REFERER'] = reffer.clone
        get :fork, {id: @private_fractal.to_param}, valid_session
        expect(response).to redirect_to(reffer)
      end
    end

    describe "GET #edit" do
      it "assigns the requested iterated_function_system as @fractal" do
        iterated_function_system = create :ifs, user: @user
        get :edit, {:id => iterated_function_system.to_param}, valid_session
        expect(assigns(:fractal)).to eq(iterated_function_system)
      end
      it "redirects to previous page if requested fractal has other owner" do
        @somebody = create :user
        fractal = create :ifs, user: @somebody, name: ''
        reffer= "/god_is_dog"
        @request.env['HTTP_REFERER'] = reffer.clone
        #reffer = @request.host.to_s + '/' + reffer
        get :edit, {id: fractal.to_param}, valid_session
        expect(response).to redirect_to(reffer)
      end
    end

    describe "POST #create" do
      #VALID
      context "with valid params" do
        it "creates a new IteratedFunctionSystem" do
          expect {
            post :create, {:iterated_function_system => valid_attributes}, valid_session
          }.to change(IteratedFunctionSystem, :count).by(1)
        end

        it "assigns a newly created iterated_function_system as @fractal" do
          post :create, {iterated_function_system: valid_attributes}, valid_session
          expect(assigns(:fractal)).to be_a(IteratedFunctionSystem)
          expect(assigns(:fractal)).to be_persisted
        end

        it "redirects to the created iterated_function_system" do
          post :create, {:iterated_function_system => valid_attributes}, valid_session
          expect(response).to redirect_to(IteratedFunctionSystem.last)
        end
      end

      #INVALID
      context "with invalid params" do
        it "assigns a newly created but unsaved iterated_function_system as @fractal" do
          post :create, {:iterated_function_system => invalid_attributes}, valid_session
          expect(assigns(:fractal)).to be_a_new(IteratedFunctionSystem)
        end

        it "re-renders the 'new' template" do
          post :create, {:iterated_function_system => invalid_attributes}, valid_session
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      before(:each) { @ifs =  create :ifs, user: @user  }
      context "with valid params" do
        let(:new_attributes) {
          {name: "Holocoust"}
        }

        it "updates the requested iterated_function_system" do
          put :update, {id: @ifs.to_param, iterated_function_system: new_attributes}, valid_session
          @ifs.reload
          expect(@ifs.name).to eq(new_attributes[:name])
        end

        it "assigns the requested iterated_function_system as @iterated_function_system" do
          put :update, {id: @ifs.to_param, :iterated_function_system => valid_attributes}, valid_session
          expect(assigns(:fractal)).to eq(@ifs)
        end

        it "redirects to the iterated_function_system" do
          @ifs
          put :update, {:id => @ifs.to_param, :iterated_function_system => valid_attributes}, valid_session
          expect(response).to redirect_to(@ifs)
        end
        it "redirects to previous page if requested fractal has other owner" do
          @somebody = create :user
          fractal = create :ifs, user: @somebody, name: ''
          reffer= "/god_is_dog"
          @request.env['HTTP_REFERER'] = reffer.clone
          put :update, {id: fractal.to_param, iterated_function_system: valid_attributes}, valid_session
          expect(response).to redirect_to(reffer)
        end
      end

      context "with invalid params" do
        it "assigns the iterated_function_system as @iterated_function_system" do
          put :update, {id: @ifs.to_param, :iterated_function_system => invalid_attributes}, valid_session
          expect(assigns(:fractal)).to eq(@ifs)
        end

        it "re-renders the 'edit' template" do
          put :update, {:id => @ifs.to_param, :iterated_function_system => invalid_attributes}, valid_session
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      before(:each) do
        @ifs =  create :ifs, user: @user
        @not_my_ifs = create :ifs, user: create(:user)
        @request.env['HTTP_REFERER'] = "/iterated_function_systems"
      end
      it "destroys the requested iterated_function_system" do
        expect {
          delete :destroy, {id: @ifs.to_param}, valid_session
        }.to change(IteratedFunctionSystem, :count).by(-1)
      end

      it "redirects to the iterated_function_systems list" do
        delete :destroy, {id: @ifs.to_param}, valid_session
        expect(response).to redirect_to(iterated_function_systems_url)
      end
    end
  end

  #Is not Logged in
  describe "User is not logged in" do
    #describe "GET #index" do
    #  it "redirects to login page" do
    #    iterated_function_system = create :ifs, user: @user
    #    get :index, {}, valid_session
    #    expect(response).to redirect_to("/")
    #  end
    #end

    #describe "GET #show" do
    #  it "redirects to login page" do
    #    iterated_function_system = create :ifs
    #    get :show, {:id => iterated_function_system.to_param}, valid_session
    #    expect(response).to redirect_to("/")
    #  end
    #end

    describe "GET #new" do
      it "redirects to login page" do
        get :new, {}, valid_session
        expect(response).to redirect_to("/")
      end
    end

    describe "GET #edit" do
      it "redirects to login page" do
        iterated_function_system = create :ifs, user: @user
        get :edit, {:id => iterated_function_system.to_param}, valid_session
        expect(response).to redirect_to("/")
      end
    end
    describe "POST #create" do
      it "redirects to login page" do
        post :create, {:iterated_function_system => valid_attributes}, valid_session
        expect(response).to redirect_to("/")
      end
    end
    describe "PUT #update" do
      before(:each) { @ifs =  create :ifs, user: create(:user) }
      it "redirects to login page" do
        put :update, {id: @ifs.to_param, :iterated_function_system => valid_attributes}, valid_session
        expect(response).to redirect_to("/")
      end
    end
    describe "DELETE #destroy" do
      before(:each) { @ifs =  create :ifs, user: create(:user) }
      it "redirects to login page" do
        delete :destroy, {id: @ifs.to_param}, valid_session
        expect(response).to redirect_to("/")
      end
    end

  end

end
