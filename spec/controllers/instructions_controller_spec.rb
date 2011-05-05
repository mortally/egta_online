require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe InstructionsController do

  def mock_instruction(stubs={})
    @mock_instruction ||= mock_model(Instruction, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all instructions as @instructions" do
      Instruction.stub(:all) { [mock_instruction] }
      get :index
      assigns(:instructions).should eq([mock_instruction])
    end
  end

  describe "GET show" do
    it "assigns the requested instruction as @instruction" do
      Instruction.stub(:find).with("37") { mock_instruction }
      get :show, :id => "37"
      assigns(:instruction).should be(mock_instruction)
    end
  end

  describe "GET new" do
    it "assigns a new instruction as @instruction" do
      Instruction.stub(:new) { mock_instruction }
      get :new
      assigns(:instruction).should be(mock_instruction)
    end
  end

  describe "GET edit" do
    it "assigns the requested instruction as @instruction" do
      Instruction.stub(:find).with("37") { mock_instruction }
      get :edit, :id => "37"
      assigns(:instruction).should be(mock_instruction)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created instruction as @instruction" do
        Instruction.stub(:new).with({'these' => 'params'}) { mock_instruction(:save => true) }
        post :create, :instruction => {'these' => 'params'}
        assigns(:instruction).should be(mock_instruction)
      end

      it "redirects to the created instruction" do
        Instruction.stub(:new) { mock_instruction(:save => true) }
        post :create, :instruction => {}
        response.should redirect_to(instruction_url(mock_instruction))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved instruction as @instruction" do
        Instruction.stub(:new).with({'these' => 'params'}) { mock_instruction(:save => false) }
        post :create, :instruction => {'these' => 'params'}
        assigns(:instruction).should be(mock_instruction)
      end

      it "re-renders the 'new' template" do
        Instruction.stub(:new) { mock_instruction(:save => false) }
        post :create, :instruction => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested instruction" do
        Instruction.stub(:find).with("37") { mock_instruction }
        mock_instruction.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :instruction => {'these' => 'params'}
      end

      it "assigns the requested instruction as @instruction" do
        Instruction.stub(:find) { mock_instruction(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:instruction).should be(mock_instruction)
      end

      it "redirects to the instruction" do
        Instruction.stub(:find) { mock_instruction(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(instruction_url(mock_instruction))
      end
    end

    describe "with invalid params" do
      it "assigns the instruction as @instruction" do
        Instruction.stub(:find) { mock_instruction(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:instruction).should be(mock_instruction)
      end

      it "re-renders the 'edit' template" do
        Instruction.stub(:find) { mock_instruction(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested instruction" do
      Instruction.stub(:find).with("37") { mock_instruction }
      mock_instruction.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the instructions list" do
      Instruction.stub(:find) { mock_instruction }
      delete :destroy, :id => "1"
      response.should redirect_to(instructions_url)
    end
  end

end